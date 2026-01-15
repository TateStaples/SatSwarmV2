#!/bin/bash
# Run new CAE FUIP test
set -e

SV_DIR="sim/sv"
OBJ_DIR="sim/obj_dir/tb_cae_fuip_dir"
mkdir -p $OBJ_DIR

echo "Compiling tb_cae_fuip..."
verilator --binary -j 4 --trace \
    -Isrc/Mega \
    -Isim/sv \
    src/Mega/cae.sv \
    $SV_DIR/tb_cae_fuip.sv \
    --top-module tb_cae_fuip \
    --Mdir $OBJ_DIR \
    -o tb_cae_fuip \
    -Wno-WIDTH \
    -Wno-CASEINCOMPLETE \
    -Wno-UNOPTFLAT \
    -Wno-INITIALDLY \
    -Wno-LATCH

echo "Running simulation..."
$OBJ_DIR/tb_cae_fuip
