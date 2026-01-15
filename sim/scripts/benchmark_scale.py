#!/usr/bin/env python3
"""
VeriSAT Scalability Benchmark
Tests hardware simulation against Python reference to find max problem size.
Uses toughsat.py-style generation with PySAT for validation.
"""

import os
import sys
import time
import random
import subprocess
import tempfile

# Add the tests directory for toughsat imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)) + '/../tests')

from pysat.solvers import Glucose3

def generate_cnf(k, n, m, seed=None):
    """Generates a random k-SAT instance in list-of-lists format."""
    if seed is not None:
        random.seed(seed)
    vars_list = list(range(1, n + 1))
    clauses = []
    for _ in range(m):
        rand_vars = random.sample(vars_list, min(k, n))
        clause = []
        for var in rand_vars:
            if random.randint(0, 1) == 1:
                clause.append(-var)
            else:
                clause.append(var)
        clauses.append(clause)
    return clauses

def save_dimacs(filename, clauses, n, m):
    with open(filename, 'w') as f:
        f.write(f"p cnf {n} {m}\n")
        for clause in clauses:
            f.write(" ".join(map(str, clause)) + " 0\n")

def check_sat_glucose(clauses):
    """Check SAT/UNSAT using Glucose3 and measure time."""
    start = time.time()
    with Glucose3(bootstrap_with=clauses) as solver:
        is_sat = solver.solve()
    elapsed = time.time() - start
    return is_sat, elapsed

def run_python_sim(cnf_file, timeout=30):
    """Run Python simulation and measure time."""
    gen_trace_path = os.path.dirname(os.path.abspath(__file__)) + '/gen_trace.py'
    start = time.time()
    try:
        result = subprocess.run(
            ['python3', gen_trace_path, cnf_file],
            capture_output=True,
            text=True,
            timeout=timeout
        )
        elapsed = time.time() - start
        
        # Parse result
        output = result.stdout
        if 'Final Result: UNSAT' in output:
            return 'UNSAT', elapsed
        elif 'Final Result: SAT' in output:
            return 'SAT', elapsed
        else:
            return 'ERROR', elapsed
    except subprocess.TimeoutExpired:
        return 'TIMEOUT', timeout

def run_hardware_sim(cnf_file, timeout=60):
    """Run hardware simulation and measure time."""
    hw_exec = os.path.dirname(os.path.abspath(__file__)) + '/obj_dir/Vtb_8v_debug'
    
    if not os.path.exists(hw_exec):
        return 'NOT_BUILT', 0
    
    # We need to modify the testbench to load a different file, or create a simpler approach
    # For now, measure using direct execution with timeout
    start = time.time()
    try:
        result = subprocess.run(
            [hw_exec],
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=os.path.dirname(os.path.abspath(__file__))
        )
        elapsed = time.time() - start
        
        output = result.stdout
        if 'Result:   UNSAT' in output or 'Result: UNSAT' in output:
            # Extract cycle count
            import re
            match = re.search(r'Cycles: (\d+)', output)
            cycles = int(match.group(1)) if match else 0
            return 'UNSAT', elapsed, cycles
        elif 'Result:   SAT' in output or 'Result: SAT' in output:
            match = re.search(r'Cycles: (\d+)', output)
            cycles = int(match.group(1)) if match else 0
            return 'SAT', elapsed, cycles
        else:
            return 'ERROR', elapsed, 0
    except subprocess.TimeoutExpired:
        return 'TIMEOUT', timeout, 0

def benchmark_size(n_vars, n_clauses, k=3, num_trials=3):
    """Benchmark a specific problem size."""
    print(f"\n{'='*60}")
    print(f"Testing: {n_vars} vars, {n_clauses} clauses (3-SAT)")
    print(f"{'='*60}")
    
    results = {
        'sat_count': 0, 'unsat_count': 0,
        'python_times': [], 'hw_times': [], 'hw_cycles': [],
        'timeouts': 0
    }
    
    for trial in range(num_trials):
        seed = 42 + trial * 1000 + n_vars * 100
        clauses = generate_cnf(k, n_vars, n_clauses, seed=seed)
        
        # First check with Glucose (fast, authoritative)
        is_sat, glucose_time = check_sat_glucose(clauses)
        result_type = 'SAT' if is_sat else 'UNSAT'
        
        if is_sat:
            results['sat_count'] += 1
        else:
            results['unsat_count'] += 1
        
        print(f"  Trial {trial+1}: Glucose says {result_type} ({glucose_time:.3f}s)")
        
        # Save to temp file for Python sim test
        with tempfile.NamedTemporaryFile(mode='w', suffix='.cnf', delete=False) as f:
            f.write(f"p cnf {n_vars} {n_clauses}\n")
            for clause in clauses:
                f.write(" ".join(map(str, clause)) + " 0\n")
            temp_cnf = f.name
        
        try:
            # Test Python simulation
            py_result, py_time = run_python_sim(temp_cnf, timeout=30)
            if py_result == 'TIMEOUT':
                print(f"    Python: TIMEOUT (>30s)")
                results['timeouts'] += 1
            else:
                results['python_times'].append(py_time)
                print(f"    Python: {py_result} in {py_time:.2f}s")
                
                # Verify correctness
                if py_result != result_type:
                    print(f"    ⚠️ Python disagrees with Glucose!")
        finally:
            os.unlink(temp_cnf)
    
    # Report summary
    print(f"\nSummary for {n_vars} vars, {n_clauses} clauses:")
    print(f"  SAT: {results['sat_count']}/{num_trials}, UNSAT: {results['unsat_count']}/{num_trials}")
    if results['python_times']:
        avg_py = sum(results['python_times']) / len(results['python_times'])
        print(f"  Python avg time: {avg_py:.3f}s")
    if results['timeouts'] > 0:
        print(f"  Timeouts: {results['timeouts']}")
    
    return results

def main():
    print("="*60)
    print("VeriSAT Scalability Benchmark")
    print("="*60)
    print("Finding maximum problem size for reasonable simulation time")
    print("Using 3-SAT with clause/var ratio ~4.3 (phase transition)")
    print()
    
    # Test sizes at the phase transition ratio for 3-SAT (~4.3 clauses/var)
    # This produces the hardest instances
    test_configs = [
        (8, 34),    # 8 vars, ~4.3 ratio
        (10, 43),   # 10 vars
        (12, 52),   # 12 vars
        (15, 65),   # 15 vars
        (20, 86),   # 20 vars
        (25, 108),  # 25 vars
        (30, 129),  # 30 vars
        (40, 172),  # 40 vars
        (50, 215),  # 50 vars
    ]
    
    for n_vars, n_clauses in test_configs:
        results = benchmark_size(n_vars, n_clauses, k=3, num_trials=3)
        
        # Stop if we hit too many timeouts
        if results['timeouts'] >= 2:
            print(f"\n⚠️ Too many timeouts at {n_vars} vars, stopping")
            break
        
        # Stop if average time is too long
        if results['python_times'] and sum(results['python_times'])/len(results['python_times']) > 20:
            print(f"\n⚠️ Python too slow at {n_vars} vars, stopping")
            break
    
    print("\n" + "="*60)
    print("Benchmark Complete")
    print("="*60)

if __name__ == "__main__":
    main()
