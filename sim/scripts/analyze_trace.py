#!/usr/bin/env python3
"""
analyze_trace.py — Analyze a SatSwarm simulation debug trace to diagnose
false UNSAT (SAT instance reported as UNSAT).

Usage:
    python3 sim/scripts/analyze_trace.py <trace_file> [--tail N] [--plot]

Options:
    --tail N     Show last N learned clauses before UNSAT (default: 30)
    --plot       Show backtrack-level histogram over time (requires matplotlib)
"""

import sys
import re
import argparse
from collections import Counter, defaultdict

# ---------------------------------------------------------------------------
# Regex patterns matching solver_core.sv / cae.sv $display statements
# ---------------------------------------------------------------------------

# [hw_trace] [CAE] Learned Clause: [N, M, ...] Backtrack to: K Trail Height: J
RE_LEARNED = re.compile(
    r'\[hw_trace\] \[CAE\] Learned Clause: \[(-?\d+), (-?\d+)[^\]]*\] Backtrack to: (\d+) Trail Height: (\d+)'
)

# [CORE N] CONFLICT_ANALYSIS: Sending to CAE. Len=N DecLvl=M
RE_CONFLICT = re.compile(
    r'\[CORE (\d+)\] CONFLICT_ANALYSIS: Sending to CAE\. Len=(\d+) DecLvl=(\d+)'
)

# [CORE N Cycle M] *** UNSAT: CAE_UNSAT=B, Learned_Len=L, Clause=[a,b]
RE_UNSAT_CAE = re.compile(
    r'\[CORE (\d+) Cycle (\d+)\] \*\*\* UNSAT: CAE_UNSAT=(\d), Learned_Len=(\d+), Clause=\[(-?\d+),(-?\d+)\]'
)

# [CORE N Cycle M] *** UNSAT: Conflict at level 1, backtrack to 0
RE_UNSAT_LVL1 = re.compile(
    r'\[CORE (\d+) Cycle (\d+)\] \*\*\* UNSAT: Conflict at level 1'
)

# [SYS] Result: UNSAT
RE_SYS_UNSAT = re.compile(r'\[SYS\] Result: UNSAT')

# [hw_trace] [VDE] Decided: N at Level M
RE_DECIDED = re.compile(r'\[hw_trace\] \[VDE\] Decided: (-?\d+) at Level (\d+)')

# [TB] cycles or heartbeat
RE_CYCLE_HB = re.compile(r'Cycle (\d+)')

# [CAE DBG] INIT_CLAUSE done: count_at_level=N dec_lvl=M buf_count=P
RE_CAE_INIT = re.compile(
    r'\[CAE DBG\] INIT_CLAUSE done: count_at_level=(\d+) dec_lvl=(\d+) buf_count=(\d+)'
)

# [CAE DBG] buf[k]: lit=N lvl=M
RE_CAE_BUF = re.compile(r'\[CAE DBG\]   buf\[(\d+)\]: lit=(-?\d+) lvl=(\d+)')


def parse_trace(path):
    learned_clauses = []       # list of dicts
    conflicts = []             # list of dicts
    decisions = []             # list of (lit, level)
    unsat_events = []          # list of dicts
    backtrack_levels = []      # list of int (backtrack target per learned clause)
    conflict_levels = []       # list of int (decision level at time of each conflict)

    current_conflict = None
    current_cae_buf = []

    with open(path, 'r', errors='replace') as f:
        for lineno, line in enumerate(f, 1):
            line = line.rstrip()

            m = RE_CONFLICT.search(line)
            if m:
                current_conflict = {
                    'core': int(m.group(1)),
                    'len': int(m.group(2)),
                    'dec_lvl': int(m.group(3)),
                    'lineno': lineno,
                }
                conflict_levels.append(int(m.group(3)))
                current_cae_buf = []
                continue

            m = RE_CAE_BUF.search(line)
            if m:
                current_cae_buf.append({'idx': int(m.group(1)), 'lit': int(m.group(2)), 'lvl': int(m.group(3))})
                continue

            m = RE_LEARNED.search(line)
            if m:
                entry = {
                    'lit0': int(m.group(1)),
                    'lit1': int(m.group(2)),
                    'backtrack_to': int(m.group(3)),
                    'trail_height': int(m.group(4)),
                    'lineno': lineno,
                    'conflict': current_conflict,
                    'cae_buf': list(current_cae_buf),
                }
                learned_clauses.append(entry)
                backtrack_levels.append(int(m.group(3)))
                current_conflict = None
                current_cae_buf = []
                continue

            m = RE_UNSAT_CAE.search(line)
            if m:
                unsat_events.append({
                    'type': 'cae_unsat',
                    'core': int(m.group(1)),
                    'cycle': int(m.group(2)),
                    'cae_unsat_flag': int(m.group(3)),
                    'learned_len': int(m.group(4)),
                    'clause_lit0': int(m.group(5)),
                    'clause_lit1': int(m.group(6)),
                    'lineno': lineno,
                    'last_conflict': current_conflict,
                })
                continue

            m = RE_UNSAT_LVL1.search(line)
            if m:
                unsat_events.append({
                    'type': 'lvl1_conflict',
                    'core': int(m.group(1)),
                    'cycle': int(m.group(2)),
                    'lineno': lineno,
                })
                continue

            m = RE_DECIDED.search(line)
            if m:
                decisions.append((int(m.group(1)), int(m.group(2))))
                continue

    return {
        'learned': learned_clauses,
        'conflicts': conflicts,
        'conflict_levels': conflict_levels,
        'decisions': decisions,
        'unsat_events': unsat_events,
        'backtrack_levels': backtrack_levels,
    }


def report(data, tail=30, plot=False):
    learned = data['learned']
    unsat_events = data['unsat_events']
    conflict_levels = data['conflict_levels']
    backtrack_levels = data['backtrack_levels']

    print("=" * 70)
    print(f"  Total learned clauses:   {len(learned)}")
    print(f"  Total conflicts seen:    {len(conflict_levels)}")
    print(f"  UNSAT events:            {len(unsat_events)}")
    print("=" * 70)

    # --- Conflict level distribution ---
    if conflict_levels:
        lvl_counts = Counter(conflict_levels)
        print("\n--- Conflict Decision Level Distribution ---")
        for lvl in sorted(lvl_counts):
            bar = '#' * min(lvl_counts[lvl], 60)
            print(f"  Level {lvl:3d}: {lvl_counts[lvl]:6d}  {bar}")
        n_lvl0 = lvl_counts.get(0, 0)
        if n_lvl0 > 0:
            print(f"\n  *** {n_lvl0} conflict(s) at decision level 0 detected ***")

    # --- Backtrack level distribution ---
    if backtrack_levels:
        bt_counts = Counter(backtrack_levels)
        print("\n--- Backtrack Target Level Distribution ---")
        for lvl in sorted(bt_counts)[:20]:
            bar = '#' * min(bt_counts[lvl] // max(1, len(backtrack_levels) // 60), 60)
            print(f"  To level {lvl:3d}: {bt_counts[lvl]:6d}  {bar}")
        n_bt0 = bt_counts.get(0, 0)
        if n_bt0 > 0:
            print(f"\n  *** {n_bt0} backtrack(s) to level 0 (restarts/proofs) ***")

    # --- UNSAT trigger ---
    print("\n--- UNSAT Events ---")
    if not unsat_events:
        print("  (none found — check the trace for [SYS] Result: UNSAT)")
    for ev in unsat_events:
        print(f"  Line {ev['lineno']}: type={ev['type']}", end='')
        if 'cycle' in ev:
            print(f"  cycle={ev['cycle']}", end='')
        if ev['type'] == 'cae_unsat':
            print(f"  cae_unsat_flag={ev['cae_unsat_flag']}  learned_len={ev['learned_len']}  clause=[{ev['clause_lit0']}, {ev['clause_lit1']}]", end='')
        print()
        if ev.get('last_conflict'):
            c = ev['last_conflict']
            print(f"    Last conflict before UNSAT: core={c['core']} dec_lvl={c['dec_lvl']} clause_len={c['len']}")

    # --- Last N learned clauses ---
    print(f"\n--- Last {tail} Learned Clauses (before UNSAT) ---")
    tail_clauses = learned[-tail:]
    for i, lc in enumerate(tail_clauses):
        idx = len(learned) - tail + i
        cf = lc['conflict']
        dec_lvl_str = f"dec_lvl={cf['dec_lvl']}" if cf else "dec_lvl=?"
        print(f"  [{idx:5d}] line={lc['lineno']:8d}  bt_to={lc['backtrack_to']:3d}  trail_ht={lc['trail_height']:4d}  "
              f"lit0={lc['lit0']:6d} lit1={lc['lit1']:6d}  {dec_lvl_str}")

    # --- Check for suspicious pattern: dec_lvl=0 conflict that produced a learned clause ---
    lvl0_learned = [lc for lc in learned if lc['conflict'] and lc['conflict']['dec_lvl'] == 0]
    if lvl0_learned:
        print(f"\n*** WARNING: {len(lvl0_learned)} learned clause(s) had dec_lvl=0 at conflict time ***")
        print("    (This means CAE was called for a level-0 conflict — unexpected with the shortcut)")
        for lc in lvl0_learned[-5:]:
            print(f"    line={lc['lineno']}  bt_to={lc['backtrack_to']}  lit0={lc['lit0']}  lit1={lc['lit1']}")

    # --- Check for bt_to=0 cascade (many consecutive backtracks to 0) ---
    bt0_runs = 0
    current_run = 0
    for bt in backtrack_levels:
        if bt == 0:
            current_run += 1
            bt0_runs = max(bt0_runs, current_run)
        else:
            current_run = 0
    if bt0_runs > 1:
        print(f"\n*** Longest consecutive backtrack-to-0 run: {bt0_runs} ***")
        print("    (Multiple restarts in a row may indicate solver getting stuck)")

    # --- Final conflict before UNSAT ---
    if learned and unsat_events:
        last_unsat = unsat_events[-1]
        # Find any learned clause whose lineno is near the unsat event
        nearby = [lc for lc in learned if abs(lc['lineno'] - last_unsat['lineno']) < 200]
        if nearby:
            print(f"\n--- Learned Clauses Near UNSAT Event (line {last_unsat['lineno']}) ---")
            for lc in nearby:
                cf = lc['conflict']
                dec_lvl_str = f"dec_lvl={cf['dec_lvl']}" if cf else "dec_lvl=?"
                print(f"  line={lc['lineno']:8d}  bt_to={lc['backtrack_to']:3d}  trail_ht={lc['trail_height']:4d}  "
                      f"lit0={lc['lit0']:6d} lit1={lc['lit1']:6d}  {dec_lvl_str}")
                if lc['cae_buf']:
                    print(f"    CAE buf ({len(lc['cae_buf'])} lits): " +
                          ', '.join(f"lit={b['lit']} lvl={b['lvl']}" for b in lc['cae_buf'][:8]))

    # --- Backtrack level time series (last 200 learned clauses) ---
    if len(learned) > 5:
        print(f"\n--- Backtrack Level (last 100 learned clauses) ---")
        tail200 = backtrack_levels[-100:]
        # ASCII sparkline
        if tail200:
            max_bt = max(tail200) if max(tail200) > 0 else 1
            for bt in tail200:
                bar = int(bt / max_bt * 20)
                print(f"  {bt:3d} {'|' * bar}")

    if plot:
        try:
            import matplotlib.pyplot as plt
            plt.figure(figsize=(14, 5))
            plt.subplot(1, 2, 1)
            plt.plot(backtrack_levels[-2000:], alpha=0.7, linewidth=0.5)
            plt.xlabel('Conflict #')
            plt.ylabel('Backtrack target level')
            plt.title('Backtrack levels (last 2000)')
            plt.subplot(1, 2, 2)
            lvl_counts = Counter(conflict_levels)
            plt.bar(lvl_counts.keys(), lvl_counts.values())
            plt.xlabel('Decision level at conflict')
            plt.ylabel('Count')
            plt.title('Conflict level distribution')
            plt.tight_layout()
            plt.savefig('/tmp/trace_analysis.png')
            print("\n  Plot saved to /tmp/trace_analysis.png")
        except ImportError:
            print("  (matplotlib not available — skipping plot)")


def main():
    parser = argparse.ArgumentParser(description="Analyze SatSwarm simulation trace")
    parser.add_argument('trace', help='Path to the trace file')
    parser.add_argument('--tail', type=int, default=30, help='Show last N learned clauses')
    parser.add_argument('--plot', action='store_true', help='Generate matplotlib plot')
    args = parser.parse_args()

    print(f"Parsing trace: {args.trace}")
    data = parse_trace(args.trace)
    report(data, tail=args.tail, plot=args.plot)


if __name__ == '__main__':
    main()
