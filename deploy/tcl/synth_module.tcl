# =============================================================================
# Per-module Out-of-Context synthesis for BRAM/LUTRAM inference verification.
# Targets xcvu47p-fsvh2892-2-e (same part as the full AWS CL build).
# Completes in ~5-15 minutes, surfacing RAM inference failures long before
# Technology Mapping in the full flow.
#
# Usage (via check_inference.sh wrapper, recommended):
#   bash deploy/check_inference.sh <module_name>
#
# Direct usage (after sourcing Vivado settings64.sh):
#   vivado -mode batch -nojournal -nolog \
#          -source deploy/tcl/synth_module.tcl \
#          -tclargs <module_name> [rtl_dir]
#
# Arguments:
#   argv[0]  module_name  — top module name, e.g. pse, trail_manager, vde_heap
#   argv[1]  rtl_dir      — optional override for src/Mega directory path
#
# Environment variable overrides (fallbacks if argv not provided):
#   SYNTH_MODULE   — module name
#   SATSWARM_RTL   — path to src/Mega directory
# =============================================================================

# ── Argument handling ────────────────────────────────────────────────────────
if {[llength $argv] >= 1 && [lindex $argv 0] ne ""} {
    set MODULE_NAME [lindex $argv 0]
} elseif {[info exists ::env(SYNTH_MODULE)] && $::env(SYNTH_MODULE) ne ""} {
    set MODULE_NAME $::env(SYNTH_MODULE)
} else {
    puts "ERROR: No module name supplied."
    puts "  Usage: vivado ... -tclargs <module_name>"
    puts "  or:    SYNTH_MODULE=<module_name> vivado ..."
    exit 1
}

# Script lives at deploy/tcl/; project root is two levels up.
set SCRIPT_DIR  [file dirname [file normalize [info script]]]
set PROJECT_DIR [file normalize "$SCRIPT_DIR/../.."]

if {[llength $argv] >= 2 && [lindex $argv 1] ne ""} {
    set RTL_DIR [lindex $argv 1]
} elseif {[info exists ::env(SATSWARM_RTL)] && $::env(SATSWARM_RTL) ne ""} {
    set RTL_DIR $::env(SATSWARM_RTL)
} else {
    set RTL_DIR "$PROJECT_DIR/src/Mega"
}

set PART "xcvu47p-fsvh2892-2-e"

puts "============================================================"
puts "SatSwarm per-module OOC synthesis — BRAM inference check"
puts "============================================================"
puts "Module : $MODULE_NAME"
puts "RTL dir: $RTL_DIR"
puts "Part   : $PART"
puts "============================================================"

# ── Verify the target module source file exists ──────────────────────────────
set MODULE_SV "$RTL_DIR/${MODULE_NAME}.sv"
if {![file exists $MODULE_SV]} {
    puts "ERROR: Source file not found: $MODULE_SV"
    exit 1
}

# ── Read sources ─────────────────────────────────────────────────────────────
# Package files must be read first.  mega_pkg is imported by trail_manager
# and others; satswarmv2_pkg provides global parameters for the solver.
puts "\n>>> Reading package files..."
foreach pkg_file [list \
    "$RTL_DIR/mega_pkg.sv" \
    "$RTL_DIR/satswarmv2_pkg.sv" \
] {
    if {[file exists $pkg_file]} {
        puts "  [file tail $pkg_file]"
        read_verilog -sv $pkg_file
    }
}

# Utils (sfifo, stack, cl_sda_slv) — exclude tb_utils* (simulation-only).
puts "\n>>> Reading utils..."
foreach f [glob -nocomplain "$RTL_DIR/utils/*.sv"] {
    set tail [file tail $f]
    if {![string match "tb_utils*" $tail]} {
        puts "  $tail"
        read_verilog -sv $f
    }
}

# Target module itself.
puts "\n>>> Reading target module: [file tail $MODULE_SV]"
read_verilog -sv $MODULE_SV

# ── Synthesis ────────────────────────────────────────────────────────────────
# -mode out_of_context: synthesizes the module standalone; Vivado auto-black-
#   boxes any submodule instantiations not provided — this is intentional and
#   keeps the run fast.
# -directive RuntimeOptimized: the lightest-weight strategy.  We only care
#   about RAM inference messages, not timing closure.
# -global_retiming off: matches the full CL synthesis settings.
puts "\n>>> Running OOC synthesis..."
synth_design \
    -mode out_of_context \
    -top  $MODULE_NAME \
    -part $PART \
    -flatten_hierarchy rebuilt \
    -directive RuntimeOptimized \
    -global_retiming off

# ── Reports ──────────────────────────────────────────────────────────────────
set OUT_DIR "/tmp/synth_module_${MODULE_NAME}"
file mkdir $OUT_DIR

puts "\n>>> Writing reports to $OUT_DIR/ ..."

report_utilization \
    -file "$OUT_DIR/utilization.rpt"

report_utilization \
    -hierarchical \
    -file "$OUT_DIR/utilization_hier.rpt"

# ── Parse utilization for key RAM primitives ─────────────────────────────────
puts "\n>>> Utilization summary (RAM primitives):"
catch {
    set fh [open "$OUT_DIR/utilization.rpt" r]
    set content [read $fh]
    close $fh
    foreach line [split $content "\n"] {
        if {[regexp -nocase {RAMB|RAM16|RAM32|LUT RAM|LUTRAM|CLB LUT|CLB Reg|Block RAM} $line]} {
            puts "  $line"
        }
    }
}

# ── Scan Vivado message log for inference pass/fail codes ────────────────────
# Vivado writes its message log to vivado.log in the working directory when
# running in batch mode without -nolog.  When -nolog is used (as check_inference.sh
# does), stdout IS the log — the wrapper redirects it to /tmp/synth_<module>.log
# and then greps that file.  We emit clearly-labelled summary lines here so the
# wrapper can find them easily.
puts "\n>>> RAM inference summary:"
puts "INFERENCE_CHECK_BEGIN"

# Walk synthesis messages via get_msgs.
set dissolved_count 0
set multiport_count 0
set inferred_count  0
set bram_count_msg  0

# Walk every message in the active run.  get_msgs returns a list of message
# objects; each has -id, -severity, and -msg_text properties.
catch {
    foreach msg [get_msgs -filter {SEVERITY =~ "WARNING" || SEVERITY =~ "CRITICAL WARNING" || SEVERITY =~ "INFO"}] {
        set id  [get_property ID  $msg]
        set txt [get_property MSG_TEXT $msg]
        # [Synth 8-3390] — "RAM ... is being implemented as LUT RAM"
        #   (only a problem if the array was marked block — for distributed it's OK)
        # [Synth 8-3391] — "cannot infer RAM due to write port conflicts / multi-driver"
        # [Synth 8-4767] — "RAM ... inferred" (success for distributed/block)
        # [Synth 8-13159] — RAMB36 / RAMB18 inferred (success for block)
        switch -glob -- $id {
            "Synth 8-3391" { incr dissolved_count; puts "  FAIL [Synth 8-3391]: $txt" }
            "Synth 8-3390" { incr dissolved_count; puts "  FAIL [Synth 8-3390]: $txt" }
            "Synth 8-4767" { incr inferred_count;  puts "  OK   [Synth 8-4767]: $txt" }
            "Synth 8-13159"{ incr bram_count_msg;  puts "  OK   [Synth 8-13159]: $txt" }
        }
    }
}

puts "INFERENCE_CHECK_END"
puts ""
puts "  Dissolved/multi-port errors : $dissolved_count"
puts "  Distributed RAM inferred    : $inferred_count"
puts "  Block RAM inferred          : $bram_count_msg"

# ── Exit code reflects inference result ──────────────────────────────────────
if {$dissolved_count > 0} {
    puts "\nRESULT: FAIL — $dissolved_count RAM(s) dissolved into FFs or have multi-port write conflicts."
    puts "        Fix the write patterns and re-run check_inference.sh."
    exit 1
} else {
    puts "\nRESULT: PASS — No RAM dissolution or multi-port errors detected."
    exit 0
}
