#include "Vtb_vde.h"
#include "verilated.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vtb_vde* top = new Vtb_vde{contextp};

    while (!contextp->gotFinish()) {
        contextp->timeInc(1);
        top->eval();
    }
    
    // Check if test passed (exit code usually 0, but we parse output)
    delete top;
    delete contextp;
    return 0;
}
