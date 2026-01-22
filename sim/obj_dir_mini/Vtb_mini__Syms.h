// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTB_MINI__SYMS_H_
#define VERILATED_VTB_MINI__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtb_mini.h"

// INCLUDE MODULE CLASSES
#include "Vtb_mini___024root.h"
#include "Vtb_mini___024unit.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vtb_mini__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtb_mini* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vtb_mini___024root             TOP;

    // CONSTRUCTORS
    Vtb_mini__Syms(VerilatedContext* contextp, const char* namep, Vtb_mini* modelp);
    ~Vtb_mini__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
