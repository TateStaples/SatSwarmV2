# =============================================================================
# resume_from_phys_opt.tcl
#
# Resumes a SatSwarm build from an existing post_phys_opt.dcp checkpoint.
# Runs route_design, writes post_route.dcp, timing report, and debug probes.
#
# Required env vars (set by resume_and_continue.sh):
#   CL_DIR   - path to cl_satswarm CL directory
#   BUILD_TAG - timestamp tag matching the checkpoint (e.g. 2026_03_26-140059)
# =============================================================================

proc print {message} {
    set prefix "\nAWS FPGA: ([clock format [clock seconds] -format %T]): "
    puts "${prefix}${message}\n"
}

proc check_timing_path {} {
    set setupPaths [get_timing_paths -max_paths 1 -slack_lesser_than 0 -setup]
    set holdPaths  [get_timing_paths -max_paths 1 -slack_lesser_than 0 -hold]
    if {[llength $setupPaths] == 0 && [llength $holdPaths] == 0} {
        return 0
    }
    return 1
}

set CL  "cl_satswarm"
set TAG $::env(BUILD_TAG)
set CL_DIR $::env(CL_DIR)

set checkpoints_dir "${CL_DIR}/build/checkpoints"
set reports_dir     "${CL_DIR}/build/reports"

print "Resuming from post_phys_opt checkpoint (TAG=${TAG})"
open_checkpoint ${checkpoints_dir}/${CL}.${TAG}.post_phys_opt.dcp

print "Start routing customer design ${CL}"
route_design -directive Default -tns_cleanup

print "Writing post-route design checkpoint and report"

set failPath [check_timing_path]
if {$failPath > 0} {
    print "WARNING: Timing violations detected — writing VIOLATED checkpoint"
    write_checkpoint -force ${checkpoints_dir}/${CL}.${TAG}.post_route.VIOLATED.dcp
} else {
    write_checkpoint -force ${checkpoints_dir}/${CL}.${TAG}.post_route.dcp
}

report_timing -delay_type max \
              -path_type full_clock_expanded \
              -max_paths 10 \
              -nworst 1 \
              -input_pins \
              -slice_pins \
              -sort_by group \
              -significant_digits 3 \
              -file ${reports_dir}/${CL}.${TAG}.post_route_timing.rpt

write_debug_probes -no_partial_ltxfile -force ${checkpoints_dir}/${TAG}.debug_probes.ltx

print "Finished routing customer design ${CL}"
close_design
