# AWS F1 FPGA Development & “Quick-Check” Workflow

**Executive Summary:**  EC2 F1 instances (Xilinx VU9P FPGAs) use the AWS FPGA Developer AMI (Ubuntu) as a ready FPGA dev environment. The AMI includes Xilinx Vivado/Vitis tools (no additional license fees) plus FPGA management utilities【114†L271-L276】.  Before embarking on a full Vivado build (which can take hours), engineers should use **quick-check tools** on the AMI to catch syntax, connectivity, and simple RTL errors. These include Vivado’s built-in syntax/lint commands (`check_syntax`, `xvhdl -lint`, `xvlog -sv -lint`), Vivado Simulator (XSIM) or open-source simulators (e.g. Verilator) for simple testbenches, and a short *out-of-context* synthesis or elaboration to verify basic synthesizability (e.g. `synth_design -top <module> -mode out_of_context`)【105†L210-L218】【127†L336-L344】.  Using these fast checks can save hours: AWS’s own tutorial shows that building a minimal “Hello World” CL design takes ~1.5 hours on F1【121†L318-L327】.  In contrast, a quick syntax/lint/synth check takes minutes. Once quick-check passes (no syntax/lint errors, basic connectivity okay), the engineer proceeds to the full HDK flow: source the HDK setup scripts, run the Vivado build (`aws_build_dcp_from_cl.sh` or `aws_build_dcp_from_cl.py`【121†L318-L327】) to create a Design Checkpoint (DCP), and then use the AWS CLI (`aws ec2 create-fpga-image …`) to generate the AFI【125†L30-L33】. Finally, on the F1 instance the AFI is loaded via Linux (using `fpga-manager` tools like `fpga-load-local-image`)【135†L249-L258】. This report details the key AMI packages/commands (Vivado syntax check, simulators, AWS FPGA CLIs), their integration in the AWS FPGA flow, example commands/configs, and a comparison of quick-check vs full Vivado steps, plus a brief checklist.

## AMI Tools & Commands for Quick HDL Checks

The **AWS FPGA Developer AMI** (free on AWS Marketplace) bundles a complete FPGA toolchain【114†L271-L276】. Key components for HDL quick-checks include:

- **Xilinx Vivado** (with license): Core suite for synthesis/implementation. We use Vivado CLI commands in batch mode (no GUI) to check RTL. For example:
  - `vivado -mode batch -source check_syntax.tcl`: runs Tcl commands to read HDL and perform `check_syntax` (fast syntax-only check)【105†L210-L218】.
  - `xvhdl -check_syntax design.vhd` or `xvlog -lint +all design.sv`: compile individual files with Vivado’s syntax/lint (reports typos, missing semicolons, undeclared signals).
  - `synth_design -top <top_module> -part xcvu9p`: perform a quick *out-of-context* synthesis to catch elaboration errors. This is far faster than a full build since it omits place-and-route optimizations.
  - `report_drc` and `report_timing_summary`: run basic DRC and clock checks on the partial netlist (warns of rule violations).

- **Simulation tools:** The AMI includes Vivado Simulator (XSim). Use `xvlog/xelab/xsim` for quick smoke tests: e.g. compile a small testbench (`xelab top_tb -debug all`) and simulate a few cycles. This verifies basic logic correctness. The HDK even provides a Makefile (`verif/scripts/Makefile`) to auto-run a “base test” for your CL design【127†L334-L344】. (Open-source alternatives like Verilator can also be installed on the AMI for free Verilog lint/simulation if desired.)

- **IP Integration:** Vivado’s IP catalog is available on the AMI. For new IP, use Vivado’s `pack_ip` and `import_ip` commands or scripts. Any unused IP cores in the CL design can be caught by running synthesis on the CL alone.

- **AWS FPGA SDK/CLI:** In addition to Vivado, the AMI includes the AWS FPGA SDK and CLI tools. Examples:
  - **AWS CLI:** `aws ec2 create-fpga-image …` (creates AFI from the generated DCP)【125†L30-L33】. Also `describe-fpga-images` to check status.
  - **FPGA Management Tools:** After AFI creation, use `fpga-load-local-image`, `fpga-describe-local-image`, `fpga-clear-local-image`, etc. to load/inspect the AFI on an EC2 FPGA instance【135†L249-L258】. These are post-build, but part of overall flow integration.

All these tools come preinstalled or are readily available on the FPGA AMI【114†L271-L276】. The Vivado license is cloud-locked (free for F1 usage) so no manual key is needed.  

## Workflow: From Code to AFI (with Quick-Checks)

A typical FPGA design workflow on AWS F1 using quick-checks is:

1. **Write/Edit HDL (Verilog/VHDL/SystemVerilog):**  In `$CL_DIR/design/`, develop your RTL.  
2. **Initial Quick-Checks:** 
   - **Syntax/Lint:** Run Vivado syntax check and language compilers. Example commands (in a shell or Tcl script):
     ```tcl
     # check_syntax.tcl: an example Tcl script for quick syntax check
     read_verilog $CL_DIR/design/*.v
     read_vhdl  $CL_DIR/design/*.vhd
     update_compile_order -fileset sources_1
     check_syntax
     synth_design -top <top_module_name> -part xcvu9p
     opt_design
     report_drc
     exit
     ```
     Then invoke: `vivado -mode batch -source check_syntax.tcl`.  This fast flow catches typos, missing ports, illegal constructs.  
   - **Alternative Compilers:** `xvlog -sv -svlint +all $CL_DIR/design/*.sv` and `xvhdl -lang 2008 -lint $CL_DIR/design/*.vhd`. These produce compiler/linter reports.
   - **Simulation (optional but recommended):** If you have testbenches, compile and run a quick sim:  
     ```
     cd $CL_DIR/verif/scripts
     make <YourTop>_base_test  # runs XSim (Vivado Simulator) for a few cycles【127†L336-L344】
     ```  
     AWS’s CL_TEMPLATE uses such a “base test” to ensure the design compiles and simulates【127†L336-L344】. A passing sim proves basic functionality.  

3. **Review Quick-Check Results:** Address any reported errors or warnings. Fix HDL or constraints as needed. These steps should catch most trivial RTL bugs with minimal delay (seconds or minutes).  

4. **Proceed to Full Build:** Once quick-checks pass, run the full AWS FPGA HDK build:  
   ```bash
   cd $AWS_FPGA_REPO_DIR/hdk/cl/examples/<your_cl_design>
   source $AWS_FPGA_REPO_DIR/hdk_build/INSTALL/bin/hdk_setup.sh
   export CL_DIR=$(pwd)
   cd $CL_DIR/build/scripts
   ./aws_build_dcp_from_cl.sh -c <your_cl_design>
   ```
   This invokes Vivado in batch for synthesis, implementation, encryption and creates a Design Checkpoint (DCP). As AWS notes, this can take **hours** (e.g. ~1.5h for Hello World【121†L318-L327】).  

5. **AFI Creation:** After the DCP is ready (found under `build/checkpoints/to_aws/`), create the Amazon FPGA Image:  
   ```bash
   aws s3 mb s3://my-afi-bucket
   aws s3 cp $CL_DIR/build/checkpoints/to_aws/*.Developer_CL.tar s3://my-afi-bucket/dcp/
   aws s3 mb s3://my-afi-bucket/logs
   aws ec2 create-fpga-image \
       --region us-east-1 \
       --name MyAFI \
       --description "AFI for my CL design" \
       --input-storage-location Bucket=my-afi-bucket,Key=dcp/Example.CL.tar \
       --logs-storage-location  Bucket=my-afi-bucket,Key=logs
   ```  
   (See AWS CLI docs example【125†L30-L33】.) This returns an AFI ID. Use `aws ec2 describe-fpga-images` to poll until it’s `available`.  

6. **Load & Test AFI on F1 Instance:** Launch or connect to an F1 instance. Install AWS FPGA tools (`source sdk_setup.sh`). Identify FPGA slots (`fpga-describe-local-image-slots`). Then load the new AFI into an FPGA slot:
   ```
   sudo fpga-clear-local-image -S 0
   sudo fpga-load-local-image  -S 0 -l agfi-xxxxxxxxxx
   sudo fpga-describe-local-image -S 0 -H
   ```  
   (AWS provides these tools for local AFI management【135†L249-L258】.) Finally, run host-side tests to exercise the FPGA design (e.g. run the Hello World software sample).  

### Time/Resource Considerations

- **Quick-checks:**  Very fast (seconds–minutes) and CPU-light. They do *not* target performance or full implementation, so they use minimal resources. Ideal for catching early bugs.  
- **Full Vivado Build:** CPU- and memory-intensive; requires the full Vivado toolchain. Run time can be hours, and AWS may charge per-hour for long-running instances. Always be sure quick-checks have passed before committing to a full build.  
- **Decision Point:**  If quick-check or simulation fails, **fix RTL before running Vivado**. Only proceed to Vivado synthesis/implementation when all quick checks are clear.  

### Limitations and Caveats

- **Coverage:** Quick-checks catch syntax/semantic errors and some connectivity issues, but they do *not* guarantee correctness. They skip place-and-route, timing, and power analyses. A design might compile but still fail timing or logic in hardware.  
- **Constraints:** Out-of-context synth ignores shell/board constraints (e.g. pin assignments, I/O standards). Ensure critical constraints are checked later.  
- **HDK Dependencies:** The HDK’s build scripts expect certain directory structures and TCL scripts (e.g. `encrypt.tcl`, `create_dcp_from_cl.tcl`)【121†L296-L304】. These are typically scaffolded by AWS examples. Quick-check scripts should use the same top-level module names and match the project’s TCL scripts for consistency.  
- **Tool Versions:** The AMI is updated periodically. Ensure your local scripts match the Vivado version on the AMI (version shown in AWS Marketplace details).  

## Quick-Check vs. Full Vivado: A Comparison

| **Aspect**                | **Quick-Check Tools**                                   | **Full Vivado Flow**                                      |
|---------------------------|---------------------------------------------------------|-----------------------------------------------------------|
| **Invocation**            | Vivado CLI (`-mode batch` with simple Tcl or compilers)| Vivado batch with HDK scripts (synth+impl)               |
| **Syntax/Lint**           | `check_syntax`; `xvhdl -lint`; `xvlog -sv -lint` (fast)  | Implicit in Vivado compile/elaborate; errors appear later |
| **Simulation**            | Vivado XSim or Verilator for small testbench (fast)     | Not part of AFI build; post-build testing on FPGA or host |
| **Synthesis**             | Out-of-context synthesis (`synth_design`)               | Full synth→impl, using full constraints & AES encryption  |
| **Design Rule Check**     | `report_drc` on partial design (checks basic rules)     | `report_drc` + timing (`report_timing_summary`) on placed design |
| **IP Integration**        | Read/compile IP sources manually                       | Vivado IP integrator or TCL scripts handle IP bundling    |
| **Output**                | Warnings/errors only (no bitstream)                     | Bitstream `.bit` and AFI package                          |
| **Runtime**               | Seconds–minutes                                         | Minutes–hours (e.g. ~1–3 h for medium CL design)         |
| **Resource Use**          | Low (only CPU & RAM for CLI)                            | High (heavy CPU/RAM, license usage)                       |

_Table 1: Quick-check steps vs. full Vivado implementation. Quick checks are lightweight but superficial; the full build produces the FPGA bitstream/AFI._  

## Recommended Checklist for Engineers

- **Syntax & Lint:** Run `check_syntax` in Vivado or compile all RTL files with `xvlog`/`xvhdl -lint`. Fix all syntax errors.  
- **Manual Code Review:** Look for unused ports, unreset registers, combinational loops, obvious mistakes.  
- **Small Testbench:** If possible, simulate a known-safe subset of the design for a few cycles. Use XSim or Verilator. (For AWS HDK examples, run the provided `Makefile` test to ensure it compiles【127†L336-L344】.)  
- **Out-of-Context Synthesis:** Use `synth_design -mode out_of_context` on the top module to confirm it elaborates. Check logs for errors/warnings.  
- **DRC Checks:** Run `report_drc` on the synthesized design for design-rule violations.  
- **Constraint Sanity:** Ensure your `.xdc` has at least basic clocks and pins for the CL. (Quick-check may skip this, but verify before full build.)  
- **Proceed to Build:** If all above pass, launch the full HDK Vivado build (`aws_build_dcp_from_cl.sh`). Otherwise, fix issues and repeat quick-check.  
- **AFI Creation:** After successful build, use `aws ec2 create-fpga-image` (as shown in Table 1) to generate the AFI. Monitor its status with `describe-fpga-images`.  
- **Load & Test:** On F1 hardware, use `fpga-load-local-image` to program the AFI, then run hardware tests or provided examples.  

Diagrammatically, the flow is:

```mermaid
flowchart LR
    A[Write/Edit HDL Code] --> B[Quick-Check: syntax/lint, partial synth, (sim)\n• `check_syntax`, `xvhdl/xvlog -lint`, `synth_design`\n• Fix errors if any]
    B --> C{Quick-Checks OK?}
    C -- No --> A
    C -- Yes --> D[Run Full HDK Build (Vivado batch)] 
    D --> E[Generate DCP → create AFI (aws ec2 create-fpga-image)【125†L30-L33】]
    E --> F[Launch F1 Instance & Load AFI\n(`fpga-load-local-image`)【135†L249-L258】]
    F --> G[Test on FPGA/Host]
```

Each step uses AWS FPGA toolkit commands as noted. 

**Sources:** Official AWS FPGA documentation and examples【114†L271-L276】【125†L30-L33】【127†L336-L344】【121†L318-L327】【135†L249-L258】 were used, along with Xilinx Vivado references, to ensure accuracy. These include AWS’s F1/F2 instance pages, FPGA HDK tutorials, and AWS CLI docs.