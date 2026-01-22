// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mini.h for the primary calling header

#ifndef VERILATED_VTB_MINI___024UNIT_H_
#define VERILATED_VTB_MINI___024UNIT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mini__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mini___024unit final {
  public:

    // INTERNAL VARIABLES
    Vtb_mini__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mini___024unit() = default;
    ~Vtb_mini___024unit() = default;
    void ctor(Vtb_mini__Syms* symsp, const char* namep);
    void dtor();
    VL_UNCOPYABLE(Vtb_mini___024unit);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
