#!/usr/bin/python3

import sys
import random
from pysat.solvers import Glucose3

def generate_cnf(k, n, m):
    """Generates a random k-SAT instance in list-of-lists format."""
    vars_list = list(range(1, n + 1))
    clauses = []
    for _ in range(m):
        # Sample k unique variables
        rand_vars = random.sample(vars_list, k)
        clause = []
        for var in rand_vars:
            # Randomly negate
            if random.randint(0, 1) == 1:
                clause.append(-var)
            else:
                clause.append(var)
        clauses.append(clause)
    return clauses

def main():
    if len(sys.argv) < 6:
        print("usage: python toughsat.py <k> <n> <m> <num_sat> <num_unsat> [output_dir]")
        sys.exit()

    k, n, m = map(int, sys.argv[1:4])
    target_sat = int(sys.argv[4])
    target_unsat = int(sys.argv[5])
    output_dir = sys.argv[6] if len(sys.argv) > 6 else "."
    
    import os
    os.makedirs(output_dir, exist_ok=True)

    found_sat = 0
    found_unsat = 0

    while found_sat < target_sat or found_unsat < target_unsat:
        clauses = generate_cnf(k, n, m)
        
        # Use Glucose3 solver to classify
        with Glucose3(bootstrap_with=clauses) as solver:
            is_sat = solver.solve()
            
            if is_sat and found_sat < target_sat:
                found_sat += 1
                filename = os.path.join(output_dir, f"sat_{n}v_{m}c_{found_sat}.cnf")
                save_dimacs(filename, clauses, n, m)
                print(f"Generated {filename}")
                
            elif not is_sat and found_unsat < target_unsat:
                found_unsat += 1
                filename = os.path.join(output_dir, f"unsat_{n}v_{m}c_{found_unsat}.cnf")
                save_dimacs(filename, clauses, n, m)
                print(f"Generated {filename}")

def save_dimacs(filename, clauses, n, m):
    with open(filename, 'w') as f:
        f.write(f"p cnf {n} {m}\n")
        for clause in clauses:
            f.write(" ".join(map(str, clause)) + " 0\n")

if __name__ == "__main__":
    main()
