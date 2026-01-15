#include "Vtb_single_core_only.h"
#include "verilated.h"

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  VerilatedContext context;
  Vtb_single_core_only top{&context};

  // Simple time advance loop
  const vluint64_t max_time = 100000000000ULL; // ~16.7 minutes @ 10ns per tick
  while (!context.gotFinish() && context.time() < max_time) {
    context.timeInc(1);
    top.eval();
  }
  return context.gotFinish() ? 0 : 1;
}
