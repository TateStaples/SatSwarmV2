#include "Vtb_cae_fuip.h"
#include "verilated.h"
#include <memory>

int main(int argc, char** argv) {
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->commandArgs(argc, argv);

    const std::unique_ptr<Vtb_cae_fuip> top{new Vtb_cae_fuip{contextp.get()}};

    while (!contextp->gotFinish()) {
        contextp->timeInc(1);
        top->eval();
    }

    top->final();
    return 0;
}
