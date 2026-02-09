// C++ driver for Mini 3x3 Mesh testbench
#include "Vtb_mini_mesh_3x3.h"
#include "verilated.h"

int main(int argc, char **argv) {
  VerilatedContext context;
  context.commandArgs(argc, argv);
  Vtb_mini_mesh_3x3 top{&context};

  const vluint64_t max_time = 200000000000ULL;
  while (!context.gotFinish() && context.time() < max_time) {
    context.timeInc(1);
    top.eval();
  }
  return context.gotFinish() ? 0 : 1;
}
