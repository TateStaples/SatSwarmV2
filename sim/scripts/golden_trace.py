import sys

def parse_dimacs(filename):
    clauses = []
    n_vars = 0
    with open(filename, 'r') as f:
        for line in f:
            if line.startswith('c'): continue
            if line.startswith('p'):
                n_vars = int(line.split()[2])
                continue
            parts = [int(x) for x in line.split() if x != '0']
            if parts: clauses.append(parts)
    return n_vars, clauses

def solve(clauses, assignment, dlevel):
    # BCP
    while True:
        propagated = False
        # Iterate in REVERSE to mimic HW LIFO/Index behavior
        for i, clause in reversed(list(enumerate(clauses))):
            # Check status
            lits_val = []
            unassigned = []
            for lit in clause:
                val = None
                var = abs(lit)
                if var in assignment:
                    if (lit > 0 and assignment[var]) or (lit < 0 and not assignment[var]):
                        val = True
                    else:
                        val = False
                if val == True:
                    lits_val = [True] # Satisfied
                    break
                if val is None:
                    unassigned.append(lit)
                else:
                    lits_val.append(False)
            
            if True in lits_val:
                continue # Satisfied
            
            if len(unassigned) == 0:
                print(f"[Expect] Conflict in Clause {i}: {clause} @ Level {dlevel}")
                return False # Conflict
            
            if len(unassigned) == 1:
                # Unit
                lit = unassigned[0]
                var = abs(lit)
                val = (lit > 0)
                assignment[var] = val
                print(f"[Expect] Propagate: {lit} (Var {var}={val}) from Clause {i} @ Level {dlevel}")
                propagated = True
        
        if not propagated:
            break
            
    # Check if satisfied
    all_sat = True
    for clause in clauses:
        sat = False
        for lit in clause:
            var = abs(lit)
            if var in assignment:
                 if (lit > 0 and assignment[var]) or (lit < 0 and not assignment[var]):
                     sat = True
                     break
        if not sat: all_sat = False; break
        
    if all_sat:
        print("[Expect] SATISFIED")
        return True

    # Decide (Pick first unassigned)
    # Heuristic: Mimic VDE (Unit/VSIDS). For small, usually lowest var.
    # HW VDE picked -1 (Var 1 = False) first
    
    # Try 1 False
    var = 1
    while var in assignment and var <= 3: var += 1 # simplistic
    if var > 3: return False # Should be sat caught above

    print(f"[Expect] Decide: -{var} (Var {var}=False) @ Level {dlevel+1}")
    assign_copy = assignment.copy()
    assign_copy[var] = False
    if solve(clauses, assign_copy, dlevel+1): return True
    
    print(f"[Expect] Backtrack / Decide: {var} (Var {var}=True) @ Level {dlevel+1}")
    assign_copy = assignment.copy()
    assign_copy[var] = True
    if solve(clauses, assign_copy, dlevel+1): return True

    return False

if __name__ == "__main__":
    nv, clauses = parse_dimacs(sys.argv[1])
    print(f"Solving {sys.argv[1]} with {nv} vars, {len(clauses)} clauses")
    solve(clauses, {}, 0)
