import re
import sys


def check_braces(filename):
    with open(filename, "r") as f:
        lines = f.readlines()

    depth = 0
    case_depth = 0
    stack = []

    print(f"Scanning {filename} for brace balance...")

    for i, line in enumerate(lines):
        line_num = i + 1200  # Offset to match grep
        stripped = line.strip()
        # Remove comments
        if "//" in stripped:
            stripped = stripped.split("//")[0]

        # Simple tokenization (flawed but good enough for this structure)
        tokens = re.findall(r"\b(begin|end|case|endcase)\b", stripped)

        for token in tokens:
            if token == "begin":
                depth += 1
                stack.append(("begin", line_num))
            elif token == "end":
                depth -= 1
                if stack and stack[-1][0] == "begin":
                    stack.pop()
                else:
                    print(f"Line {line_num}: Unmatched END. Depth: {depth}")
            elif token == "case":
                case_depth += 1
                stack.append(("case", line_num))
            elif token == "endcase":
                case_depth -= 1
                if stack and stack[-1][0] == "case":
                    stack.pop()
                else:
                    print(
                        f"Line {line_num}: Unmatched ENDCASE. Case Depth: {case_depth}"
                    )

        # Check indent? No.

        # Print status at Key States
        if "APPEND_LEARNED:" in line:
            print(f"[{line_num}] APPEND_LEARNED Start. Depth: {depth}")
        if "APPEND_PUSH:" in line:
            print(f"[{line_num}] APPEND_PUSH Start. Depth: {depth}")
        if "INJECT_RX_CLAUSE:" in line:
            print(f"[{line_num}] INJECT_RX_CLAUSE Start. Depth: {depth}")
        if "DDR_WRITE_CLAUSE:" in line:
            print(f"[{line_num}] DDR_WRITE_CLAUSE Start. Depth: {depth}")
        if "FINAL_VERIFY:" in line:
            print(f"[{line_num}] FINAL_VERIFY Start. Depth: {depth}")
        if "SAT_CHECK:" in line:
            print(f"[{line_num}] SAT_CHECK Start. Depth: {depth}")

    print(f"Final Depth: {depth}")
    print(f"Final Case Depth: {case_depth}")
    if stack:
        print("Unclosed blocks:", stack)


if __name__ == "__main__":
    check_braces(sys.argv[1])
