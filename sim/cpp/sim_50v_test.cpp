#include "Vtb_50v_test.h"
#include "verilated.h"
#include <memory>

int main(int argc, char **argv) {
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  contextp->commandArgs(argc, argv);
  const std::unique_ptr<Vtb_50v_test> tb{new Vtb_50v_test{contextp.get()}};

  while (!contextp->gotFinish()) {
    tb->eval_step();
    tb->eval_end_step();
    contextp->timeInc(1);
    if (contextp->time() > 500000000)
      break;
  }

  tb->final();
  return 0;
}
