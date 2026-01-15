#include "Vtb_single_core_debug.h"
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vtb_single_core_debug* tb = new Vtb_single_core_debug;
    
    // Run simulation (testbench has its own control logic)
    while (!Verilated::gotFinish()) {
        tb->eval();
    }
    
    tb->final();
    delete tb;
    return 0;
}
