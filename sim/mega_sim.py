import sys
import heapq
import logging

# ==========================================
# 0. Configuration & Debugging Support
# ==========================================

class Logger:
    """
    Extensive debugging support to track hardware state changes.
    """
    def __init__(self, verbose=True):
        logging.basicConfig(
            level=logging.INFO if verbose else logging.WARNING,

            format='%(message)s'
        )
        self.log = logging.info

    def log_step(self, module, message):
        prefix = "[hw_trace] " if module in ["VDE", "PSE", "CAE"] else ""
        self.log(f"{prefix}[{module}] {message}")

DEBUG = Logger(verbose=True)

def lit_to_str(lit):
    return '+' + str(abs(lit)) if lit > 0 else '-' + str(abs(lit))

# ==========================================
# 1. Hardware-Optimized Memory Scheme
# ==========================================

class ClauseEntry:
    """
    Represents a row in the Clause Entry Table.
    """
    def __init__(self, literals, lbd=0):
        self.literals = literals  
        self.lbd = lbd            
        self.literals = literals  
        self.lbd = lbd            
        self.next1 = None
        self.next2 = None   
        self.cached_wlit = None   
        self.is_learned = False

    def __repr__(self):
        return f"Clause(Lits={self.literals})"

class MemorySystem:
    def __init__(self, num_vars):
        self.num_vars = num_vars
        self.assignments = [0] * (num_vars + 1) 
        self.phases = [0] * (num_vars + 1)
        self.trail = []                 
        self.trail_lim = []             
        self.reason = [None] * (num_vars + 1) 
        self.level = [-1] * (num_vars + 1)    
        self.clause_db = [] 
        self.watch_heads1 = [None] * (2 * num_vars + 2) 
        self.watch_heads2 = [None] * (2 * num_vars + 2)
        self.conflict_clause_idx = None

    def get_val(self, lit):
        var = abs(lit)
        sign = 1 if lit > 0 else -1
        val = self.assignments[var]
        if val == 0: return 0
        return 1 if val == sign else -1

    def assign(self, lit, reason_clause_idx=None, decision_level=0):
        var = abs(lit)
        
        # [CRITICAL FIX] Prevent duplicate assignments/infinite trail loops
        if self.assignments[var] != 0:
            return

        val = 1 if lit > 0 else -1
        self.assignments[var] = val
        self.level[var] = decision_level
        self.reason[var] = reason_clause_idx
        self.phases[var] = 1 if lit > 0 else 0
        self.trail.append(lit)
        val_str = lit_to_str(lit)
        DEBUG.log_step("MEM", f"Assigned Literal {int(lit)} (Var {var} = {val}) @ Level {decision_level}")

    def add_clause(self, literals, is_learned=False):
        c_idx = len(self.clause_db)
        entry = ClauseEntry(literals)
        entry.is_learned = is_learned
        self.clause_db.append(entry)

        if len(literals) < 2: return c_idx 

        DEBUG.log_step("MEM", f"Adding Watch List for {literals[0]} and {literals[1]} to clause {c_idx}")

        self._attach_watch(literals[0], c_idx, slot=1)
        self._attach_watch(literals[1], c_idx, slot=2)
        return c_idx

    def _attach_watch(self, lit, c_idx, slot):
        lit_idx = self._lit_to_idx(lit)
        if slot == 1:
            old_head = self.watch_heads1[lit_idx]
            self.clause_db[c_idx].next1 = old_head 
            self.watch_heads1[lit_idx] = c_idx
        else:
            old_head = self.watch_heads2[lit_idx]
            self.clause_db[c_idx].next2 = old_head 
            self.watch_heads2[lit_idx] = c_idx

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
        """
        Core BCP loop. 
        """
        while self.q_head < len(self.mem.trail):
            lit = self.mem.trail[self.q_head]
            self.q_head += 1
            
            # Lit is True, so -lit became False. Trigger watchers of -lit.
            false_lit = -lit 
            
            if self.process_watch_list(false_lit) == "CONFLICT":
                return "CONFLICT"
        
        return "NO_CONFLICT"

    def process_watch_list(self, false_lit):
        lit_idx = self.mem._lit_to_idx(false_lit)
        
        # Scan List 1 (Slot 0 watchers)
        if self._scan_list(lit_idx, false_lit, slot=1) == "CONFLICT": return "CONFLICT"
        
        # Scan List 2 (Slot 1 watchers)
        if self._scan_list(lit_idx, false_lit, slot=2) == "CONFLICT": return "CONFLICT"
        
        return "OK"

    def _scan_list(self, lit_idx, false_lit, slot):
        curr_c_idx = self.mem.watch_heads1[lit_idx] if slot == 1 else self.mem.watch_heads2[lit_idx]
        
        new_head = None
        last_ptr = None
        
        while curr_c_idx is not None:
            clause = self.mem.clause_db[curr_c_idx]
            
            # Retrieve next before modification
            next_c_idx = clause.next1 if slot == 1 else clause.next2

            status = self.check_clause(curr_c_idx, false_lit, slot)
            
            if status == "KEEP_WATCH":
                # Keep in current list
                if new_head is None: new_head = curr_c_idx
                else: 
                     prev_clause = self.mem.clause_db[last_ptr]
                     if slot == 1: prev_clause.next1 = curr_c_idx
                     else: prev_clause.next2 = curr_c_idx
                
                last_ptr = curr_c_idx
                # Terminate for now
                if slot == 1: clause.next1 = None
                else: clause.next2 = None
                
            elif status == "MOVED_WATCH":
                # Clause moved to another list. 
                pass
            
            elif status == "CONFLICT":
                # Repair list tail roughly and abort
                if new_head is None: 
                    if slot == 1: self.mem.watch_heads1[lit_idx] = curr_c_idx
                    else: self.mem.watch_heads2[lit_idx] = curr_c_idx
                else:
                    prev_clause = self.mem.clause_db[last_ptr]
                    if slot == 1: prev_clause.next1 = curr_c_idx
                    else: prev_clause.next2 = curr_c_idx
                return "CONFLICT"
                
            curr_c_idx = next_c_idx

        # Update Head
        if slot == 1: self.mem.watch_heads1[lit_idx] = new_head
        else: self.mem.watch_heads2[lit_idx] = new_head
        return "OK"

    def check_clause(self, c_idx, false_lit, slot):
        clause = self.mem.clause_db[c_idx]
        lits = clause.literals
        
        # Identify slots
        w_idx = 0 if slot == 1 else 1
        o_idx = 1 if slot == 1 else 0
        
        # lits[w_idx] should be the false_lit (or something we are asked to replace)
        # lits[o_idx] is the other watched literal
        
        # 1. If other watched literal is True, clause is satisfied.
        if self.mem.get_val(lits[o_idx]) == 1:
            return "KEEP_WATCH" 
            
        # 2. Look for new literal to watch (non-False)
        for i in range(2, len(lits)):
            if self.mem.get_val(lits[i]) != -1:
                DEBUG.log_step("PSE", f"Replaced watcher {lit_to_str(lits[w_idx])} with {lit_to_str(lits[i])} for clause {c_idx}")
                # Found replacement
                lits[w_idx], lits[i] = lits[i], lits[w_idx]
                
                # Add to new list (maintain slot!)
                self.mem._attach_watch(lits[w_idx], c_idx, slot) 
                return "MOVED_WATCH"
        
        # 3. No replacement found.
        # If lits[o_idx] is False, it's a CONFLICT
        if self.mem.get_val(lits[o_idx]) == -1:
            # Format conflict dump to match HW: [other, current, rest...] or whatever HW prints
            # HW prints conflict clause. 
            DEBUG.log_step("PSE", f"Conflict detected in Clause {c_idx}: {lits}")
            self.mem.conflict_clause_idx = c_idx
            return "CONFLICT"
        else:
            # lits[o_idx] is Undef -> UNIT PROPAGATION
            unit = lits[o_idx]
            lit_str = lit_to_str(unit)
            DEBUG.log_step("PSE", f"Propagating Unit {int(unit)} from Clause {c_idx}")
            self.mem.assign(unit, c_idx, decision_level=len(self.mem.trail_lim))
            return "KEEP_WATCH"

# ==========================================
# 3. Conflict Analysis Engine (CAE)
# ==========================================

class ConflictAnalysisEngine:
    def __init__(self, memory, decision_engine):
        self.mem = memory
        self.vde = decision_engine
        self.conflict_count = 0

    def analyze(self, conflict_c_idx):
        DEBUG.log_step("CAE", f"Analyzing Conflict {conflict_c_idx}")
        self.conflict_count += 1
        curr_level = len(self.mem.trail_lim)
        if curr_level == 0: 
            DEBUG.log_step("CAE", "Conflict at current decision level 0, UNSAT")
            return None, -1 
        
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
            
            # Find next literal to resolve
            while True:
                if index < 0: break 
                p = self.mem.trail[index]
                index -= 1
                if abs(p) in seen: break
            
            path_c -= 1
            # [CRITICAL FIX] Ensure strict 1-UIP termination
            if path_c <= 0: break 
            
            if abs(p) not in seen: break # Should not happen if logic is correct
            
            reason_idx = self.mem.reason[abs(p)]
            if reason_idx is None: break # Should not happen unless decision var is reached incorrectly

            clause_to_resolve = [l for l in self.mem.clause_db[reason_idx].literals if abs(l) != abs(p)]

        learned.insert(0, -p) # Negate UIP
        
        if len(learned) == 1:
            bt_level = 0
        else:
            levels = [self.mem.level[abs(l)] if self.mem.level[abs(l)] != -1 else 0 for l in learned[1:]]
            bt_level = max(levels) if levels else 0
        
        # Note: Assignments happen after this function returns in solve(), so we log what we *will* assign
        for lit in learned: self.vde.bump_activity(abs(lit))
        self.vde.decay_activities()

        return learned, bt_level
# ==========================================
# 4. Variable Decision Engine (VDE)
# ==========================================
class VariableDecisionEngine:
    DECAY_FACTOR = 0.9275
    ACTIVITY_INCR = 1.0

    def __init__(self, memory, num_vars):
        self.mem = memory
        self.activity = [0.0] * (num_vars + 1)
        self.queue = []
        self.decision_count = 0

        for i in range(1, num_vars + 1):
            heapq.heappush(self.queue, (-self.activity[i], i))

    def bump_activity(self, var):
        self.activity[var] += self.ACTIVITY_INCR
        DEBUG.log_step("VDE", f"Bumping activity for variable {var} to {self.activity[var]}")
        if self.activity[var] > 1e100:
            DEBUG.log_step("VDE", "Activity overflow detected, normalizing...")
            for i in range(len(self.activity)):
                self.activity[i] *= 1e-100
            self.ACTIVITY_INCR *= 1e-100

    def decay_activities(self):
        self.ACTIVITY_INCR *= (1 / self.DECAY_FACTOR)

    def decide(self):
        self.decision_count += 1
        while self.queue:
            _, var = heapq.heappop(self.queue)
            if self.mem.assignments[var] == 0:
                lit = -var if self.mem.phases[var] == 0 else var
                lit_str = lit_to_str(lit)
                # Simple static polarity (negative) for stability
                # DEBUG.log_step("VDE", f"Deciding on {lit_str}, activity {self.activity[var]}")
                return lit
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
        DEBUG.log_step("SYS", "Starting VeriSAT Solve...")
        
        # Initial propagation (for level 0 unit clauses)
        if self.pse.propagate() == "CONFLICT":
            return "UNSAT"

        while True:
            # 1. Decision (VDE)
            next_lit = self.vde.decide()
            if next_lit is not None:
                 DEBUG.log_step("VDE", f"Decided: {int(next_lit)} at Level {len(self.mem.trail_lim) + 1}")

            if next_lit is None:
                # All variables assigned?
                # Double check if any are unassigned
                if any(x == 0 for x in self.mem.assignments[1:]):
                     # This usually means variables were not picked. 
                     # Re-scan for unassigned
                     pass
                
                DEBUG.log_step("SYS", f"Result: SAT")
                return "SAT"
            
            self.mem.trail_lim.append(len(self.mem.trail))
            self.mem.assign(next_lit, reason_clause_idx=None, decision_level=len(self.mem.trail_lim))


            # 2. Propagation Loop
            force_conflict = False
            while True:
                if not force_conflict:
                    conflict_status = self.pse.propagate()
                else:
                    conflict_status = "CONFLICT"
                    force_conflict = False
                
                if conflict_status == "CONFLICT":
                    learned_clause, bt_level = self.cae.analyze(self.mem.conflict_clause_idx)
                    
                    if bt_level == -1:
                        DEBUG.log_step("SYS", "Result: UNSAT")
                        return "UNSAT"
                    
                    self.backtrack(bt_level)
                    uip_lit = lit_to_str(learned_clause[0])
                    trail_len = len(self.mem.trail)
                    DEBUG.log_step("CAE", f"Learned Clause: {learned_clause}, Backtrack to: {bt_level}, Trail Height: {trail_len}")

                    
                    # Add learned clause
                    c_idx = self.mem.add_clause(learned_clause, is_learned=True)
                    
                    # Assign driving literal
                    lit = learned_clause[0]
                    self.mem.assign(lit, c_idx, decision_level=bt_level)
                    
                    # [FIX] Check for immediate conflict if assignment failed
                    if self.mem.get_val(lit) == -1:
                        DEBUG.log_step("SYS", f"Immediate conflict after backtrack on {lit}")
                        self.mem.conflict_clause_idx = c_idx
                        force_conflict = True
                        continue

                    self.pse.q_head = len(self.mem.trail) - 1
                    # Loop back to propagate this new assignment immediately
                else:
                    # No conflict, break to Decision
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
                # Add back to heap to be picked again
                heapq.heappush(self.vde.queue, (-self.vde.activity[var], var))
        self.pse.q_head = len(self.mem.trail)

# ==========================================
# Execution with Provided CNF
# ==========================================

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

if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            cnf_content = f.read()
    solver = VeriSAT(cnf_content)
    result = solver.solve()
    print(f"\nFinal Result: {result}")
    
    if result == "SAT":
        # Validation
        print("\n[VALIDATION] Checking clauses...")
        all_sat = True
        for cls in solver.mem.clause_db:
            sat = False
            vals = []
            for lit in cls.literals:
                val = solver.mem.get_val(lit)
                vals.append(val)
                if val == 1:
                    sat = True
                    break
            if not sat:
                print(f"[VALIDATION] Unsatisfied clause found: {cls.literals} Vals: {vals}")
                all_sat = False
        
        if all_sat:
            print("[VALIDATION] All clauses satisfied.")
        else:
             # This should ideally not happen if logic is correct
             pass