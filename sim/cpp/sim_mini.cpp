// C++ driver for Mini DPLL testbench
#include "Vtb_mini.h"
#include "verilated.h"

int main(int argc, char **argv) {
  VerilatedContext context;
  context.commandArgs(argc, argv);
  Vtb_mini top{&context};

  // Time advance loop - run until testbench calls $finish or timeout
  const vluint64_t max_time = 100000000000ULL; // ~16.7 minutes @ 10ns per tick
  while (!context.gotFinish() && context.time() < max_time) {
    context.timeInc(1);
    top.eval();
  }
  return context.gotFinish() ? 0 : 1;
}
