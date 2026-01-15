#include "Vtb_hw_bench.h"
#include "verilated.h"
#include <memory>
int main(int argc, char** argv) {
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->commandArgs(argc, argv);
    const std::unique_ptr<Vtb_hw_bench> tb{new Vtb_hw_bench{contextp.get()}};
    while (!contextp->gotFinish()) {
        tb->eval_step(); tb->eval_end_step(); contextp->timeInc(1);
        if (contextp->time() > 100000000) break;
    }
    tb->final(); return 0;
}
