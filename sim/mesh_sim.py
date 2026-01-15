#!/usr/bin/env python3
"""
Multi-Core VeriSAT Mesh Simulator
Simulates 2x2 mesh grid with identical parallel search (no divergence).
This is a reference for debugging the hardware implementation.
"""

import sys
import heapq
import logging
from copy import deepcopy

# ==========================================
# Configuration
# ==========================================

GRID_X = 2
GRID_Y = 2
NUM_CORES = GRID_X * GRID_Y
VERBOSE = False

logging.basicConfig(
    level=logging.INFO if VERBOSE else logging.WARNING,
    format='[%(name)s] %(message)s'
)

# ==========================================
# Single-Core Solver (copied from mega_sim.py)
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

    def assign(self, lit, reason_clause_idx=None, decision_level=0):
        var = abs(lit)
        if self.assignments[var] != 0:
            return
        val = 1 if lit > 0 else -1
        self.assignments[var] = val
        self.level[var] = decision_level
        self.reason[var] = reason_clause_idx
        self.trail.append(lit)

    def add_clause(self, literals, is_learned=False):
        c_idx = len(self.clause_db)
        entry = ClauseEntry(literals)
        entry.is_learned = is_learned
        self.clause_db.append(entry)
        if len(literals) == 0: return c_idx 
        if len(literals) == 1: return c_idx
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
            self.mem.conflict_clause_idx = c_idx
            return "CONFLICT"
        else:
            self.mem.assign(lits[0], c_idx, decision_level=len(self.mem.trail_lim))
            return "KEEP_WATCH"

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
            if abs(p) not in seen: break
            reason_idx = self.mem.reason[abs(p)]
            if reason_idx is None: break
            clause_to_resolve = [l for l in self.mem.clause_db[reason_idx].literals if abs(l) != abs(p)]

        learned.insert(0, -p)
        if len(learned) == 1:
            bt_level = 0
        else:
            levels = [self.mem.level[abs(l)] if self.mem.level[abs(l)] != -1 else 0 for l in learned[1:]]
            bt_level = max(levels) if levels else 0
        
        for lit in learned: self.vde.bump_activity(abs(lit))
        self.vde.decay_activities()
        return learned, bt_level

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
# Single Solver Core
# ==========================================

class SolverCore:
    def __init__(self, core_id, num_vars, clauses):
        self.core_id = core_id
        self.mem = MemorySystem(num_vars)
        self.vde = VariableDecisionEngine(self.mem, num_vars)
        self.pse = PropagationSearchEngine(self.mem)
        self.cae = ConflictAnalysisEngine(self.mem, self.vde)
        self.result = None
        self.conflicts = 0
        
        for cls in clauses:
            self.mem.add_clause(list(cls))  # Copy to avoid sharing
    
    def step(self):
        """Run one step of the solver. Returns 'SAT', 'UNSAT', or None (continuing)."""
        if self.result is not None:
            return self.result
            
        # Initial propagation
        if len(self.mem.trail_lim) == 0:
            if self.pse.propagate() == "CONFLICT":
                self.result = "UNSAT"
                return "UNSAT"
        
        # Decision
        next_lit = self.vde.decide()
        if next_lit is None:
            self.result = "SAT"
            return "SAT"
        
        self.mem.trail_lim.append(len(self.mem.trail))
        self.mem.assign(next_lit, reason_clause_idx=None, decision_level=len(self.mem.trail_lim))
        
        # Propagation and conflict handling
        while True:
            conflict_status = self.pse.propagate()
            
            if conflict_status == "CONFLICT":
                self.conflicts += 1
                learned_clause, bt_level = self.cae.analyze(self.mem.conflict_clause_idx)
                
                if bt_level == -1:
                    self.result = "UNSAT"
                    return "UNSAT"
                
                self._backtrack(bt_level)
                c_idx = self.mem.add_clause(learned_clause, is_learned=True)
                lit = learned_clause[0]
                self.mem.assign(lit, c_idx, decision_level=bt_level)
                self.pse.q_head = len(self.mem.trail) - 1
            else:
                break
        
        return None  # Continuing

    def _backtrack(self, level):
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
# Multi-Core Mesh Solver
# ==========================================

class MeshSolver:
    def __init__(self, cnf_content):
        self.num_vars, self.clauses = self._parse_dimacs(cnf_content)
        self.cores = [
            SolverCore(i, self.num_vars, self.clauses)
            for i in range(NUM_CORES)
        ]
        print(f"Initialized {NUM_CORES} cores with {self.num_vars} vars, {len(self.clauses)} clauses")
    
    def _parse_dimacs(self, content):
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
    
    def solve(self, max_steps=100000):
        """Simulate all cores stepping in lockstep."""
        for step in range(max_steps):
            results = []
            for core in self.cores:
                result = core.step()
                results.append(result)
            
            # Check if any core finished
            for i, result in enumerate(results):
                if result is not None:
                    total_conflicts = sum(c.conflicts for c in self.cores)
                    print(f"\nCore {i} finished with {result} at step {step}")
                    print(f"Total conflicts across all cores: {total_conflicts}")
                    return result
        
        print(f"Timeout after {max_steps} steps")
        return None

# ==========================================
# Main
# ==========================================

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python mesh_sim.py <cnf_file>")
        sys.exit(1)
    
    with open(sys.argv[1], 'r') as f:
        cnf = f.read()
    
    solver = MeshSolver(cnf)
    result = solver.solve()
    print(f"\nFinal Result: {result}")
