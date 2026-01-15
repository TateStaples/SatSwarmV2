#!/usr/bin/env python3
"""
Generate a reference trace from mega_sim.py for comparison with hardware simulation.
Usage: python gen_trace.py <cnf_file>
"""

import sys
import heapq

# ==========================================
# 0. Configuration & Debugging Support
# ==========================================

class Logger:
    """Trace logger that outputs mega_sim-compatible format."""
    def __init__(self, verbose=True):
        self.verbose = verbose
        self.decisions = 0
        self.conflicts = 0
        self.propagations = 0
        self.learned_clauses = 0

    def log(self, module, message):
        if self.verbose:
            print(f"[mega_sim] [{module}] {message}")
    
    def log_decision(self, lit, level):
        self.decisions += 1
        self.log("VDE", f"Decided: {lit} @ Level {level} (decision #{self.decisions})")
    
    def log_assignment(self, lit, level, is_decision=False):
        var = abs(lit)
        val = "True" if lit > 0 else "False"
        tag = "[DECISION]" if is_decision else f"[PROPAGATION #{self.propagations}]"
        if not is_decision:
            self.propagations += 1
        self.log("MEM", f"Assigned {lit} (Var {var}) = {val} @ Level {level} {tag}")
    
    def log_propagation(self, lit, clause_idx):
        self.log("PSE", f"Propagating Unit {lit} from Clause {clause_idx}")
    
    def log_conflict(self, clause_lits):
        self.conflicts += 1
        self.log("PSE", f"Conflict detected (conflict #{self.conflicts}) in Clause: {clause_lits}")
    
    def log_learned_clause(self, learned, bt_level):
        self.learned_clauses += 1
        self.log("CAE", f"Learned Clause #{self.learned_clauses}: {learned}, Backtrack to: {bt_level}")
    
    def log_backtrack(self, from_level, to_level):
        self.log("SYS", f"Backtracking from level {from_level} to level {to_level}")
    
    def print_summary(self):
        print(f"\n[mega_sim] [SYS] ==========================================")
        print(f"[mega_sim] [SYS] FINAL RESULTS")
        print(f"[mega_sim] [SYS] ==========================================")
        print(f"[mega_sim] [SYS] Decisions: {self.decisions}")
        print(f"[mega_sim] [SYS] Conflicts: {self.conflicts}")
        print(f"[mega_sim] [SYS] Propagations: {self.propagations}")
        print(f"[mega_sim] [SYS] Learned Clauses: {self.learned_clauses}")
        print(f"[mega_sim] [SYS] ==========================================")

DEBUG = Logger(verbose=True)

# ==========================================
# 1. Hardware-Optimized Memory Scheme
# ==========================================

class ClauseEntry:
    def __init__(self, literals, lbd=0):
        self.literals = literals  
        self.lbd = lbd            
        self.next_ptr = {}      
        self.cached_wlit = None   
        self.is_learned = False

    def __repr__(self):
        return f"Clause(Lits={self.literals})"

class MemorySystem:
    def __init__(self, num_vars):
        self.num_vars = num_vars
        self.assignments = [0] * (num_vars + 1) 
        self.trail = []                 
        self.trail_lim = []             
        self.reason = [None] * (num_vars + 1) 
        self.level = [-1] * (num_vars + 1)    
        self.clause_db = [] 
        self.watch_heads = [None] * (2 * num_vars + 2) 
        self.conflict_clause_idx = None

    def get_val(self, lit):
        var = abs(lit)
        sign = 1 if lit > 0 else -1
        val = self.assignments[var]
        if val == 0: return 0
        return 1 if val == sign else -1

    def assign(self, lit, reason_clause_idx=None, decision_level=0, is_decision=False):
        var = abs(lit)
        val = 1 if lit > 0 else -1
        self.assignments[var] = val
        self.level[var] = decision_level
        self.reason[var] = reason_clause_idx
        self.trail.append(lit)
        DEBUG.log_assignment(lit, decision_level, is_decision)

    def add_clause(self, literals, is_learned=False):
        c_idx = len(self.clause_db)
        entry = ClauseEntry(literals)
        entry.is_learned = is_learned
        self.clause_db.append(entry)

        if len(literals) == 0: return c_idx 
        if len(literals) == 1:
            return c_idx

        self._attach_watch(literals[0], c_idx)
        self._attach_watch(literals[1], c_idx)
        return c_idx

    def _attach_watch(self, lit, c_idx):
        lit_idx = self._lit_to_idx(lit)
        old_head = self.watch_heads[lit_idx]
        self.clause_db[c_idx].next_ptr[lit] = old_head 
        self.watch_heads[lit_idx] = c_idx

    def _lit_to_idx(self, lit):
        return (abs(lit) * 2) + (1 if lit < 0 else 0)

# ==========================================
# 2. Propagation Search Engine (PSE)
# ==========================================

class PropagationSearchEngine:
    def __init__(self, memory):
        self.mem = memory
        self.q_head = 0 

    def propagate(self):
        while self.q_head < len(self.mem.trail):
            lit = self.mem.trail[self.q_head]
            self.q_head += 1
            
            false_lit = -lit 
            
            if self.process_watch_list(false_lit) == "CONFLICT":
                return "CONFLICT"
        
        return "NO_CONFLICT"

    def process_watch_list(self, false_lit):
        lit_idx = self.mem._lit_to_idx(false_lit)
        curr_c_idx = self.mem.watch_heads[lit_idx]
        
        new_head = None
        last_ptr = None
        
        while curr_c_idx is not None:
            clause = self.mem.clause_db[curr_c_idx]
            next_c_idx = clause.next_ptr.get(false_lit)

            status = self.check_clause(curr_c_idx, false_lit)
            
            if status == "KEEP_WATCH":
                if new_head is None: new_head = curr_c_idx
                else: self.mem.clause_db[last_ptr].next_ptr[false_lit] = curr_c_idx
                last_ptr = curr_c_idx
                self.mem.clause_db[curr_c_idx].next_ptr[false_lit] = None 
                
            elif status == "MOVED_WATCH":
                pass
            
            elif status == "CONFLICT":
                if new_head is None: self.mem.watch_heads[lit_idx] = curr_c_idx
                else: self.mem.clause_db[last_ptr].next_ptr[false_lit] = curr_c_idx
                return "CONFLICT"
                
            curr_c_idx = next_c_idx

        if last_ptr is not None:
            self.mem.clause_db[last_ptr].next_ptr[false_lit] = None
        self.mem.watch_heads[lit_idx] = new_head
        return "OK"

    def check_clause(self, c_idx, false_lit):
        clause = self.mem.clause_db[c_idx]
        lits = clause.literals
        
        if lits[0] == false_lit:
            lits[0], lits[1] = lits[1], lits[0]
        
        if self.mem.get_val(lits[0]) == 1:
            return "KEEP_WATCH" 
            
        for i in range(2, len(lits)):
            if self.mem.get_val(lits[i]) != -1:
                lits[1], lits[i] = lits[i], lits[1]
                self.mem._attach_watch(lits[1], c_idx) 
                return "MOVED_WATCH"
        
        if self.mem.get_val(lits[0]) == -1:
            DEBUG.log_conflict(lits)
            self.mem.conflict_clause_idx = c_idx
            return "CONFLICT"
        else:
            DEBUG.log_propagation(lits[0], c_idx)
            self.mem.assign(lits[0], c_idx, decision_level=len(self.mem.trail_lim))
            return "KEEP_WATCH"

# ==========================================
# 3. Conflict Analysis Engine (CAE)
# ==========================================

class ConflictAnalysisEngine:
    def __init__(self, memory, decision_engine):
        self.mem = memory
        self.vde = decision_engine

    def analyze(self, conflict_c_idx):
        curr_level = len(self.mem.trail_lim)
        if curr_level == 0: return None, -1 
        
        learned = []
        path_c = 0
        p = None
        
        clause_to_resolve = self.mem.clause_db[conflict_c_idx].literals
        seen = set()
        index = len(self.mem.trail) - 1

        while True:
            for lit in clause_to_resolve:
                var = abs(lit)
                if var not in seen:
                    seen.add(var)
                    if self.mem.level[var] == curr_level:
                        path_c += 1
                    else:
                        learned.append(lit)
            
            while True:
                if index < 0: break 
                p = self.mem.trail[index]
                index -= 1
                if abs(p) in seen: break
            
            path_c -= 1
            if path_c <= 0: break
            
            reason_idx = self.mem.reason[abs(p)]
            if reason_idx is None:
                 break
            
            clause_to_resolve = [l for l in self.mem.clause_db[reason_idx].literals if l != p]

        learned.insert(0, -p)
        
        if len(learned) == 1:
            bt_level = 0
        else:
            levels = []
            for l in learned[1:]:
                lvl = self.mem.level[abs(l)]
                if lvl == -1: lvl = 0
                levels.append(lvl)
            bt_level = max(levels) if levels else 0
        
        DEBUG.log_learned_clause(learned, bt_level)
        
        for lit in learned:
            self.vde.bump_activity(abs(lit))
        self.vde.decay_activities()

        return learned, bt_level

# ==========================================
# 4. Variable Decision Engine (VDE)
# ==========================================

class VariableDecisionEngine:
    def __init__(self, memory, num_vars):
        self.mem = memory
        self.activity = [0.0] * (num_vars + 1)
        self.var_inc = 1.0
        self.decay_factor = 0.9275 
        self.queue = [] 
        
        for i in range(1, num_vars + 1):
            heapq.heappush(self.queue, (-self.activity[i], i))

    def bump_activity(self, var):
        self.activity[var] += self.var_inc
        if self.activity[var] > 1e100:
            for i in range(len(self.activity)):
                self.activity[i] *= 1e-100
            self.var_inc *= 1e-100

    def decay_activities(self):
        self.var_inc *= (1 / self.decay_factor)

    def decide(self):
        while self.queue:
            _, var = heapq.heappop(self.queue)
            if self.mem.assignments[var] == 0:
                return -var 
        return None

# ==========================================
# 5. Top-Level VeriSAT Solver
# ==========================================

class VeriSAT:
    def __init__(self, cnf_content):
        self.num_vars, clauses = self.parse_dimacs(cnf_content)
        
        self.mem = MemorySystem(self.num_vars)
        self.vde = VariableDecisionEngine(self.mem, self.num_vars)
        self.pse = PropagationSearchEngine(self.mem)
        self.cae = ConflictAnalysisEngine(self.mem, self.vde)
        
        for cls in clauses:
            self.mem.add_clause(cls)

    def parse_dimacs(self, content):
        lines = content.strip().split('\n')
        clauses = []
        num_vars = 0
        for line in lines:
            line = line.strip()
            if line.startswith('p cnf'):
                parts = line.split()
                num_vars = int(parts[2])
            elif not line.startswith('c') and not line.startswith('%') and line:
                lits = [int(x) for x in line.split() if x != '0']
                if lits: clauses.append(lits)
        return num_vars, clauses

    def solve(self):
        DEBUG.log("SYS", "Starting VeriSAT Solve...")
        
        if self.pse.propagate() == "CONFLICT":
            return "UNSAT"

        while True:
            next_lit = self.vde.decide()
            if next_lit is None:
                if any(x == 0 for x in self.mem.assignments[1:]):
                     pass
                
                DEBUG.log("SYS", f"Result: SAT with assignments: {self.mem.assignments[1:]}")
                return "SAT"
            
            self.mem.trail_lim.append(len(self.mem.trail))
            decision_level = len(self.mem.trail_lim)
            DEBUG.log_decision(next_lit, decision_level)
            self.mem.assign(next_lit, reason_clause_idx=None, decision_level=decision_level, is_decision=True)

            while True:
                conflict_status = self.pse.propagate()
                
                if conflict_status == "CONFLICT":
                    learned_clause, bt_level = self.cae.analyze(self.mem.conflict_clause_idx)
                    
                    if bt_level == -1:
                        DEBUG.log("SYS", "Result: UNSAT")
                        return "UNSAT"
                    
                    DEBUG.log_backtrack(len(self.mem.trail_lim), bt_level)
                    self.backtrack(bt_level)
                    
                    c_idx = self.mem.add_clause(learned_clause, is_learned=True)
                    
                    lit = learned_clause[0]
                    self.mem.assign(lit, c_idx, decision_level=bt_level)
                    self.pse.q_head = len(self.mem.trail) - 1
                else:
                    break

    def backtrack(self, level):
        while len(self.mem.trail_lim) > level:
            limit = self.mem.trail_lim.pop()
            while len(self.mem.trail) > limit:
                lit = self.mem.trail.pop()
                var = abs(lit)
                self.mem.assignments[var] = 0
                self.mem.level[var] = -1
                self.mem.reason[var] = None
                heapq.heappush(self.vde.queue, (-self.vde.activity[var], var))
        self.pse.q_head = len(self.mem.trail)

# ==========================================
# Main
# ==========================================

def main():
    if len(sys.argv) > 1:
        cnf_file = sys.argv[1]
        with open(cnf_file, 'r') as f:
            cnf_content = f.read()
    else:
        # Default: use the embedded 8-var UNSAT instance
        cnf_content = """
p cnf 8 20
4 -3 6 0
5 -4 -8 0
-6 -8 4 0
7 -3 -2 0
-7 6 8 0
-8 3 5 0
-4 -7 -3 0
1 -8 3 0
1 5 8 0
-1 -4 5 0
-5 8 -6 0
-8 7 2 0
-4 -5 7 0
-4 3 -1 0
6 4 -1 0
5 4 -6 0
-4 -1 7 0
6 3 5 0
-5 8 1 0
4 -8 -6 0
"""
    
    print("[mega_sim] [SYS] ==========================================")
    print("[mega_sim] [SYS] Python Reference Trace Generator")
    print("[mega_sim] [SYS] ==========================================")
    
    solver = VeriSAT(cnf_content)
    result = solver.solve()
    
    print(f"\n[mega_sim] [SYS] Final Result: {result}")
    DEBUG.print_summary()

if __name__ == "__main__":
    main()
