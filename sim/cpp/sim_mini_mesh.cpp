// C++ driver for Mini 2-Core Mesh testbench
#include "Vtb_mini_mesh.h"
#include "verilated.h"

int main(int argc, char **argv) {
  VerilatedContext context;
  context.commandArgs(argc, argv);
  Vtb_mini_mesh top{&context};

  // Time advance loop - run until testbench calls $finish or timeout
  const vluint64_t max_time = 100000000000ULL;
  while (!context.gotFinish() && context.time() < max_time) {
    context.timeInc(1);
    top.eval();
  }
  return context.gotFinish() ? 0 : 1;
}
