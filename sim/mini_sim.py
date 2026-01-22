"""
Mini DPLL SAT Solver Simulation
A pure DPLL solver without learned clauses (no CAE).
Analogous to mega_sim.py but simpler - uses chronological backtracking.
"""

import sys
import logging

# ==========================================
# 0. Configuration & Debugging Support
# ==========================================


class Logger:
    """Debugging support to track state changes."""

    def __init__(self, verbose=True):
        logging.basicConfig(
            level=logging.INFO if verbose else logging.WARNING, format="%(message)s"
        )
        self.log = logging.info

    def log_step(self, module, message):
        prefix = "[hw_trace] " if module in ["PSE", "DPLL"] else ""
        self.log(f"{prefix}[{module}] {message}")


DEBUG = Logger(verbose=True)


def lit_to_str(lit):
    return "+" + str(abs(lit)) if lit > 0 else "-" + str(abs(lit))


# ==========================================
# 1. Memory System (Same as Mega)
# ==========================================


class ClauseEntry:
    """Represents a row in the Clause Entry Table."""

    def __init__(self, literals):
        self.literals = literals
        self.next1 = None
        self.next2 = None

    def __repr__(self):
        return f"Clause(Lits={self.literals})"


class MemorySystem:
    def __init__(self, num_vars):
        self.num_vars = num_vars
        self.assignments = [0] * (num_vars + 1)  # 0=undef, 1=true, -1=false
        self.trail = []
        self.trail_lim = []  # Decision level markers
        self.clause_db = []
        self.watch_heads1 = [None] * (2 * num_vars + 2)
        self.watch_heads2 = [None] * (2 * num_vars + 2)
        self.conflict_clause_idx = None

    def get_val(self, lit):
        var = abs(lit)
        sign = 1 if lit > 0 else -1
        val = self.assignments[var]
        if val == 0:
            return 0
        return 1 if val == sign else -1

    def assign(self, lit, decision_level=0):
        var = abs(lit)

        # Prevent duplicate assignments
        if self.assignments[var] != 0:
            return

        val = 1 if lit > 0 else -1
        self.assignments[var] = val
        self.trail.append(lit)
        DEBUG.log_step(
            "MEM",
            f"Assigned Literal {int(lit)} (Var {var} = {val}) @ Level {decision_level}",
        )

    def add_clause(self, literals):
        c_idx = len(self.clause_db)
        entry = ClauseEntry(literals)
        self.clause_db.append(entry)

        if len(literals) < 2:
            return c_idx

        DEBUG.log_step(
            "MEM",
            f"Adding Watch List for {literals[0]} and {literals[1]} to clause {c_idx}",
        )

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
        return (lit + self.num_vars) if lit < 0 else (lit + self.num_vars - 1)

    def get_storage_stats(self):
        total_clauses = len(self.clause_db)
        total_literals = sum(len(c.literals) for c in self.clause_db)
        max_clause_len = (
            max(len(c.literals) for c in self.clause_db) if self.clause_db else 0
        )
        return total_clauses, total_literals, max_clause_len

    def get_solution_bitstring(self):
        bits = []
        for i in range(1, self.num_vars + 1):
            val = self.assignments[i]
            if val == 1:
                bits.append("1")
            elif val == -1:
                bits.append("0")
            else:
                bits.append("0")  # Default unassigned to 0
        return "".join(bits)


# ==========================================
# 2. Propagation Search Engine (Same as Mega)
# ==========================================


class PropagationSearchEngine:
    def __init__(self, memory):
        self.mem = memory
        self.q_head = 0

    def propagate(self):
        """Core BCP loop with watched literals."""
        while self.q_head < len(self.mem.trail):
            lit = self.mem.trail[self.q_head]
            self.q_head += 1

            false_lit = -lit

            if self.process_watch_list(false_lit) == "CONFLICT":
                return "CONFLICT"

        return "NO_CONFLICT"

    def process_watch_list(self, false_lit):
        lit_idx = self.mem._lit_to_idx(false_lit)

        if self._scan_list(lit_idx, false_lit, slot=1) == "CONFLICT":
            return "CONFLICT"
        if self._scan_list(lit_idx, false_lit, slot=2) == "CONFLICT":
            return "CONFLICT"

        return "OK"

    def _scan_list(self, lit_idx, false_lit, slot):
        curr_c_idx = (
            self.mem.watch_heads1[lit_idx]
            if slot == 1
            else self.mem.watch_heads2[lit_idx]
        )

        new_head = None
        last_ptr = None

        while curr_c_idx is not None:
            clause = self.mem.clause_db[curr_c_idx]
            next_c_idx = clause.next1 if slot == 1 else clause.next2

            status = self.check_clause(curr_c_idx, false_lit, slot)

            if status == "KEEP_WATCH":
                if new_head is None:
                    new_head = curr_c_idx
                else:
                    prev_clause = self.mem.clause_db[last_ptr]
                    if slot == 1:
                        prev_clause.next1 = curr_c_idx
                    else:
                        prev_clause.next2 = curr_c_idx

                last_ptr = curr_c_idx
                if slot == 1:
                    clause.next1 = None
                else:
                    clause.next2 = None

            elif status == "MOVED_WATCH":
                pass

            elif status == "CONFLICT":
                if new_head is None:
                    new_head = curr_c_idx
                else:
                    prev_clause = self.mem.clause_db[last_ptr]
                    if slot == 1:
                        prev_clause.next1 = curr_c_idx
                    else:
                        prev_clause.next2 = curr_c_idx

                if slot == 1:
                    self.mem.watch_heads1[lit_idx] = new_head
                else:
                    self.mem.watch_heads2[lit_idx] = new_head
                return "CONFLICT"

            curr_c_idx = next_c_idx

        if slot == 1:
            self.mem.watch_heads1[lit_idx] = new_head
        else:
            self.mem.watch_heads2[lit_idx] = new_head
        return "OK"

    def check_clause(self, c_idx, false_lit, slot):
        clause = self.mem.clause_db[c_idx]
        lits = clause.literals

        w_idx = 0 if slot == 1 else 1
        o_idx = 1 if slot == 1 else 0

        # If other watched literal is True, clause is satisfied
        if self.mem.get_val(lits[o_idx]) == 1:
            return "KEEP_WATCH"

        # Look for new literal to watch
        for i in range(2, len(lits)):
            if self.mem.get_val(lits[i]) != -1:
                DEBUG.log_step(
                    "PSE",
                    f"Replaced watcher {lit_to_str(lits[w_idx])} with {lit_to_str(lits[i])} for clause {c_idx}",
                )
                lits[w_idx], lits[i] = lits[i], lits[w_idx]
                self.mem._attach_watch(lits[w_idx], c_idx, slot)
                return "MOVED_WATCH"

        # No replacement found
        if self.mem.get_val(lits[o_idx]) == -1:
            DEBUG.log_step("PSE", f"Conflict detected in Clause {c_idx}: {lits}")
            self.mem.conflict_clause_idx = c_idx
            return "CONFLICT"
        else:
            # Unit propagation
            unit = lits[o_idx]
            DEBUG.log_step("PSE", f"Propagating Unit {int(unit)} from Clause {c_idx}")
            self.mem.assign(unit, decision_level=len(self.mem.trail_lim))
            return "KEEP_WATCH"


# ==========================================
# 3. DPLL Solver (Replaces CAE + VDE)
# ==========================================


class DPLLSolver:
    """
    Pure DPLL solver with:
    - Sequential variable selection (no VSIDS)
    - Chronological backtracking (no learned clauses)
    """

    def __init__(self, cnf_content):
        self.num_vars, clauses = self.parse_dimacs(cnf_content)

        self.mem = MemorySystem(self.num_vars)
        self.pse = PropagationSearchEngine(self.mem)

        # Track decisions for backtracking
        # Each entry: (var, tried_positive, tried_negative)
        self.decisions = []
        self.decision_count = 0
        self.conflict_count = 0

        for cls in clauses:
            self.mem.add_clause(cls)

    def parse_dimacs(self, content):
        lines = content.strip().split("\n")
        clauses = []
        num_vars = 0
        for line in lines:
            line = line.strip()
            if line.startswith("p cnf"):
                parts = line.split()
                num_vars = int(parts[2])
            elif not line.startswith("c") and not line.startswith("%") and line:
                lits = [int(x) for x in line.split() if x != "0"]
                if lits:
                    clauses.append(lits)
        return num_vars, clauses

    def pick_next_var(self):
        """Sequential variable selection - pick first unassigned variable."""
        for var in range(1, self.num_vars + 1):
            if self.mem.assignments[var] == 0:
                return var
        return None

    def solve(self):
        DEBUG.log_step("SYS", "Starting DPLL Solve...")

        # Initial propagation for unit clauses
        if self.pse.propagate() == "CONFLICT":
            return "UNSAT"

        while True:
            # Pick next unassigned variable
            next_var = self.pick_next_var()

            if next_var is None:
                # All assigned, SAT!
                DEBUG.log_step("SYS", "Result: SAT")
                return "SAT"

            # Make a decision (try negative polarity first for DPLL convention)
            self.decision_count += 1
            decision_lit = -next_var

            DEBUG.log_step(
                "DPLL",
                f"Decided: {int(decision_lit)} at Level {len(self.mem.trail_lim) + 1}",
            )

            self.mem.trail_lim.append(len(self.mem.trail))
            self.decisions.append(
                (next_var, False, True)
            )  # tried_pos=False, tried_neg=True
            self.mem.assign(decision_lit, decision_level=len(self.mem.trail_lim))

            # Propagation + Backtracking loop
            while True:
                conflict_status = self.pse.propagate()

                if conflict_status == "CONFLICT":
                    self.conflict_count += 1

                    # DPLL: Chronological backtracking
                    result = self.backtrack()
                    if result == "UNSAT":
                        DEBUG.log_step("SYS", "Result: UNSAT")
                        return "UNSAT"
                    # After backtrack, continue propagation
                else:
                    # No conflict, break to make next decision
                    break

    def backtrack(self):
        """
        Chronological backtracking:
        1. If current decision hasn't tried both polarities, flip it
        2. Otherwise, backtrack to previous decision level
        """
        while self.decisions:
            var, tried_pos, tried_neg = self.decisions[-1]

            # Undo assignments back to this decision level
            limit = self.mem.trail_lim[-1]
            while len(self.mem.trail) > limit:
                lit = self.mem.trail.pop()
                self.mem.assignments[abs(lit)] = 0
            self.pse.q_head = len(self.mem.trail)

            # Try the other polarity if we haven't
            if not tried_pos:
                # We tried negative, now try positive
                self.decisions[-1] = (var, True, True)
                decision_lit = var
                DEBUG.log_step(
                    "DPLL",
                    f"Flipping decision to {int(decision_lit)} at Level {len(self.mem.trail_lim)}",
                )
                self.mem.assign(decision_lit, decision_level=len(self.mem.trail_lim))
                return "CONTINUE"
            elif not tried_neg:
                # We tried positive, now try negative
                self.decisions[-1] = (var, True, True)
                decision_lit = -var
                DEBUG.log_step(
                    "DPLL",
                    f"Flipping decision to {int(decision_lit)} at Level {len(self.mem.trail_lim)}",
                )
                self.mem.assign(decision_lit, decision_level=len(self.mem.trail_lim))
                return "CONTINUE"
            else:
                # Both polarities failed, backtrack one more level
                DEBUG.log_step(
                    "DPLL",
                    f"Both polarities exhausted for Var {var}, backtracking further",
                )
                self.decisions.pop()
                self.mem.trail_lim.pop()

        # Exhausted all possibilities
        return "UNSAT"


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
        with open(sys.argv[1], "r") as f:
            cnf_content = f.read()
    solver = DPLLSolver(cnf_content)
    result = solver.solve()
    print(f"\nFinal Result: {result}")

    # Storage Stats
    total_clauses, total_lits, max_len = solver.mem.get_storage_stats()
    print(f"Total Clauses in Storage:  {total_clauses}")
    print(f"Total Literals in Storage: {total_lits}")
    print(f"Max Clause Length:         {max_len}")
    print(f"Total Conflicts:           {solver.conflict_count}")
    print(f"Total Decisions:           {solver.decision_count}")

    if result == "SAT":
        sol_bits = solver.mem.get_solution_bitstring()
        print(f"Solution: {sol_bits}")

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
                print(
                    f"[VALIDATION] Unsatisfied clause found: {cls.literals} Vals: {vals}"
                )
                all_sat = False

        if all_sat:
            print("[VALIDATION] All clauses satisfied.")
