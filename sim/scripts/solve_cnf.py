
import sys

def parse_cnf(filename):
    clauses = []
    num_vars = 0
    with open(filename, 'r') as f:
        for line in f:
            if line.startswith('c') or line.startswith('%') or line.startswith('0'):
                continue
            if line.startswith('p cnf'):
                parts = line.split()
                num_vars = int(parts[2])
                continue
            
            parts = [int(x) for x in line.split() if x != '0']
            if parts:
                clauses.append(parts)
    return num_vars, clauses

def solve(num_vars, clauses):
    # Brute force 2^N
    for i in range(1 << num_vars):
        assignment = {}
        for v in range(1, num_vars + 1):
            # i has bits. bit 0 -> var 1
            val = (i >> (v-1)) & 1
            assignment[v] = True if val else False
        
        # Check clauses
        all_sat = True
        for cl in clauses:
            clause_sat = False
            for lit in cl:
                var = abs(lit)
                is_pos = lit > 0
                val = assignment[var]
                if (is_pos and val) or (not is_pos and not val):
                    clause_sat = True
                    break
            if not clause_sat:
                all_sat = False
                break
        
        if all_sat:
            return True, assignment
            
    return False, {}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 solve_cnf.py <file.cnf>")
        sys.exit(1)
        
    f = sys.argv[1]
    n, c = parse_cnf(f)
    print(f"Solving {f} ({n} vars, {len(c)} clauses)...")
    is_sat, model = solve(n, c)
    if is_sat:
        print("SAT")
        print("Model:", model)
    else:
        print("UNSAT")
