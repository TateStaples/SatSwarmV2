#!/usr/bin/env python3
"""
compare_traces.py — Compare RTL simulation trace with mega_sim reference trace.

Parses [hw_trace] events from both files and reports:
  - Stats summary (decisions, props, conflicts, learns)
  - Decision sequence comparison (first divergence)
  - Conflict-by-conflict comparison (props before, bt level, learned clause length)
  - Restart detection (RTL only)
  - Plain-English verdict

Usage:
  python3 sim/scripts/compare_traces.py [rtl_trace] [mega_trace]
  python3 sim/scripts/compare_traces.py rtl_events.txt mega_events.txt
"""

import sys
import re
import argparse
from collections import defaultdict


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

def parse_hw_trace(filename):
    """Extract [hw_trace] events from a trace file. Returns list of event dicts."""
    events = []
    with open(filename, errors='replace') as f:
        for lineno, line in enumerate(f, 1):
            line = line.rstrip()
            if '[hw_trace]' not in line:
                continue
            m = re.search(r'\[hw_trace\]\s+\[(\w+)\]\s+(.*)', line)
            if not m:
                continue
            module = m.group(1)
            msg = m.group(2).strip()
            event = _parse_event(module, msg, lineno)
            if event:
                events.append(event)
    return events


def _parse_event(module, msg, lineno):
    if module == 'VDE':
        m = re.match(r'Decided:\s*(-?\d+)\s+(?:at|@)\s+Level\s+(\d+)', msg)
        if m:
            return {'type': 'DECIDE', 'lit': int(m.group(1)), 'level': int(m.group(2)), 'line': lineno}

    elif module == 'PSE':
        m = re.match(r'Propagating Unit\s+(-?\d+)\s+from Clause\s+(\d+)', msg)
        if m:
            return {'type': 'PROP', 'lit': int(m.group(1)), 'clause': int(m.group(2)), 'line': lineno}
        m = re.match(r'Conflict detected in Clause\s+(\d+)', msg)
        if m:
            return {'type': 'CONFLICT', 'clause': int(m.group(1)), 'line': lineno}
        # mega_sim format: "Conflict detected (conflict #N) in Clause: [lits]"
        m = re.match(r'Conflict detected.*?Clause[:\s]+(\[.*?\]|\d+)', msg)
        if m:
            return {'type': 'CONFLICT', 'clause': m.group(1), 'line': lineno}

    elif module == 'CAE':
        # RTL: "Learned Clause: [-12, 5] Backtrack to: 3 Trail Height: 22"
        # mega: "Learned Clause #N: [-12, 5, ...], Backtrack to: 3"
        m = re.search(r'Learned Clause[^:]*:\s*(.*?),?\s*Backtrack to:\s*(\d+)', msg)
        if m:
            clause_str = m.group(1).strip().rstrip(',')
            bt_level = int(m.group(2))
            lits = _parse_lits(clause_str)
            return {'type': 'LEARN', 'lits': lits, 'len': len(lits), 'bt_level': bt_level, 'line': lineno}

    return None


def _parse_lits(clause_str):
    """Parse a clause string like '[-12, 5, 3]' or '-12 5 3' into list of ints."""
    return [int(x) for x in re.findall(r'-?\d+', clause_str)]


# ---------------------------------------------------------------------------
# Grouping into conflict blocks
# ---------------------------------------------------------------------------

def group_into_conflict_blocks(events):
    """
    Group events into blocks, each ending at a CONFLICT+LEARN pair.
    Each block: {decides, props, conflict, learn}
    """
    blocks = []
    current = {'decides': [], 'props': [], 'conflict': None, 'learn': None}

    for e in events:
        t = e['type']
        if t == 'DECIDE':
            current['decides'].append(e)
        elif t == 'PROP':
            current['props'].append(e)
        elif t == 'CONFLICT':
            current['conflict'] = e
        elif t == 'LEARN':
            current['learn'] = e
            blocks.append(current)
            current = {'decides': [], 'props': [], 'conflict': None, 'learn': None}

    # Trailing block (no conflict at end)
    if current['decides'] or current['props']:
        blocks.append(current)

    return blocks


def detect_restarts(events):
    """
    Detect restart events: a drop in decision level back to 1 after being at level > 5.
    Returns list of (event_index, from_level, to_level).
    """
    restarts = []
    decide_events = [e for e in events if e['type'] == 'DECIDE']
    prev_level = 0
    for i, e in enumerate(decide_events):
        lvl = e['level']
        if prev_level > 5 and lvl == 1:
            restarts.append({'at_decide': i, 'from_level': prev_level, 'to_level': lvl, 'line': e['line']})
        prev_level = lvl
    return restarts


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def stats(events):
    c = defaultdict(int)
    for e in events:
        c[e['type']] += 1
    return c


def print_stats_table(rtl, mega):
    rs, ms = stats(rtl), stats(mega)
    print("=== STATISTICS ===")
    print(f"{'Event':<12} {'RTL':>8} {'Mega':>8} {'Diff':>8}")
    print("-" * 42)
    for k in ['DECIDE', 'PROP', 'CONFLICT', 'LEARN']:
        r, m = rs[k], ms[k]
        diff = r - m
        flag = "  <-- !!!" if abs(diff) > max(1, 0.1 * max(r, m, 1)) else ""
        print(f"{k:<12} {r:>8} {m:>8} {diff:>+8}{flag}")
    print()


def print_decision_sequence(rtl, mega, n=40):
    rtl_d = [e for e in rtl if e['type'] == 'DECIDE']
    mega_d = [e for e in mega if e['type'] == 'DECIDE']
    limit = min(n, len(rtl_d), len(mega_d))

    print(f"=== DECISION SEQUENCE (first {limit}) ===")
    print(f"{'#':<5} {'RTL':>14} {'Mega':>14}  Match")
    print("-" * 42)

    first_diverge = None
    for i in range(limit):
        r, m = rtl_d[i], mega_d[i]
        r_str = f"{r['lit']}@L{r['level']}"
        m_str = f"{m['lit']}@L{m['level']}"
        match = "OK" if r['lit'] == m['lit'] else "DIFF <--"
        if match != "OK" and first_diverge is None:
            first_diverge = i + 1
        print(f"{i+1:<5} {r_str:>14} {m_str:>14}  {match}")

    if first_diverge:
        print(f"\n  !! First divergence at decision #{first_diverge}")
    else:
        print(f"\n  All {limit} decisions match.")
    print()


def print_conflict_comparison(rtl_blocks, mega_blocks, n=15):
    rtl_c = [b for b in rtl_blocks if b['conflict']]
    mega_c = [b for b in mega_blocks if b['conflict']]
    limit = min(n, len(rtl_c), len(mega_c))

    print(f"=== CONFLICT COMPARISON (first {limit}) ===")
    hdr = f"{'#':<4} {'RTL last-decide':>16} {'RTL props':>10} {'RTL bt':>7} {'RTL llen':>9}  |  {'Mega last-decide':>16} {'Mega props':>10} {'Mega bt':>7} {'Mega llen':>9}"
    print(hdr)
    print("-" * len(hdr))

    for i in range(limit):
        rb, mb = rtl_c[i], mega_c[i]
        rd = rb['decides'][-1] if rb['decides'] else None
        md = mb['decides'][-1] if mb['decides'] else None
        rd_str = f"{rd['lit']}@L{rd['level']}" if rd else "?"
        md_str = f"{md['lit']}@L{md['level']}" if md else "?"
        rbt = rb['learn']['bt_level'] if rb['learn'] else "?"
        mbt = mb['learn']['bt_level'] if mb['learn'] else "?"
        rll = rb['learn']['len'] if rb['learn'] else "?"
        mll = mb['learn']['len'] if mb['learn'] else "?"
        flag = ""
        if rb['learn'] and mb['learn'] and abs(rb['learn']['len'] - mb['learn']['len']) > 3:
            flag = "  <-- len diff"
        print(f"{i+1:<4} {rd_str:>16} {len(rb['props']):>10} {str(rbt):>7} {str(rll):>9}  |  "
              f"{md_str:>16} {len(mb['props']):>10} {str(mbt):>7} {str(mll):>9}{flag}")
    print()


def print_restarts(rtl, mega):
    rtl_restarts = detect_restarts(rtl)
    mega_restarts = detect_restarts(mega)
    print(f"=== RESTARTS ===")
    print(f"  RTL:  {len(rtl_restarts)} restart(s) detected")
    print(f"  Mega: {len(mega_restarts)} restart(s) detected")
    if rtl_restarts:
        for r in rtl_restarts[:5]:
            print(f"    RTL restart at decide #{r['at_decide']+1}: level {r['from_level']} -> {r['to_level']}  (line {r['line']})")
    print()


def print_learned_clause_stats(rtl_blocks, mega_blocks):
    rtl_learns = [b['learn'] for b in rtl_blocks if b['learn']]
    mega_learns = [b['learn'] for b in mega_blocks if b['learn']]

    def avg(lst, key):
        vals = [x[key] for x in lst if isinstance(x[key], int)]
        return sum(vals) / len(vals) if vals else 0

    print("=== LEARNED CLAUSE STATS ===")
    print(f"{'Metric':<25} {'RTL':>10} {'Mega':>10}")
    print("-" * 48)
    print(f"{'Count':<25} {len(rtl_learns):>10} {len(mega_learns):>10}")
    print(f"{'Avg length':<25} {avg(rtl_learns, 'len'):>10.2f} {avg(mega_learns, 'len'):>10.2f}")
    print(f"{'Avg backtrack level':<25} {avg(rtl_learns, 'bt_level'):>10.2f} {avg(mega_learns, 'bt_level'):>10.2f}")

    if rtl_learns and mega_learns:
        rl_avg = avg(rtl_learns, 'len')
        ml_avg = avg(mega_learns, 'len')
        if rl_avg > ml_avg + 2:
            print(f"\n  !! RTL learning longer clauses on average ({rl_avg:.1f} vs {ml_avg:.1f}) — weaker learned clauses")
        elif ml_avg > rl_avg + 2:
            print(f"\n  !! Mega learning longer clauses ({ml_avg:.1f} vs {rl_avg:.1f})")
    print()


def print_verdict(rtl, mega, rtl_blocks, mega_blocks):
    rs, ms = stats(rtl), stats(mega)
    rtl_restarts = detect_restarts(rtl)

    print("=== VERDICT ===")
    issues = []

    # Decision ratio
    if ms['CONFLICT'] > 0 and rs['DECIDE'] > 0:
        rtl_dpc = rs['DECIDE'] / max(rs['CONFLICT'], 1)
        mega_dpc = ms['DECIDE'] / max(ms['CONFLICT'], 1)
        if rtl_dpc > mega_dpc * 1.5:
            issues.append(f"RTL makes {rtl_dpc:.1f} decisions/conflict vs mega's {mega_dpc:.1f} "
                          f"({rtl_dpc/mega_dpc:.1f}x more) — VSIDS or restart divergence")

    # Propagation ratio
    if ms['CONFLICT'] > 0:
        rtl_ppc = rs['PROP'] / max(rs['CONFLICT'], 1)
        mega_ppc = ms['PROP'] / max(ms['CONFLICT'], 1)
        if abs(rtl_ppc - mega_ppc) > 5:
            issues.append(f"RTL averages {rtl_ppc:.1f} props/conflict vs mega's {mega_ppc:.1f} "
                          f"— {'more' if rtl_ppc > mega_ppc else 'fewer'} propagations than expected")

    # Restarts
    if rtl_restarts:
        issues.append(f"RTL performed {len(rtl_restarts)} restart(s) (mega has none) — "
                      f"restarts discard learned clauses and reset search")

    # Learned clause length
    rtl_learns = [b['learn'] for b in rtl_blocks if b['learn']]
    mega_learns = [b['learn'] for b in mega_blocks if b['learn']]
    if rtl_learns and mega_learns:
        rl_avg = sum(l['len'] for l in rtl_learns) / len(rtl_learns)
        ml_avg = sum(l['len'] for l in mega_learns) / len(mega_learns)
        if rl_avg > ml_avg + 2:
            issues.append(f"RTL learned clauses avg {rl_avg:.1f} lits vs mega's {ml_avg:.1f} — "
                          f"CAE may be producing weaker clauses")

    # Conflict count divergence
    if rs['CONFLICT'] < ms['CONFLICT'] * 0.3 and ms['CONFLICT'] > 10:
        issues.append(f"RTL only reached {rs['CONFLICT']} conflicts vs mega's {ms['CONFLICT']} — "
                      f"trace may be truncated or simulation timed out early")
    elif rs['CONFLICT'] > ms['CONFLICT'] * 3 and ms['CONFLICT'] > 5:
        issues.append(f"RTL required {rs['CONFLICT']} conflicts vs mega's {ms['CONFLICT']} — "
                      f"RTL search is significantly less efficient")

    if issues:
        for i, issue in enumerate(issues, 1):
            print(f"  {i}. {issue}")
    else:
        print("  No major divergence detected in the compared events.")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Compare RTL and mega_sim SAT solver traces.")
    parser.add_argument('rtl', nargs='?', default='rtl_events.txt', help='RTL trace file (default: rtl_events.txt)')
    parser.add_argument('mega', nargs='?', default='mega_events.txt', help='mega_sim trace file (default: mega_events.txt)')
    parser.add_argument('--decisions', type=int, default=40, help='How many decisions to compare (default: 40)')
    parser.add_argument('--conflicts', type=int, default=15, help='How many conflicts to compare (default: 15)')
    args = parser.parse_args()

    print(f"RTL trace:  {args.rtl}")
    print(f"Mega trace: {args.mega}\n")

    rtl = parse_hw_trace(args.rtl)
    mega = parse_hw_trace(args.mega)

    print(f"Parsed {len(rtl)} RTL hw_trace events, {len(mega)} mega hw_trace events.\n")

    rtl_blocks = group_into_conflict_blocks(rtl)
    mega_blocks = group_into_conflict_blocks(mega)

    print_stats_table(rtl, mega)
    print_restarts(rtl, mega)
    print_decision_sequence(rtl, mega, n=args.decisions)
    print_conflict_comparison(rtl_blocks, mega_blocks, n=args.conflicts)
    print_learned_clause_stats(rtl_blocks, mega_blocks)
    print_verdict(rtl, mega, rtl_blocks, mega_blocks)


if __name__ == '__main__':
    main()
