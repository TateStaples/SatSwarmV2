// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mini.h for the primary calling header

#include "Vtb_mini__pch.h"

VL_ATTR_COLD void Vtb_mini___024root___eval_static(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_static\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mini__DOT__DEBUG = 0U;
    vlSelfRef.tb_mini__DOT__passed_tests = 0U;
    vlSelfRef.tb_mini__DOT__failed_tests = 0U;
    vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unsat_clauses = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done__0 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict__0 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done__1 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict__1 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__clk__0 
        = vlSelfRef.tb_mini__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__rst_n__0 
        = vlSelfRef.tb_mini__DOT__rst_n;
}

VL_ATTR_COLD void Vtb_mini___024root___eval_static__TOP(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_static__TOP\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mini__DOT__DEBUG = 0U;
    vlSelfRef.tb_mini__DOT__passed_tests = 0U;
    vlSelfRef.tb_mini__DOT__failed_tests = 0U;
    vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unsat_clauses = 0U;
}

VL_ATTR_COLD void Vtb_mini___024root___eval_initial__TOP(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_initial__TOP\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mini__DOT__clk = 0U;
}

VL_ATTR_COLD void Vtb_mini___024root___eval_final(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_final\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mini___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 2> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_mini___024root___eval_phase__stl(Vtb_mini___024root* vlSelf);

VL_ATTR_COLD void Vtb_mini___024root___eval_settle(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_settle\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mini___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("sv/tb_mini.sv", 4, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vtb_mini___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vtb_mini___024root___eval_triggers__stl(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_triggers__stl\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[1U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [1U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
    vlSelfRef.__VstlTriggered[0U] = (QData)((IData)(
                                                    ((((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict) 
                                                       != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict__0)) 
                                                      << 1U) 
                                                     | ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done) 
                                                        != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done__0)))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done__0 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict__0 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict;
    if (VL_UNLIKELY(((1U & (~ (IData)(vlSelfRef.__VstlDidInit)))))) {
        vlSelfRef.__VstlDidInit = 1U;
        vlSelfRef.__VstlTriggered[0U] = (1ULL | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (2ULL | vlSelfRef.__VstlTriggered
                                         [0U]);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mini___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vtb_mini___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 2> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mini___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 2> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mini___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @([hybrid] tb_mini.dut.u_solver.pse_done)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @([hybrid] tb_mini.dut.u_solver.pse_conflict)\n");
    }
    if ((1U & (IData)(triggers[1U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 64 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_mini___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 2> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___trigger_anySet__stl\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((2U > n));
    return (0U);
}

VL_ATTR_COLD void Vtb_mini___024root___stl_sequent__TOP__0(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___stl_sequent__TOP__0\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v;
    tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v = 0;
    // Body
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire 
        = ((IData)(vlSelfRef.tb_mini__DOT__host_load_valid) 
           & ((0U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
              | ((1U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
                 | (8U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)))));
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty 
        = ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr) 
           == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr));
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var = 0U;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned = 1U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v = 1U;
    while (((tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
             <= vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q) 
            & VL_GTES_III(32, 0x00000100U, tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v))) {
        if (((0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
              [(0x000000ffU & (tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
                               - (IData)(1U)))]) & 
             (0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var 
                = tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned = 0U;
        }
        tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
            = ((IData)(1U) + tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v);
    }
}

void Vtb_mini___024root___act_comb__TOP__0(Vtb_mini___024root* vlSelf);

VL_ATTR_COLD void Vtb_mini___024root___eval_stl(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_stl\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v;
    __Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v = 0;
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[1U])) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire 
            = ((IData)(vlSelfRef.tb_mini__DOT__host_load_valid) 
               & ((0U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
                  | ((1U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
                     | (8U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)))));
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty 
            = ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr) 
               == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr));
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned = 1U;
        __Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v = 1U;
        while (((__Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
                 <= vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q) 
                & VL_GTES_III(32, 0x00000100U, __Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v))) {
            if (((0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                  [(0x000000ffU & (__Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
                                   - (IData)(1U)))]) 
                 & (0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var 
                    = __Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned = 0U;
            }
            __Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
                = ((IData)(1U) + __Vinline__stl_sequent__TOP__0_tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v);
        }
    }
    if (((1ULL & vlSelfRef.__VstlTriggered[1U]) | (3ULL 
                                                   & vlSelfRef.__VstlTriggered
                                                   [0U]))) {
        Vtb_mini___024root___act_comb__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD bool Vtb_mini___024root___eval_phase__stl(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_phase__stl\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_mini___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vtb_mini___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vtb_mini___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vtb_mini___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mini___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mini___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @([hybrid] tb_mini.dut.u_solver.pse_done)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @([hybrid] tb_mini.dut.u_solver.pse_conflict)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(posedge tb_mini.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @(negedge tb_mini.rst_n)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_mini___024root___ctor_var_reset(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___ctor_var_reset\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_mini__DOT__clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9427860048283735637ull);
    vlSelf->tb_mini__DOT__rst_n = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8565265438735308349ull);
    vlSelf->tb_mini__DOT__host_load_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 809060729755761770ull);
    vlSelf->tb_mini__DOT__host_load_literal = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10096422108452285894ull);
    vlSelf->tb_mini__DOT__host_load_clause_end = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5581239255959256373ull);
    vlSelf->tb_mini__DOT__host_start = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6135777328820603145ull);
    vlSelf->tb_mini__DOT__host_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1202624363259408347ull);
    vlSelf->tb_mini__DOT__host_sat = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16753815768871738383ull);
    vlSelf->tb_mini__DOT__host_unsat = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8412053484459538898ull);
    vlSelf->tb_mini__DOT__DEBUG = 0;
    vlSelf->tb_mini__DOT__clause_store.atDefault().atDefault() = 0;
    vlSelf->tb_mini__DOT__passed_tests = 0;
    vlSelf->tb_mini__DOT__failed_tests = 0;
    vlSelf->tb_mini__DOT__max_cycles = 0;
    vlSelf->tb_mini__DOT__load_cnf_file__Vstatic__lit = 0;
    vlSelf->tb_mini__DOT__load_cnf_file__Vstatic__scan_result = 0;
    vlSelf->tb_mini__DOT__load_cnf_file__Vstatic__num_vars = 0;
    vlSelf->tb_mini__DOT__load_cnf_file__Vstatic__num_clauses = 0;
    vlSelf->tb_mini__DOT__load_cnf_file__Vstatic__literals.atDefault() = 0;
    vlSelf->tb_mini__DOT__load_cnf_file__Vstatic__clause_copy.atDefault() = 0;
    vlSelf->tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos = 0;
    vlSelf->tb_mini__DOT__verify_model__Vstatic__unsat_clauses = 0;
    vlSelf->tb_mini__DOT__verify_model__Vstatic__state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 4595456100524245855ull);
    vlSelf->tb_mini__DOT__verify_model__Vstatic__clause_sat = 0;
    vlSelf->tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit = 0;
    vlSelf->tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__var_idx = 0;
    vlSelf->tb_mini__DOT__run_test__Vstatic__unnamedblk7__DOT__time_ms = 0;
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__state_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 15866123941881430472ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 16209351085915977054ull);
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 17881435269688528643ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[__Vi0] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6376106097582630452ull);
    }
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 12375576537385857974ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 13914180394573329116ull);
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 17883103295283020804ull);
    }
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8063375570086569941ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17406086245311379581ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 933385096336970464ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_decision_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7290482402425773067ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_enable = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6257544062623611860ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7696201729654997626ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16866274357462691474ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11519845854863326889ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__next_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13513903231661608808ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5265356256139459984ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 459289620453863989ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11572365810563574082ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 17582481250824351064ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11492133399089562260ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i = 0;
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state[__Vi0] = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 1918486305437205272ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 11480030619784654731ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 14055862478198859545ull);
    }
    for (int __Vi0 = 0; __Vi0 < 2048; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7440585180110816991ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7961730340227757232ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7687923724919917504ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2933185592339923227ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16719048322852979755ull);
    }
    for (int __Vi0 = 0; __Vi0 < 512; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7681132903125516115ull);
    }
    for (int __Vi0 = 0; __Vi0 < 512; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2349083085778435875ull);
    }
    for (int __Vi0 = 0; __Vi0 < 2048; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 941394359101214758ull);
    }
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 18259531801554927324ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3749858356731465724ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13487744190461521783ull);
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11055922136455646595ull);
    }
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 8981683416690299908ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 5499442765029439369ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 15874415011352306448ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 10388613949033950574ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 10248237849903331787ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 14953998550578492628ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16336269615218792121ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15076471873204782953ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16083179898481029848ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 13337493183379079476ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 9319976283433698163ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11866366397388825292ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10973200964248129728ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 14410636694710446813ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 17966508612016665656ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11843304363790643407ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8251262432012542524ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 12764417918975316018ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15315321148362534960ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 476986975485564168ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7555646892132862499ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4624081926864431393ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 8465915146168966202ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 1825918604039336728ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 5551193051102858377ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6991936261479261034ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6312175367034026677ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1326041661738204408ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__i = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11412303267694246307ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9875676806310157664ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 17392699461531434599ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 12008533727136821933ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 13474272814528559273ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 13291604898097326377ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 17427026627031366958ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2771470781652457831ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2345089052350258283ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6023708294052669925ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7225369656235942307ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 2451198073734962898ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 440678580280476339ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 4024053475352140813ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk3__DOT__c = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16154145647666029015ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk3__DOT__b = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 10643112287999427294ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk3__DOT__l = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 17626747905518477261ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk3__DOT__w1_addr = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 9445423725958809118ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk3__DOT__w2_addr = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16853622384492701797ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk3__DOT__idx1 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7660148266191772840ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk3__DOT__idx2 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 10018143244448706335ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk4__DOT__v = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10837282405052396362ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk5__DOT__v = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5628139769937219649ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk6__DOT__j = 0;
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk6__DOT__unnamedblk7__DOT__lit = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 536024607520796687ull);
    vlSelf->tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk6__DOT__unnamedblk7__DOT__v = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9758394086351696447ull);
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__Vfuncout = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__raw_idx = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__5__Vfuncout = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__5__lit = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__5__v = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__6__Vfuncout = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__6__lit = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__6__v = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__lit = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__v = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__8__Vfuncout = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__8__lit = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__8__v = 0;
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__8__raw_idx = 0;
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict__0 = 0;
    vlSelf->__VstlDidInit = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_mini__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_mini__DOT__rst_n__0 = 0;
    vlSelf->__VactDidInit = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
}
