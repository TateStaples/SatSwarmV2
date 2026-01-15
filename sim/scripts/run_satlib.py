#!/usr/bin/env python3
import argparse
import os
import re
import random
import subprocess
import sys

def get_variable_count(filename):
    """
    Extracts the variable count from SATLIB filenames.
    Matches uuf50-01.cnf or uf50-01.cnf -> 50 variables.
    """
    match = re.search(r'(?:u)?uf(\d+)-', filename)
    if match:
        return int(match.group(1))
    return None

def find_cnf_files(root_dirs):
    """
    Recursively finds all .cnf files in the given directories.
    """
    cnf_files = []
    for root_dir in root_dirs:
        for root, _, files in os.walk(root_dir):
            for file in files:
                if file.endswith('.cnf'):
                    cnf_files.append(os.path.join(root, file))
    return cnf_files

def main():
    parser = argparse.ArgumentParser(description="Run SATLIB examples with filtering and randomization.")
    parser.add_argument("command", help="The command/script to run on each CNF file (e.g., ./test.sh)")
    parser.add_argument("-vars", "--vars", type=int, required=True, help="Run tests with this many variables or fewer")
    parser.add_argument("-tests", "--tests", type=int, help="Number of random tests to run (optional)")
    parser.add_argument("--dry-run", action="store_true", help="Print what would be run without executing")
    
    args = parser.parse_args()
    
    # Directories to search
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    search_dirs = [
        os.path.join(base_dir, 'tests', 'satlib'),
        os.path.join(base_dir, 'tests', 'focused_satlib'),
    ]
    
    print(f"Searching for CNF files in: {search_dirs}")
    all_files = find_cnf_files(search_dirs)
    print(f"Found {len(all_files)} total CNF files.")
    
    # Filter by variable count
    filtered_files = []
    for f in all_files:
        basename = os.path.basename(f)
        var_count = get_variable_count(basename)
        if var_count is not None and var_count <= args.vars:
            filtered_files.append(f)
    
    print(f"Filtered down to {len(filtered_files)} files with <= {args.vars} variables.")
    
    # Random selection
    if args.tests is not None and args.tests < len(filtered_files):
        print(f"Randomly selecting {args.tests} files...")
        selected_files = random.sample(filtered_files, args.tests)
    else:
        selected_files = filtered_files
        
    print(f"Running {len(selected_files)} tests...")
    print("-" * 40)
    
    # Execute
    passed = 0
    failed = 0
    
    for i, filepath in enumerate(selected_files):
        cmd = f"{args.command} {filepath}"
        prefix = f"[{i+1}/{len(selected_files)}] "
        
        if args.dry_run:
            print(f"{prefix}Would run: {cmd}")
            continue
            
        print(f"{prefix}Running: {cmd}")
        sys.stdout.flush()
        
        try:
            # We use shell=True to easily handle arguments in the command string
            result = subprocess.run(cmd, shell=True)
            if result.returncode == 0:
                passed += 1
            else:
                failed += 1
        except KeyboardInterrupt:
            print("\nInterrupted by user.")
            sys.exit(1)
        except Exception as e:
            print(f"Error executing command: {e}")
            failed += 1
            
    if not args.dry_run:
        print("-" * 40)
        print(f"Summary: {passed} passed, {failed} failed out of {len(selected_files)} tests.")

if __name__ == "__main__":
    main()
