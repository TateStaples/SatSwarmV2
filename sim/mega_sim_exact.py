#!/usr/bin/env python3
import argparse
import heapq
import json
from dataclasses import dataclass
from typing import List, Optional


class TraceLogger:
    def __init__(self, verbose: bool):
        self.verbose = verbose
        self.decisions = []
        self.watch_moves = []
        self.learned_clauses = []

    def emit(self, module: str, msg: str):
        if self.verbose:
            print(f"[mega_sim_exact] [{module}] {msg}")


@dataclass
class ClauseEntry:
    literals: List[int]
    lbd: int = 0
    next1: Optional[int] = None
    next2: Optional[int] = None
    is_learned: bool = False


class MemorySystem:
    def __init__(self, num_vars: int, trace: TraceLogger):
        self.num_vars = num_vars
        self.trace = trace
        self.assignments = [0] * (num_vars + 1)
        self.phases = [0] * (num_vars + 1)
        self.trail: List[int] = []
        self.trail_lim: List[int] = []
        self.reason = [None] * (num_vars + 1)
        self.level = [-1] * (num_vars + 1)
        self.clause_db: List[ClauseEntry] = []
        self.watch_heads1 = [None] * (2 * num_vars + 2)
        self.watch_heads2 = [None] * (2 * num_vars + 2)
        self.conflict_clause_idx: Optional[int] = None

    def lit_to_idx(self, lit: int) -> int:
        return (lit + self.num_vars) if lit < 0 else (lit + self.num_vars - 1)

    def get_val(self, lit: int) -> int:
        var = abs(lit)
        sign = 1 if lit > 0 else -1
        val = self.assignments[var]
        if val == 0:
            return 0
        return 1 if val == sign else -1

    def assign(self, lit: int, reason_clause_idx: Optional[int], decision_level: int) -> bool:
        var = abs(lit)
        target = 1 if lit > 0 else -1
        if self.assignments[var] != 0:
            return self.assignments[var] == target
        self.assignments[var] = target
        self.level[var] = decision_level
        self.reason[var] = reason_clause_idx
        self.phases[var] = 1 if lit > 0 else 0
        self.trail.append(lit)
        self.trace.emit("MEM", f"Assigned Literal {lit} @ Level {decision_level}")
        return True

    def add_clause(self, literals: List[int], is_learned: bool = False) -> int:
        idx = len(self.clause_db)
        entry = ClauseEntry(list(literals), is_learned=is_learned)
        self.clause_db.append(entry)
        if len(literals) >= 2:
            self.attach_watch(literals[0], idx, slot=1)
            self.attach_watch(literals[1], idx, slot=2)
        return idx

    def attach_watch(self, lit: int, c_idx: int, slot: int):
        lit_idx = self.lit_to_idx(lit)
        if slot == 1:
            old_head = self.watch_heads1[lit_idx]
            self.clause_db[c_idx].next1 = old_head
            self.watch_heads1[lit_idx] = c_idx
        else:
            old_head = self.watch_heads2[lit_idx]
            self.clause_db[c_idx].next2 = old_head
            self.watch_heads2[lit_idx] = c_idx


class VariableDecisionEngine:
    DECAY_FACTOR = 0.9275

    def __init__(self, mem: MemorySystem):
        self.mem = mem
        self.activity = [0.0] * (mem.num_vars + 1)
        self.act_incr = 1.0
        self.version = [0] * (mem.num_vars + 1)
        self.heap = []
        for var in range(1, mem.num_vars + 1):
            heapq.heappush(self.heap, (-self.activity[var], var, self.version[var]))

    def _push_var(self, var: int):
        self.version[var] += 1
        heapq.heappush(self.heap, (-self.activity[var], var, self.version[var]))

    def bump_activity(self, var: int):
        self.activity[var] += self.act_incr
        if self.activity[var] > 1e100:
            for i in range(len(self.activity)):
                self.activity[i] *= 1e-100
            self.act_incr *= 1e-100
        self._push_var(var)

    def decay_activities(self):
        self.act_incr *= (1 / self.DECAY_FACTOR)

    def on_unassign(self, var: int):
        self._push_var(var)

    def decide(self) -> Optional[int]:
        while self.heap:
            neg_score, var, ver = heapq.heappop(self.heap)
            if ver != self.version[var]:
                continue
            if self.mem.assignments[var] != 0:
                continue
            if -neg_score != self.activity[var]:
                continue
            return var if self.mem.phases[var] == 1 else -var
        return None


class PropagationSearchEngine:
    def __init__(self, mem: MemorySystem, trace: TraceLogger):
        self.mem = mem
        self.trace = trace
        self.q_head = 0

    def propagate(self) -> str:
        while self.q_head < len(self.mem.trail):
            lit = self.mem.trail[self.q_head]
            self.q_head += 1
            if self._process_watch_list(-lit) == "CONFLICT":
                return "CONFLICT"
        return "NO_CONFLICT"

    def _process_watch_list(self, false_lit: int) -> str:
        lit_idx = self.mem.lit_to_idx(false_lit)
        if self._scan_list(lit_idx, false_lit, slot=1) == "CONFLICT":
            return "CONFLICT"
        if self._scan_list(lit_idx, false_lit, slot=2) == "CONFLICT":
            return "CONFLICT"
        return "OK"

    def _scan_list(self, lit_idx: int, false_lit: int, slot: int) -> str:
        curr = self.mem.watch_heads1[lit_idx] if slot == 1 else self.mem.watch_heads2[lit_idx]
        new_head = None
        last = None

        while curr is not None:
            clause = self.mem.clause_db[curr]
            nxt = clause.next1 if slot == 1 else clause.next2
            status = self._check_clause(curr, false_lit, slot)

            if status == "KEEP_WATCH":
                if new_head is None:
                    new_head = curr
                else:
                    prev = self.mem.clause_db[last]
                    if slot == 1:
                        prev.next1 = curr
                    else:
                        prev.next2 = curr
                last = curr
                if slot == 1:
                    clause.next1 = None
                else:
                    clause.next2 = None
            elif status == "CONFLICT":
                if new_head is None:
                    new_head = curr
                else:
                    prev = self.mem.clause_db[last]
                    if slot == 1:
                        prev.next1 = curr
                    else:
                        prev.next2 = curr
                if slot == 1:
                    self.mem.watch_heads1[lit_idx] = new_head
                else:
                    self.mem.watch_heads2[lit_idx] = new_head
                return "CONFLICT"

            curr = nxt

        if slot == 1:
            self.mem.watch_heads1[lit_idx] = new_head
        else:
            self.mem.watch_heads2[lit_idx] = new_head
        return "OK"

    def _check_clause(self, c_idx: int, false_lit: int, slot: int) -> str:
        clause = self.mem.clause_db[c_idx]
        lits = clause.literals
        w_idx = 0 if slot == 1 else 1
        o_idx = 1 if slot == 1 else 0

        if self.mem.get_val(lits[o_idx]) == 1:
            return "KEEP_WATCH"

        for i in range(2, len(lits)):
            if self.mem.get_val(lits[i]) != -1:
                old_lit = lits[w_idx]
                new_lit = lits[i]
                lits[w_idx], lits[i] = lits[i], lits[w_idx]
                self.mem.attach_watch(lits[w_idx], c_idx, slot)
                self.trace.watch_moves.append({
                    "clause": c_idx,
                    "slot": slot,
                    "from": old_lit,
                    "to": new_lit,
                })
                self.trace.emit("PSE", f"Watch move c{c_idx} slot{slot}: {old_lit} -> {new_lit}")
                return "MOVED_WATCH"

        if self.mem.get_val(lits[o_idx]) == -1:
            self.mem.conflict_clause_idx = c_idx
            self.trace.emit("PSE", f"Conflict detected in Clause {c_idx}: {lits}")
            return "CONFLICT"

        unit = lits[o_idx]
        self.trace.emit("PSE", f"Propagating Unit {unit} from Clause {c_idx}")
        self.mem.assign(unit, c_idx, decision_level=len(self.mem.trail_lim))
        return "KEEP_WATCH"


class ConflictAnalysisEngine:
    def __init__(self, mem: MemorySystem, vde: VariableDecisionEngine, trace: TraceLogger):
        self.mem = mem
        self.vde = vde
        self.trace = trace
        self.conflict_count = 0

    def analyze(self, conflict_idx: int):
        self.conflict_count += 1
        curr_level = len(self.mem.trail_lim)
        if curr_level == 0:
            return None, -1

        learned = []
        path_c = 0
        p = None
        seen = set()
        clause_to_resolve = self.mem.clause_db[conflict_idx].literals
        index = len(self.mem.trail) - 1

        while True:
            for lit in clause_to_resolve:
                var = abs(lit)
                if var in seen:
                    continue
                seen.add(var)
                if self.mem.level[var] == curr_level:
                    path_c += 1
                else:
                    learned.append(lit)

            while True:
                if index < 0:
                    break
                p = self.mem.trail[index]
                index -= 1
                if abs(p) in seen:
                    break

            path_c -= 1
            if path_c <= 0:
                break
            if abs(p) not in seen:
                break
            reason_idx = self.mem.reason[abs(p)]
            if reason_idx is None:
                break
            clause_to_resolve = [l for l in self.mem.clause_db[reason_idx].literals if abs(l) != abs(p)]

        learned.insert(0, -p)
        if len(learned) == 1:
            bt_level = 0
        else:
            levels = [self.mem.level[abs(l)] if self.mem.level[abs(l)] != -1 else 0 for l in learned[1:]]
            bt_level = max(levels) if levels else 0

        for lit in learned:
            self.vde.bump_activity(abs(lit))
        self.vde.decay_activities()

        self.trace.learned_clauses.append(list(learned))
        self.trace.emit("CAE", f"Learned Clause: {learned}, Backtrack to: {bt_level}")
        return learned, bt_level


class MegaSimExact:
    def __init__(self, cnf_content: str, verbose: bool = True):
        self.trace = TraceLogger(verbose=verbose)
        self.num_vars, clauses = self.parse_dimacs(cnf_content)
        self.mem = MemorySystem(self.num_vars, self.trace)
        self.vde = VariableDecisionEngine(self.mem)
        self.pse = PropagationSearchEngine(self.mem, self.trace)
        self.cae = ConflictAnalysisEngine(self.mem, self.vde, self.trace)

        for clause in clauses:
            self.mem.add_clause(clause)

    @staticmethod
    def parse_dimacs(content: str):
        clauses = []
        num_vars = 0
        for raw in content.strip().splitlines():
            line = raw.strip()
            if not line or line.startswith("c") or line.startswith("%"):
                continue
            if line.startswith("p cnf"):
                parts = line.split()
                num_vars = int(parts[2])
                continue
            lits = [int(x) for x in line.split() if x != "0"]
            if lits:
                clauses.append(lits)
        return num_vars, clauses

    def backtrack(self, level: int):
        while len(self.mem.trail_lim) > level:
            limit = self.mem.trail_lim.pop()
            while len(self.mem.trail) > limit:
                lit = self.mem.trail.pop()
                var = abs(lit)
                self.mem.assignments[var] = 0
                self.mem.level[var] = -1
                self.mem.reason[var] = None
                self.vde.on_unassign(var)
        self.pse.q_head = len(self.mem.trail)

    def solve(self, max_steps: int = 2_000_000) -> str:
        if self.pse.propagate() == "CONFLICT":
            return "UNSAT"

        steps = 0
        while steps < max_steps:
            steps += 1
            lit = self.vde.decide()
            if lit is None:
                return "SAT"

            level = len(self.mem.trail_lim) + 1
            self.trace.decisions.append(int(lit))
            self.trace.emit("VDE", f"Decided: {lit} at Level {level}")
            self.mem.trail_lim.append(len(self.mem.trail))
            self.mem.assign(lit, reason_clause_idx=None, decision_level=level)

            force_conflict = False
            while True:
                conflict = "CONFLICT" if force_conflict else self.pse.propagate()
                force_conflict = False
                if conflict != "CONFLICT":
                    break

                learned, bt_level = self.cae.analyze(self.mem.conflict_clause_idx)
                if bt_level == -1:
                    return "UNSAT"
                self.backtrack(bt_level)
                c_idx = self.mem.add_clause(learned, is_learned=True)
                if not self.mem.assign(learned[0], c_idx, decision_level=bt_level):
                    if self.mem.get_val(learned[0]) == -1:
                        self.mem.conflict_clause_idx = c_idx
                        force_conflict = True
                        continue
                self.pse.q_head = len(self.mem.trail) - 1

        return "TIMEOUT"

    def exact_summary(self):
        return {
            "result": None,
            "decisions": self.trace.decisions,
            "watch_moves": self.trace.watch_moves,
            "learned_clauses": self.trace.learned_clauses,
            "conflicts": self.cae.conflict_count,
            "total_clauses": len(self.mem.clause_db),
        }


def load_cnf(path: Optional[str]) -> str:
    if path:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    return """p cnf 8 20
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


def main():
    parser = argparse.ArgumentParser(description="High-level exact-order Mega simulator")
    parser.add_argument("cnf", nargs="?", help="Path to DIMACS CNF")
    parser.add_argument("--quiet", action="store_true", help="Disable step logs")
    parser.add_argument("--json", action="store_true", help="Emit exactness summary JSON")
    args = parser.parse_args()

    sim = MegaSimExact(load_cnf(args.cnf), verbose=not args.quiet)
    result = sim.solve()
    summary = sim.exact_summary()
    summary["result"] = result

    print(f"Final Result: {result}")
    print(f"Conflicts: {summary['conflicts']}")
    print(f"Decisions: {len(summary['decisions'])}")
    print(f"Learned Clauses: {len(summary['learned_clauses'])}")

    if args.json:
        print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
