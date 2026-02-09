import csv
import sys
from collections import defaultdict


def analyze_benchmarks(csv_path):
    data = defaultdict(dict)

    with open(csv_path, "r") as f:
        # Read lines first to handle malformed rows manually if needed
        lines = f.readlines()

    header = lines[0].strip().split(",")

    print("## Benchmark Results Summary\n")

    malformed_count = 0

    for line in lines[1:]:
        parts = line.strip().split(",")
        if len(parts) != 7:
            # Try to recover or just skip
            malformed_count += 1
            if len(parts) > 7:
                # Check if it ends with valid data: status, cycles, time
                # e.g. ...,TIMEOUT,0,240.006
                # Try to grab the last 3 as status, cycles, time
                pass
            continue

        # Parse standard row
        # config,type,vars,filename,status,cycles,time_sec
        config = parts[0]
        typ = parts[1]
        vs = parts[2]
        filename = parts[3]
        status = parts[4]
        try:
            cycles = int(parts[5])
        except:
            cycles = 0
        try:
            time = float(parts[6])
        except:
            time = 0.0

        data[filename][config] = {
            "status": status,
            "cycles": cycles,
            "time": time,
            "type": typ,
            "vars": vs,
        }

    if malformed_count > 0:
        print(
            f"> [!NOTE]\n> Skipped {malformed_count} malformed rows in the CSV file.\n"
        )

    # Global Stats
    configurations = set()
    for f in data:
        configurations.update(data[f].keys())

    # Calculate Pass Rates
    print("### Pass Rates by Configuration")
    for config in sorted(configurations):
        passed = 0
        total = 0
        for f in data:
            if config in data[f]:
                total += 1
                if data[f][config]["status"] == "PASS":
                    passed += 1
        if total > 0:
            print(f"- **{config}**: {passed}/{total} ({passed / total * 100:.1f}%)")

    print("\n### Speedup Analysis (vs 1x1)")
    print("| File | Type | 1x1 Cycles | 2x2 Speedup | 3x3 Speedup |")
    print("|---|---|---|---|---|")

    speedups_2x2 = []
    speedups_3x3 = []

    for f, results in sorted(data.items()):
        if "1x1" not in results:
            continue

        base = results["1x1"]
        if base["status"] != "PASS" or base["cycles"] == 0:
            continue

        row_str = f"| {f} | {base['type']} | {base['cycles']:,} |"

        # 2x2
        if "2x2" in results:
            res = results["2x2"]
            if res["status"] == "PASS" and res["cycles"] > 0:
                speedup = base["cycles"] / res["cycles"]
                speedups_2x2.append(speedup)
                row_str += f" **{speedup:.2f}x** |"
            else:
                row_str += f" {res['status']} |"
        else:
            row_str += " - |"

        # 3x3
        if "3x3" in results:
            res = results["3x3"]
            if res["status"] == "PASS" and res["cycles"] > 0:
                speedup = base["cycles"] / res["cycles"]
                speedups_3x3.append(speedup)
                row_str += f" **{speedup:.2f}x** |"
            else:
                row_str += f" {res['status']} |"
        else:
            row_str += " - |"

        print(row_str)

    if speedups_2x2:
        print(
            f"\n**Average 2x2 Speedup**: {sum(speedups_2x2) / len(speedups_2x2):.2f}x"
        )
    if speedups_3x3:
        print(f"**Average 3x3 Speedup**: {sum(speedups_3x3) / len(speedups_3x3):.2f}x")


if __name__ == "__main__":
    analyze_benchmarks(
        "/Users/tatestaples/Code/SatSwarmV2/benchmark_results/hw_benchmark_results.csv"
    )
