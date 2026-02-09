#!/usr/bin/env python3
"""
Mesh Mini Simulator
Implements a work-stealing architecture on a 2x2 mesh.
Uses a simplified "Mini" DPLL solver.
"""

import sys
import logging
from copy import deepcopy

# ==========================================
# Configuration
# ==========================================

GRID_X = 2
GRID_Y = 2
NUM_CORES = GRID_X * GRID_Y
VERBOSE = True

logging.basicConfig(
    level=logging.INFO if VERBOSE else logging.WARNING, format="[%(name)s] %(message)s"
)


class Logger:
    def __init__(self, name):
        self.logger = logging.getLogger(name)

    def log(self, msg):
        self.logger.info(msg)


DEBUG = Logger("MESH")

# ==========================================
# Core Dictionary / Constants
# ==========================================
# Status codes for the Steppable Solver
STATUS_READY = "READY"
STATUS_RUNNING = "RUNNING"
STATUS_DECISION_NEEDED = "DECISION_NEEDED"
STATUS_SAT = "SAT"
STATUS_UNSAT = "UNSAT"
STATUS_IDLE = "IDLE"
STATUS_RECEIVING = "RECEIVING"  # Receiving trail stream from neighbor

# ==========================================
# Memory & Logic (Copied/Adapted from mini_sim.py)
# ==========================================


class ClauseEntry:
    def __init__(self, literals):
        self.literals = literals
        self.next1 = None
        self.next2 = None

    def __repr__(self):
        return f"Clause(Lits={self.literals})"


class MemorySystem:
    def __init__(self, num_vars):
        self.num_vars = num_vars
        self.assignments = [0] * (num_vars + 1)
        self.trail = []
        self.trail_lim = []
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
        if self.assignments[var] != 0:
            return
        val = 1 if lit > 0 else -1
        self.assignments[var] = val
        self.trail.append(lit)

    def add_clause(self, literals):
        c_idx = len(self.clause_db)
        entry = ClauseEntry(list(literals))  # Ensure copy
        self.clause_db.append(entry)
        if len(literals) < 2:
            return c_idx
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

    def get_solution_bitstring(self):
        bits = []
        for i in range(1, self.num_vars + 1):
            val = self.assignments[i]
            bits.append("1" if val == 1 else "0")
        return "".join(bits)


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
        if self._scan_list(lit_idx, false_lit, slot=1) == "CONFLICT":
            return "CONFLICT"
        if self._scan_list(lit_idx, false_lit, slot=2) == "CONFLICT":
            return "CONFLICT"
        return "OK"

    def _scan_list(self, lit_idx, false_lit, slot):
        # Scan code adapted from mini_sim.py
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
                    prev = self.mem.clause_db[last_ptr]
                    if slot == 1:
                        prev.next1 = curr_c_idx
                    else:
                        prev.next2 = curr_c_idx
                last_ptr = curr_c_idx
                if slot == 1:
                    clause.next1 = None
                else:
                    clause.next2 = None
            elif status == "CONFLICT":
                # Restore link for traversal correctness/recovery if needed, but mainly return
                if new_head is None:
                    new_head = curr_c_idx
                else:
                    prev = self.mem.clause_db[last_ptr]
                    if slot == 1:
                        prev.next1 = curr_c_idx
                    else:
                        prev.next2 = curr_c_idx

                # Update head before returning
                if slot == 1:
                    self.mem.watch_heads1[lit_idx] = new_head
                else:
                    self.mem.watch_heads2[lit_idx] = new_head
                return "CONFLICT"
            # MOVED_WATCH does nothing here (removed from this list)

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

        if self.mem.get_val(lits[o_idx]) == 1:
            return "KEEP_WATCH"

        for i in range(2, len(lits)):
            if self.mem.get_val(lits[i]) != -1:
                lits[w_idx], lits[i] = lits[i], lits[w_idx]
                self.mem._attach_watch(lits[w_idx], c_idx, slot)
                return "MOVED_WATCH"

        if self.mem.get_val(lits[o_idx]) == -1:
            self.mem.conflict_clause_idx = c_idx
            return "CONFLICT"
        else:
            self.mem.assign(lits[o_idx], decision_level=len(self.mem.trail_lim))
            return "KEEP_WATCH"


# ==========================================
# Steppable Solver
# ==========================================


class SteppableDPLLSolver:
    def __init__(self, core_id, num_vars=0, clauses=None):
        self.core_id = core_id
        if clauses is not None:
            self.init(num_vars, clauses)
        else:
            self.status = STATUS_IDLE

    def init(self, num_vars, clauses):
        self.num_vars = num_vars
        self.mem = MemorySystem(num_vars)
        self.pse = PropagationSearchEngine(self.mem)
        self.clauses = clauses
        for cls in clauses:
            self.mem.add_clause(cls)

        self.decisions = []  # Stack of (var, tried_pos, tried_neg)
        self.decision_count = 0
        self.conflict_count = 0
        self.status = STATUS_READY

    def step(self):
        """Execute one 'step' of logic. Returns current status."""
        if self.status == STATUS_IDLE:
            return STATUS_IDLE

        if self.status == STATUS_READY:
            # Initial Propagate
            if self.pse.propagate() == "CONFLICT":
                self.status = STATUS_UNSAT
            else:
                self.status = STATUS_DECISION_NEEDED
            return self.status

        if self.status == STATUS_RUNNING:
            # We are here because we did a decision or backtrack.
            # Propagate.
            status = self.pse.propagate()
            if status == "CONFLICT":
                self.conflict_count += 1
                backtrack_res = self.backtrack()
                if backtrack_res == "UNSAT":
                    self.status = STATUS_UNSAT
                else:
                    self.status = STATUS_RUNNING  # Continue propagating after backtrack
            else:
                # Stable
                if len(self.mem.trail) == self.num_vars:
                    # All assigned? Check or just assume SAT if stable and all vars assigned?
                    # Wait, unassigned vars might remain.
                    next_var = self.pick_next_var()
                    if next_var is None:
                        self.status = STATUS_SAT
                    else:
                        self.status = STATUS_DECISION_NEEDED
                else:
                    self.status = STATUS_DECISION_NEEDED
            return self.status

        return self.status

    def pick_next_var(self):
        for var in range(1, self.num_vars + 1):
            if self.mem.assignments[var] == 0:
                return var
        return None

    def decide(self, lit, forked=False):
        """Force a decision."""
        # forked=True means we are taking a branch that was stolen/assigned,
        # so we effectively say we 'tried' the other one (or it's handled elsewhere).

        var = abs(lit)
        self.decision_count += 1
        self.mem.trail_lim.append(len(self.mem.trail))

        # If normal decision: try 'lit', other polarity is untried.
        # If forked (work stealing): we are taking 'lit', but we act as if
        # the *other* polarity is already 'done' (handled by neighbor).
        # So we mark both as tried.

        tried_pos = lit > 0
        tried_neg = lit < 0

        if forked:
            # Mark BOTH as tried so we don't flip to the other side on backtrack
            dec_entry = (var, True, True)
        else:
            dec_entry = (var, tried_pos, tried_neg)

        self.decisions.append(dec_entry)
        self.mem.assign(lit, decision_level=len(self.mem.trail_lim))
        self.pse.q_head = len(self.mem.trail) - 1  # Ensure propagated
        self.status = STATUS_RUNNING

    def backtrack(self):
        while self.decisions:
            var, tried_pos, tried_neg = self.decisions[-1]

            # Undo
            limit = self.mem.trail_lim[-1]
            while len(self.mem.trail) > limit:
                l = self.mem.trail.pop()
                self.mem.assignments[abs(l)] = 0
            self.pse.q_head = len(self.mem.trail)

            # Check options
            if not tried_pos:
                # Try positive
                self.decisions[-1] = (var, True, True)
                self.mem.assign(var, decision_level=len(self.mem.trail_lim))
                DEBUG.log(f"Core {self.core_id} Flipping to +{var}")
                return "CONTINUE"
            elif not tried_neg:
                # Try negative
                self.decisions[-1] = (var, True, True)
                self.mem.assign(-var, decision_level=len(self.mem.trail_lim))
                DEBUG.log(f"Core {self.core_id} Flipping to -{var}")
                return "CONTINUE"
            else:
                # Backtrack further
                self.decisions.pop()
                self.mem.trail_lim.pop()

        return "UNSAT"

    def clone_from(self, source_solver):
        """Deep copy state from source_solver. (Legacy - Full Snapshot)"""
        self.num_vars = source_solver.num_vars
        self.mem = deepcopy(source_solver.mem)
        self.pse = PropagationSearchEngine(self.mem)
        self.decisions = deepcopy(source_solver.decisions)
        self.decision_count = source_solver.decision_count
        self.conflict_count = 0
        self.clauses = source_solver.clauses
        self.status = STATUS_RUNNING

    # ==========================================
    # Assignment-Only Fork (Simplified Model)
    # ==========================================
    # Prior assignments become Level 0 AXIOMS.
    # New core only backtracks within its OWN decisions.
    # If it exhausts its search space -> IDLE (subtree UNSAT).

    def init_from_assignments(self, num_vars, clauses, assignment_bits, fork_decision):
        """
        Initialize core from assignment bits + a single decision.

        Args:
            num_vars: Number of variables
            clauses: Reference to SHARED clause database
            assignment_bits: List of N values (1=True, -1=False, 0=Unassigned)
            fork_decision: The literal this core should explore (e.g., -var for x=False)

        All prior assignments are treated as Level 0 AXIOMS.
        This core cannot backtrack past them.
        """
        self.num_vars = num_vars
        self.clauses = clauses

        # Fresh memory
        self.mem = MemorySystem(num_vars)

        # Add clauses (rebuilds initial watch pointers)
        for cls in clauses:
            self.mem.add_clause(cls)

        self.pse = PropagationSearchEngine(self.mem)

        # Apply prior assignments as Level 0 AXIOMS
        # These are "given" - no backtracking past them
        for var in range(1, num_vars + 1):
            val = assignment_bits[var]
            if val == 1:
                self.mem.assign(var, decision_level=0)
            elif val == -1:
                self.mem.assign(-var, decision_level=0)

        # Run BCP to update watch pointers for the given assignments
        self.pse.propagate()
        self.pse.q_head = len(self.mem.trail)

        # Fresh decision stack - only tracks THIS core's decisions
        self.decisions = []
        self.decision_count = 0
        self.conflict_count = 0

        # Make the fork decision as Level 1 (this core's first decision)
        self.mem.trail_lim.append(len(self.mem.trail))
        self.decisions.append(
            (abs(fork_decision), True, True)
        )  # Both polarities "tried" to prevent flip
        self.mem.assign(fork_decision, decision_level=1)
        self.decision_count = 1

        self.status = STATUS_RUNNING

        DEBUG.log(
            f"Core {self.core_id} initialized from {sum(1 for v in assignment_bits[1:] if v != 0)} axioms + decision {fork_decision}"
        )


# ==========================================
# Mesh Solver
# ==========================================


class MeshSolver:
    def __init__(self, cnf_content):
        self.num_vars, self.clauses = self._parse_dimacs(cnf_content)
        self.cores = []
        for i in range(NUM_CORES):
            if i == 0:
                self.cores.append(SteppableDPLLSolver(i, self.num_vars, self.clauses))
            else:
                s = SteppableDPLLSolver(i)
                s.status = STATUS_IDLE
                self.cores.append(s)

    def _parse_dimacs(self, content):
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

    def get_neighbors(self, idx):
        # 2x2 Grid:
        # 0 1
        # 2 3
        x = idx % GRID_X
        y = idx // GRID_X
        neighs = []

        # Up
        if y > 0:
            neighs.append((y - 1) * GRID_X + x)
        # Down
        if y < GRID_Y - 1:
            neighs.append((y + 1) * GRID_X + x)
        # Left
        if x > 0:
            neighs.append(y * GRID_X + (x - 1))
        # Right
        if x < GRID_X - 1:
            neighs.append(y * GRID_X + (x + 1))

        return neighs

    def solve(self, max_cycles=100000):
        print(f"Starting Mesh Solve with {NUM_CORES} cores...")
        print(f"Using ASSIGNMENT-ONLY fork (prior assignments = Level 0 axioms)")

        for cycle in range(max_cycles):
            active_count = 0

            # 1. Step all cores
            for i, core in enumerate(self.cores):
                if (
                    core.status != STATUS_IDLE
                    and core.status != STATUS_SAT
                    and core.status != STATUS_UNSAT
                ):
                    active_count += 1
                    res = core.step()
                    if res == STATUS_SAT:
                        print(f"SAT found by Core {i} at cycle {cycle}!")
                        return "SAT", core.mem.get_solution_bitstring()

            if active_count == 0:
                # All idle or UNSAT
                return "UNSAT", None

            # 2. Handle Decisions & Work Stealing
            current_statuses = [c.status for c in self.cores]

            for i, core in enumerate(self.cores):
                if current_statuses[i] == STATUS_DECISION_NEEDED:
                    var = self.cores[i].pick_next_var()
                    if var is None:
                        print(f"SAT found by Core {i} (late check)!")
                        return "SAT", self.cores[i].mem.get_solution_bitstring()

                    # Check neighbors for IDLE
                    neighbors = self.get_neighbors(i)
                    target_neighbor = None
                    for n_idx in neighbors:
                        if self.cores[n_idx].status == STATUS_IDLE:
                            target_neighbor = n_idx
                            break

                    if target_neighbor is not None:
                        # WORK STEALING with ASSIGNMENT-ONLY fork!
                        DEBUG.log(
                            f"Core {i} forking to Core {target_neighbor}: {sum(1 for v in core.mem.assignments[1:] if v != 0)} bits + decision -{var}"
                        )

                        # Initialize neighbor from current assignments
                        neighbor = self.cores[target_neighbor]
                        neighbor.init_from_assignments(
                            core.num_vars,
                            core.clauses,  # Shared clause reference
                            core.mem.assignments,  # N bits of assignment state
                            -var,  # Fork decision (neighbor explores x=False)
                        )

                        # Current Core takes +var
                        core.decide(var, forked=True)

                    else:
                        # No neighbor, standard decision
                        core.decide(-var, forked=False)

        print("Timeout.")
        return "TIMEOUT", None


# ==========================================
# Main
# ==========================================

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ./mesh_mini_sim.py <cnf_file>")
        # Create a dummy test if no file
        print("Running internal simple test...")
        cnf = """p cnf 4 4
1 2 0
-1 -2 0
3 4 0
-3 -4 0"""
    else:
        with open(sys.argv[1], "r") as f:
            cnf = f.read()

    solver = MeshSolver(cnf)
    res, bits = solver.solve()
    print(f"FINAL RESULT: {res}")
    if bits:
        print(f"BITS: {bits}")
