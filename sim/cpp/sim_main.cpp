#include "Vtb_satswarmv2.h"
#include "verilated.h"

int main(int argc, char **argv) {
  VerilatedContext context;
  context.commandArgs(argc, argv);
  Vtb_satswarmv2 top{&context};

  // Simple time advance loop; stop if the testbench calls $finish or timeout
  // hits. Allow long runs (e.g., 15-minute UNSAT) without host-side timeout.
  const vluint64_t max_time = 100000000000ULL; // ~16.7 minutes @ 10ns per tick
  while (!context.gotFinish() && context.time() < max_time) {
    context.timeInc(1);
    top.eval();
  }
  return context.gotFinish() ? 0 : 1;
}
