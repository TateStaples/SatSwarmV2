#include "Vtb_8v_debug.h"
#include "verilated.h"
#include <memory>

int main(int argc, char **argv) {
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  contextp->commandArgs(argc, argv);

  const std::unique_ptr<Vtb_8v_debug> tb{new Vtb_8v_debug{contextp.get()}};

  // Run simulation with timing support
  // Verilator with --timing uses coroutines, we just need to call eval_step and
  // eval_end_step
  while (!contextp->gotFinish()) {
    tb->eval_step();
    tb->eval_end_step();
    // Advance time by 1 time unit each iteration
    contextp->timeInc(1);

    // Safety timeout (100M time units = ~20s at 100MHz with 5ns clock period)
    if (contextp->time() > 100000000)
      break;
  }

  tb->final();
  return 0;
}
