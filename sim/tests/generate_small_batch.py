
import os
import random
import sys
# Add current directory to path to allow importing toughsat if needed, 
# but better to just use subprocess to call it or copy the logic.
# Since toughsat.py acts as a script, let's just import the generate_cnf and solve logic
# by reading toughsat.py or just re-implementing the loop here for better control 
# without modifying toughsat.py.
# Actually, I can just import toughsat if I fix the path.

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
import toughsat

def main():
    output_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "small_tests")
    os.makedirs(output_dir, exist_ok=True)
    
    # Configuration
    # n: number of variables
    # m: number of clauses (approx 4.3 * n for hard instances, but random for these small ones)
    
    # We want a lot of tests, so let's do more than just 10 each.
    # The user asked for "Generate a lot more small tests".
    # Let's target 50 SAT and 50 UNSAT for each variable count from 3 to 10.
    
    target_count = 50
    
    total_generated = 0
    
    for n in range(3, 11):
        # k=3 for 3-SAT (except when n < 3, but range starts at 3)
        k = 3
        if n < 3:
            k = n # Should not happen based on range
            
        # m = 4.3 * n is the phase transition, but for small n it's noisy.
        # Let's vary m slightly to ensure we get both SAT and UNSAT
        m_base = int(4.3 * n)
        
        print(f"Generating tests for {n} vars...")
        
        found_sat = 0
        found_unsat = 0
        
        # Safety break
        attempts = 0
        max_attempts = 10000 
        
        while (found_sat < target_count or found_unsat < target_count) and attempts < max_attempts:
            attempts += 1
            
            # Vary m slightly ensures we cover different densities
            m = m_base + random.randint(-2, 2)
            if m < 1: m = 1
            
            clauses = toughsat.generate_cnf(k, n, m)
            
            # Use Glucose3 solver to classify
            # We can use the same logic from toughsat.py
            with toughsat.Glucose3(bootstrap_with=clauses) as solver:
                is_sat = solver.solve()
                
                if is_sat and found_sat < target_count:
                    found_sat += 1
                    filename = os.path.join(output_dir, f"sat_{n}v_{m}c_{found_sat}.cnf")
                    toughsat.save_dimacs(filename, clauses, n, m)
                    total_generated += 1
                    
                elif not is_sat and found_unsat < target_count:
                    found_unsat += 1
                    filename = os.path.join(output_dir, f"unsat_{n}v_{m}c_{found_unsat}.cnf")
                    toughsat.save_dimacs(filename, clauses, n, m)
                    total_generated += 1

        print(f"  Finished {n} vars: {found_sat} SAT, {found_unsat} UNSAT")
        
    print(f"Total tests generated: {total_generated}")

if __name__ == "__main__":
    main()
