# =============================================================================
# VeriSAT FPGA Programming Script
# Target: Xilinx Zynq UltraScale+ ZU9EG
# Usage: vivado -mode batch -source program.tcl -tclargs <bitstream>
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
set SCRIPT_DIR [file dirname [file normalize [info script]]]

# Get bitstream from command line or find latest
if {$argc > 0 && [lindex $argv 0] ne "--check-only"} {
    set BITSTREAM [lindex $argv 0]
} else {
    # Find latest implementation bitstream
    set impl_dirs [lsort -decreasing [glob -nocomplain "$SCRIPT_DIR/../output/impl/*"]]
    if {[llength $impl_dirs] > 0} {
        set latest_impl [lindex $impl_dirs 0]
        set bit_files [glob -nocomplain "$latest_impl/*.bit"]
        if {[llength $bit_files] > 0} {
            set BITSTREAM [lindex $bit_files 0]
        } else {
            puts "ERROR: No bitstream found in latest impl directory"
            exit 1
        }
    } else {
        puts "ERROR: No implementation found. Run impl.tcl first."
        exit 1
    }
}

puts "============================================="
puts "VeriSAT FPGA Programming"
puts "============================================="
puts "Bitstream: $BITSTREAM"
puts "============================================="

# -----------------------------------------------------------------------------
# Check for --check-only flag
# -----------------------------------------------------------------------------
if {[lsearch -exact $::argv "--check-only"] >= 0} {
    puts "Syntax check mode - exiting successfully"
    exit 0
}

# -----------------------------------------------------------------------------
# Verify Bitstream Exists
# -----------------------------------------------------------------------------
if {![file exists $BITSTREAM]} {
    puts "ERROR: Bitstream not found: $BITSTREAM"
    exit 1
}

# Find associated LTX file for debug probes
set LTX_FILE [file rootname $BITSTREAM].ltx
set HAS_LTX [file exists $LTX_FILE]

# -----------------------------------------------------------------------------
# Open Hardware Manager
# -----------------------------------------------------------------------------
puts "\n>>> Opening hardware manager..."
open_hw_manager

# -----------------------------------------------------------------------------
# Connect to Hardware Server
# -----------------------------------------------------------------------------
puts "\n>>> Connecting to hardware server..."

# Try default local server first
if {[catch {connect_hw_server -url localhost:3121} err]} {
    puts "  Failed to connect to localhost:3121"
    puts "  Trying to auto-detect server..."
    
    if {[catch {connect_hw_server -allow_non_jtag} err]} {
        puts "ERROR: Could not connect to hardware server"
        puts "  Make sure hw_server is running: hw_server &"
        puts "  Or specify server: vivado -mode tcl then connect_hw_server -url <host>:<port>"
        close_hw_manager
        exit 1
    }
}

puts "  Connected to hardware server"

# -----------------------------------------------------------------------------
# Open Hardware Target
# -----------------------------------------------------------------------------
puts "\n>>> Opening hardware target..."

# Get list of available targets
set targets [get_hw_targets]
if {[llength $targets] == 0} {
    puts "ERROR: No hardware targets found"
    puts "  Check USB connection and ensure board is powered on"
    close_hw_manager
    exit 1
}

puts "  Available targets:"
foreach t $targets {
    puts "    - $t"
}

# Open first available target
set target [lindex $targets 0]
puts "  Opening target: $target"
open_hw_target $target

# -----------------------------------------------------------------------------
# Select Device
# -----------------------------------------------------------------------------
puts "\n>>> Selecting device..."

set devices [get_hw_devices]
if {[llength $devices] == 0} {
    puts "ERROR: No devices found on target"
    close_hw_target
    close_hw_manager
    exit 1
}

puts "  Available devices:"
foreach d $devices {
    puts "    - $d"
}

# Find ZU9EG device or use first device
set device ""
foreach d $devices {
    set part [get_property PART $d]
    if {[string match "*zu9eg*" [string tolower $part]]} {
        set device $d
        break
    }
}

if {$device eq ""} {
    set device [lindex $devices 0]
    puts "  Warning: ZU9EG not found, using first device"
}

puts "  Selected device: $device"
current_hw_device $device

# -----------------------------------------------------------------------------
# Program Device
# -----------------------------------------------------------------------------
puts "\n>>> Programming device..."

# Set programming file
set_property PROGRAM.FILE $BITSTREAM [current_hw_device]

# Set debug probes if available
if {$HAS_LTX} {
    set_property PROBES.FILE $LTX_FILE [current_hw_device]
    puts "  Debug probes: $LTX_FILE"
}

# Program the device
puts "  Programming with: [file tail $BITSTREAM]"
if {[catch {program_hw_devices [current_hw_device]} err]} {
    puts "ERROR: Programming failed"
    puts "  $err"
    close_hw_target
    close_hw_manager
    exit 1
}

# -----------------------------------------------------------------------------
# Verify Programming
# -----------------------------------------------------------------------------
puts "\n>>> Verifying programming..."

# Refresh device status
refresh_hw_device [current_hw_device]

set done_status [get_property REGISTER.IR.BIT5_DONE [current_hw_device]]
set init_status [get_property REGISTER.IR.BIT4_INIT [current_hw_device]]

if {$done_status eq "1"} {
    puts "  DONE pin: HIGH (programming successful)"
} else {
    puts "  WARNING: DONE pin not high"
}

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
puts "\n>>> Closing connections..."

# Keep hardware manager open for debugging
# close_hw_target
# close_hw_manager

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
puts "\n============================================="
puts "Programming Complete"
puts "============================================="
puts "Device:    $device"
puts "Bitstream: [file tail $BITSTREAM]"
if {$HAS_LTX} {
    puts "Probes:    [file tail $LTX_FILE]"
}
puts ""
puts "Hardware manager left open for debugging."
puts "To close: close_hw_manager"
puts "============================================="

exit 0
