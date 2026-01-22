// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mini.h for the primary calling header

#include "Vtb_mini__pch.h"

void Vtb_mini___024unit___ctor_var_reset(Vtb_mini___024unit* vlSelf);

void Vtb_mini___024unit::ctor(Vtb_mini__Syms* symsp, const char* namep) {
    vlSymsp = symsp;
    vlNamep = strdup(Verilated::catName(vlSymsp->name(), namep));
    // Reset structure values
    Vtb_mini___024unit___ctor_var_reset(this);
}

void Vtb_mini___024unit::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

void Vtb_mini___024unit::dtor() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
