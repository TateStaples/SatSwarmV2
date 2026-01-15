// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_hw_bench.h for the primary calling header

#include "Vtb_hw_bench__pch.h"

VL_ATTR_COLD void Vtb_hw_bench___024root___eval_static(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_static\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_start__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__cae_start__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_valid__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_value__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_level__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_start__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__cae_start__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_valid__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_value__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_level__1 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__clk__0 
        = vlSelfRef.tb_hw_bench__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__rst_n__0 
        = vlSelfRef.tb_hw_bench__DOT__rst_n;
}

VL_ATTR_COLD void Vtb_hw_bench___024root___eval_final(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_final\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_hw_bench___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 2> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_hw_bench___024root___eval_phase__stl(Vtb_hw_bench___024root* vlSelf);

VL_ATTR_COLD void Vtb_hw_bench___024root___eval_settle(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_settle\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_hw_bench___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("tb_hw_bench.sv", 2, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vtb_hw_bench___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vtb_hw_bench___024root___eval_triggers__stl(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_triggers__stl\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[1U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [1U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
    vlSelfRef.__VstlTriggered[0U] = (QData)((IData)(
                                                    (((((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level) 
                                                          != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_level__0)) 
                                                         << 3U) 
                                                        | (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value) 
                                                            != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_value__0)) 
                                                           << 2U)) 
                                                       | ((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid) 
                                                            != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_valid__0)) 
                                                           << 1U) 
                                                          | ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start) 
                                                             != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__cae_start__0)))) 
                                                      << 4U) 
                                                     | (((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value) 
                                                           != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value__0)) 
                                                          << 3U) 
                                                         | ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var 
                                                             != vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var__0) 
                                                            << 2U)) 
                                                        | ((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid) 
                                                             != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid__0)) 
                                                            << 1U) 
                                                           | ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start) 
                                                              != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_start__0)))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_start__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__cae_start__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_valid__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_value__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_level__0 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level;
    if (VL_UNLIKELY(((1U & (~ (IData)(vlSelfRef.__VstlDidInit)))))) {
        vlSelfRef.__VstlDidInit = 1U;
        vlSelfRef.__VstlTriggered[0U] = (1ULL | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (2ULL | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (4ULL | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (8ULL | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (0x0000000000000010ULL 
                                         | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (0x0000000000000020ULL 
                                         | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (0x0000000000000040ULL 
                                         | vlSelfRef.__VstlTriggered
                                         [0U]);
        vlSelfRef.__VstlTriggered[0U] = (0x0000000000000080ULL 
                                         | vlSelfRef.__VstlTriggered
                                         [0U]);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_hw_bench___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vtb_hw_bench___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 2> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_hw_bench___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 2> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_hw_bench___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @([hybrid] tb_hw_bench.dut.pse_start)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @([hybrid] tb_hw_bench.dut.pse_assign_broadcast_valid)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @([hybrid] tb_hw_bench.dut.pse_assign_broadcast_var)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @([hybrid] tb_hw_bench.dut.pse_assign_broadcast_value)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @([hybrid] tb_hw_bench.dut.cae_start)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 5U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 5 is active: @([hybrid] tb_hw_bench.dut.trail_query_valid)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 6U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 6 is active: @([hybrid] tb_hw_bench.dut.trail_query_value)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 7U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 7 is active: @([hybrid] tb_hw_bench.dut.trail_query_level)\n");
    }
    if ((1U & (IData)(triggers[1U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 64 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_hw_bench___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 2> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_hw_bench___024root___stl_sequent__TOP__0(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___stl_sequent__TOP__0\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_done = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_all_assigned = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_phase = 0U;
    if ((0U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        if ((1U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
            if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
                if ((0xffffU != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var 
                        = ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q));
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_phase 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint
                        [(0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q))];
                }
                if ((0xffffU == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_all_assigned = 1U;
                }
            }
        }
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_is_decision = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_value = 0U;
    if ((0U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
        if ((1U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
            if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_done = 1U;
            }
        }
        if ((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
            if (((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q)) 
                 & ((0x0000ffffU & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                            [(0x0000003fU 
                                              & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                                 - (IData)(1U)))] 
                                            >> 1U))) 
                    > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_is_decision 
                    = (1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                    [(0x0000003fU & 
                                      ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                       - (IData)(1U)))]));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_valid = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_var 
                    = (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                               [(0x0000003fU & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                                - (IData)(1U)))] 
                               >> 0x00000012U));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_value 
                    = (1U & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                     [(0x0000003fU 
                                       & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                          - (IData)(1U)))] 
                                     >> 0x00000011U)));
            }
        }
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_max_var 
        = ((0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q)
            ? 0x00000040U : vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q);
    vlSelfRef.tb_hw_bench__DOT__load_ready = ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q)) 
                                              | (1U 
                                                 == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q)));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q;
    if ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_d = 0xffffU;
    } else if ((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q) 
             < vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_max_var)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q)));
            if ((1U & (~ vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned
                       [(0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q))]))) {
                if ((((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q))] 
                       > vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_q) 
                      | ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                          [(0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q))] 
                          == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_q) 
                         & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q) 
                            < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q)))) 
                     | (0xffffU == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q)))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_d 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                        [(0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q))];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_d 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q;
                }
            }
        }
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__load_valid) 
           & (IData)(vlSelfRef.tb_hw_bench__DOT__load_ready));
}

VL_ATTR_COLD void Vtb_hw_bench___024root___stl_comb__TOP__1(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___stl_comb__TOP__1\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i;
    tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i = 0;
    IData/*31:0*/ tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i;
    tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i = 0;
    // Body
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push_val = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_en = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_idx = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_val = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_done = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause_len = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[0U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[1U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[2U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[3U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[4U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[5U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[6U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[7U] = 0U;
    tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i = 0U;
    while (VL_GTS_III(32, 0x000000c0U, tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)) {
        if (VL_LIKELY(((0xbfU >= (0x000000ffU & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i))))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h68eec191__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1
                [(0x000000ffU & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)];
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1_d[(0x000000ffU 
                                                                              & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)] 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h68eec191__0;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_ha6773321__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2
                [(0x000000ffU & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)];
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2_d[(0x000000ffU 
                                                                              & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)] 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_ha6773321__0;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h0f6e9a5b__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1
                [(0x000000ffU & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)];
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1_d[(0x000000ffU 
                                                                             & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)] 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h0f6e9a5b__0;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h38aa84f1__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2
                [(0x000000ffU & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)];
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2_d[(0x000000ffU 
                                                                             & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i)] 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h38aa84f1__0;
        } else {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h68eec191__0 = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_ha6773321__0 = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h0f6e9a5b__0 = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h38aa84f1__0 = 0U;
        }
        tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i 
            = ((IData)(1U) + tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk3__DOT__i);
    }
    tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i = 0U;
    while (VL_GTS_III(32, 0x00000080U, tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i)) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d[(0x0000007fU 
                                                                         & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i)] 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1
            [(0x0000007fU & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i)];
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d[(0x0000007fU 
                                                                         & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i)] 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2
            [(0x0000007fU & tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i)];
        tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i 
            = ((IData)(1U) + tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk4__DOT__i);
    }
    if ((8U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 0U;
    } else if ((4U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
        if ((2U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
            if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 0U;
            } else {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_done = 1U;
                if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_d = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_d = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 2U;
                } else if ((1U & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__load_valid)))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 0U;
                }
            }
        } else if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
            if ((0xffffU == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))) {
                if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 4U;
                } else {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit 
                        = (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_q);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx 
                        = (0x0000ffffU & (VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit)
                                           ? VL_MULS_III(32, (IData)(2U), 
                                                         (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit 
                                                          - (IData)(1U)))
                                           : ((IData)(1U) 
                                              + VL_MULS_III(32, (IData)(2U), 
                                                            ((- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit) 
                                                             - (IData)(1U))))));
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_d = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d = 0xffffU;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 5U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d
                        [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx))];
                }
            } else {
                if ((0xbfU >= (0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1
                        [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2
                        [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start
                        [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len
                        [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))];
                } else {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1 = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2 = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen = 0U;
                }
                if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch 
                        = ((0x0203U >= (0x000003ffU 
                                        & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))
                            ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                           [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2))]
                            : 0U);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other 
                        = ((0x0203U >= (0x000003ffU 
                                        & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1)))
                            ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                           [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1))]
                            : 0U);
                } else {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch 
                        = ((0x0203U >= (0x000003ffU 
                                        & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1)))
                            ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                           [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1))]
                            : 0U);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other 
                        = ((0x0203U >= (0x000003ffU 
                                        & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))
                            ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                           [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2))]
                            : 0U);
                }
                vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other;
                vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__v = 0;
                {
                    vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__v 
                        = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__lit)
                            ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__lit)
                            : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__lit);
                    if (((0U == vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__v) 
                         | (0x00000040U < vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__v))) {
                        vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__Vfuncout = 0U;
                        goto __Vlabel0;
                    }
                    vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__Vfuncout 
                        = ((1U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state
                            [(0x0000003fU & (vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__v 
                                             - (IData)(1U)))])
                            ? (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__lit)
                                ? 2U : 1U) : ((2U == 
                                               vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state
                                               [(0x0000003fU 
                                                 & (vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__v 
                                                    - (IData)(1U)))])
                                               ? (VL_LTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__lit)
                                                   ? 2U
                                                   : 1U)
                                               : 0U));
                    __Vlabel0: ;
                }
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth 
                    = vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__Vfuncout;
                if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth))) {
                    if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                            = ((0xbfU >= (0x000000ffU 
                                          & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2
                               [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                : 0U);
                    } else {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                            = ((0xbfU >= (0x000000ffU 
                                          & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1
                               [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                : 0U);
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 5U;
                } else {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_idx 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                        = ((0x0203U >= (0x000003ffU 
                                        & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1)))
                            ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                           [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1))]
                            : 0U);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j = 0U;
                    {
                        while ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j 
                                < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            {
                                if (((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart) 
                                       + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j) 
                                      == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                     | (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart) 
                                         + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j) 
                                        == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                    goto __Vlabel2;
                                }
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = ((0x0203U >= 
                                        (0x000003ffU 
                                         & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart) 
                                            + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j)))
                                        ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                       [(0x000003ffU 
                                         & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart) 
                                            + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j))]
                                        : 0U);
                                vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__lit 
                                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__v = 0;
                                {
                                    vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__v 
                                        = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__lit)
                                            ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__lit)
                                            : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__lit);
                                    if (((0U == vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__v) 
                                         | (0x00000040U 
                                            < vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__v))) {
                                        vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__Vfuncout = 0U;
                                        goto __Vlabel3;
                                    }
                                    vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__Vfuncout 
                                        = ((1U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state
                                            [(0x0000003fU 
                                              & (vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__v 
                                                 - (IData)(1U)))])
                                            ? (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__lit)
                                                ? 2U
                                                : 1U)
                                            : ((2U 
                                                == 
                                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state
                                                [(0x0000003fU 
                                                  & (vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__v 
                                                     - (IData)(1U)))])
                                                ? (
                                                   VL_LTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__lit)
                                                    ? 2U
                                                    : 1U)
                                                : 0U));
                                    __Vlabel3: ;
                                }
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__t 
                                    = vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__Vfuncout;
                                if ((1U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__t))) {
                                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_idx 
                                        = (0x0000ffffU 
                                           & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart) 
                                              + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j));
                                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                    goto __Vlabel1;
                                }
                                __Vlabel2: ;
                            }
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j 
                                = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j);
                        }
                        __Vlabel1: ;
                    }
                    if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_head_idx 
                            = (0x0000ffffU & (VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit)
                                               ? VL_MULS_III(32, (IData)(2U), 
                                                             (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                                              - (IData)(1U)))
                                               : ((IData)(1U) 
                                                  + 
                                                  VL_MULS_III(32, (IData)(2U), 
                                                              ((- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit) 
                                                               - (IData)(1U))))));
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__old_head_idx 
                            = (0x0000ffffU & (VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch)
                                               ? VL_MULS_III(32, (IData)(2U), 
                                                             (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch 
                                                              - (IData)(1U)))
                                               : ((IData)(1U) 
                                                  + 
                                                  VL_MULS_III(32, (IData)(2U), 
                                                              ((- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch) 
                                                               - (IData)(1U))))));
                        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hc7e6b68a__0 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_idx;
                            if ((0xffffU == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))) {
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d[(0x0000007fU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__old_head_idx))] 
                                    = ((0xbfU >= (0x000000ffU 
                                                  & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                        ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2
                                       [(0x000000ffU 
                                         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                        : 0U);
                            } else {
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hcead6646__0 
                                    = ((0xbfU >= (0x000000ffU 
                                                  & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                        ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2
                                       [(0x000000ffU 
                                         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                        : 0U);
                                if (VL_LIKELY(((0xbfU 
                                                >= 
                                                (0x000000ffU 
                                                 & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q)))))) {
                                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))] 
                                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hcead6646__0;
                                }
                            }
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h5838062a__0 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d
                                [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_head_idx))];
                            if (VL_LIKELY(((0xbfU >= 
                                            (0x000000ffU 
                                             & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))))) {
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))] 
                                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hc7e6b68a__0;
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))] 
                                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h5838062a__0;
                            }
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d[(0x0000007fU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_head_idx))] 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                                = ((0xffffU == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d
                                   [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__old_head_idx))]
                                    : ((0xbfU >= (0x000000ffU 
                                                  & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q)))
                                        ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2_d
                                       [(0x000000ffU 
                                         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))]
                                        : 0U));
                        } else {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hc8ff74ca__0 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_idx;
                            if ((0xffffU == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))) {
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d[(0x0000007fU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__old_head_idx))] 
                                    = ((0xbfU >= (0x000000ffU 
                                                  & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                        ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1
                                       [(0x000000ffU 
                                         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                        : 0U);
                            } else {
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h89617ee6__0 
                                    = ((0xbfU >= (0x000000ffU 
                                                  & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                        ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1
                                       [(0x000000ffU 
                                         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                        : 0U);
                                if (VL_LIKELY(((0xbfU 
                                                >= 
                                                (0x000000ffU 
                                                 & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q)))))) {
                                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))] 
                                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h89617ee6__0;
                                }
                            }
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hefbe1e22__0 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d
                                [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_head_idx))];
                            if (VL_LIKELY(((0xbfU >= 
                                            (0x000000ffU 
                                             & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))))) {
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))] 
                                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hc8ff74ca__0;
                                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))] 
                                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hefbe1e22__0;
                            }
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d[(0x0000007fU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_head_idx))] 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                                = ((0xffffU == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d
                                   [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__old_head_idx))]
                                    : ((0xbfU >= (0x000000ffU 
                                                  & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q)))
                                        ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1_d
                                       [(0x000000ffU 
                                         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q))]
                                        : 0U));
                        }
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 5U;
                    } else if ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                            = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other)
                                ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other)
                                : vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_valid = 1U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other;
                        if ((((0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v) 
                              & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v)) 
                             & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state
                                [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                                                 - (IData)(1U)))]))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_en = 1U;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_idx 
                                = (0x0000ffffU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                                                  - (IData)(1U)));
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_val 
                                = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other)
                                    ? 1U : 2U);
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push = 1U;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push_val 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d 
                                = (0x0000ffffU & ((IData)(1U) 
                                                  + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q)));
                        }
                        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                                = ((0xbfU >= (0x000000ffU 
                                              & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2
                                   [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                    : 0U);
                        } else {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                                = ((0xbfU >= (0x000000ffU 
                                              & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q)))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1
                                   [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q))]
                                    : 0U);
                        }
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 5U;
                    } else {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict = 1U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_done = 1U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause_len 
                            = (0x0000000fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen));
                        if ((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[0U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))]
                                    : 0U);
                        }
                        if ((1U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[1U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & ((IData)(1U) 
                                                   + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & 
                                     ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))]
                                    : 0U);
                        }
                        if ((2U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[2U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & ((IData)(2U) 
                                                   + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & 
                                     ((IData)(2U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))]
                                    : 0U);
                        }
                        if ((3U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[3U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & ((IData)(3U) 
                                                   + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & 
                                     ((IData)(3U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))]
                                    : 0U);
                        }
                        if ((4U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[4U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & ((IData)(4U) 
                                                   + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & 
                                     ((IData)(4U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))]
                                    : 0U);
                        }
                        if ((5U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[5U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & ((IData)(5U) 
                                                   + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & 
                                     ((IData)(5U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))]
                                    : 0U);
                        }
                        if ((6U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[6U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & ((IData)(6U) 
                                                   + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & 
                                     ((IData)(6U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))]
                                    : 0U);
                        }
                        if ((7U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[7U] 
                                = ((0x0203U >= (0x000003ffU 
                                                & ((IData)(7U) 
                                                   + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))))
                                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                                   [(0x000003ffU & 
                                     ((IData)(7U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))]
                                    : 0U);
                        }
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 6U;
                    }
                }
            }
        } else if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q) 
                    == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_done = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 6U;
        } else {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_d 
                = ((0x0203U >= (0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q)))
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q
                   [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q))]
                    : 0U);
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q)));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit 
                = (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_d);
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx 
                = (0x0000ffffU & (VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit)
                                   ? VL_MULS_III(32, (IData)(2U), 
                                                 (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit 
                                                  - (IData)(1U)))
                                   : ((IData)(1U) + 
                                      VL_MULS_III(32, (IData)(2U), 
                                                  ((- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit) 
                                                   - (IData)(1U))))));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d
                [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx))];
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d = 0xffffU;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 5U;
        }
    } else if ((2U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
        if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
            if ((0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q)) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                    = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q)
                        ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q)
                        : vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q);
                if (((0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v) 
                     & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_en = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_idx 
                        = (0x0000ffffU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                                          - (IData)(1U)));
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_val 
                        = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q)
                            ? 1U : 2U);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push_val 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d 
                        = (0x0000ffffU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q)));
                }
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 4U;
        } else if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q) 
                    < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q))) {
            if ((0xbfU >= (0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__base 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start
                    [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q))];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__base;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__len 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len
                    [(0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q))];
            } else {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__base = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__base;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__len = 0U;
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2 
                = (0x0000ffffU & ((1U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__len))
                                   ? ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__base))
                                   : (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__base)));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit1 
                = ((0x0203U >= (0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1)))
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                   [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1))]
                    : 0U);
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit2 
                = ((0x0203U >= (0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem
                   [(0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2))]
                    : 0U);
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx1 
                = (0x0000ffffU & (VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit1)
                                   ? VL_MULS_III(32, (IData)(2U), 
                                                 (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit1 
                                                  - (IData)(1U)))
                                   : ((IData)(1U) + 
                                      VL_MULS_III(32, (IData)(2U), 
                                                  ((- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit1) 
                                                   - (IData)(1U))))));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx2 
                = (0x0000ffffU & (VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit2)
                                   ? VL_MULS_III(32, (IData)(2U), 
                                                 (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit2 
                                                  - (IData)(1U)))
                                   : ((IData)(1U) + 
                                      VL_MULS_III(32, (IData)(2U), 
                                                  ((- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit2) 
                                                   - (IData)(1U))))));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h81e6d567__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h7f3f1653__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h39167de9__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d
                [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx1))];
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d[(0x0000007fU 
                                                                             & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx1))] 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h1fa06947__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d
                [(0x0000007fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx2))];
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q)))))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q))] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h81e6d567__0;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q))] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h7f3f1653__0;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q))] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h39167de9__0;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2_d[(0x000000ffU 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q))] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h1fa06947__0;
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d[(0x0000007fU 
                                                                             & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx2))] 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q)));
        } else {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 3U;
        }
    } else if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) {
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q)));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q)));
            if (((VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__load_literal)
                   ? (- vlSelfRef.tb_hw_bench__DOT__load_literal)
                   : vlSelfRef.tb_hw_bench__DOT__load_literal) 
                 > vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q)) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_d 
                    = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__load_literal)
                        ? (- vlSelfRef.tb_hw_bench__DOT__load_literal)
                        : vlSelfRef.tb_hw_bench__DOT__load_literal);
            }
            if (vlSelfRef.tb_hw_bench__DOT__load_clause_end) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_d 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q)));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_d = 0U;
            }
        } else if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 2U;
        } else {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 0U;
        }
    } else if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_d 
            = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q)));
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_d 
            = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q)));
        if (((VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__load_literal)
               ? (- vlSelfRef.tb_hw_bench__DOT__load_literal)
               : vlSelfRef.tb_hw_bench__DOT__load_literal) 
             > vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_d 
                = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__load_literal)
                    ? (- vlSelfRef.tb_hw_bench__DOT__load_literal)
                    : vlSelfRef.tb_hw_bench__DOT__load_literal);
        }
        if (vlSelfRef.tb_hw_bench__DOT__load_clause_end) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q)));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_d = 0U;
        }
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 1U;
    } else if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = 2U;
    }
    if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid) 
         & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push)))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__var_idx_b 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var;
        if ((((0U < vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__var_idx_b) 
              & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__var_idx_b)) 
             & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state
                [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__var_idx_b 
                                 - (IData)(1U)))]))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push_val 
                = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value)
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__var_idx_b
                    : (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__var_idx_b));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d)));
        }
    }
}

void Vtb_hw_bench___024root___act_sequent__TOP__0(Vtb_hw_bench___024root* vlSelf);
void Vtb_hw_bench___024root___act_comb__TOP__1(Vtb_hw_bench___024root* vlSelf);

VL_ATTR_COLD void Vtb_hw_bench___024root___eval_stl(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_stl\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[1U])) {
        Vtb_hw_bench___024root___stl_sequent__TOP__0(vlSelf);
    }
    if (((1ULL & vlSelfRef.__VstlTriggered[1U]) | (0x0000000000000010ULL 
                                                   & vlSelfRef.__VstlTriggered
                                                   [0U]))) {
        Vtb_hw_bench___024root___act_sequent__TOP__0(vlSelf);
    }
    if (((1ULL & vlSelfRef.__VstlTriggered[1U]) | (0x000000000000000fULL 
                                                   & vlSelfRef.__VstlTriggered
                                                   [0U]))) {
        Vtb_hw_bench___024root___stl_comb__TOP__1(vlSelf);
    }
    if (((1ULL & vlSelfRef.__VstlTriggered[1U]) | (0x00000000000000ffULL 
                                                   & vlSelfRef.__VstlTriggered
                                                   [0U]))) {
        Vtb_hw_bench___024root___act_comb__TOP__1(vlSelf);
    }
}

VL_ATTR_COLD bool Vtb_hw_bench___024root___eval_phase__stl(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_phase__stl\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_hw_bench___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vtb_hw_bench___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vtb_hw_bench___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vtb_hw_bench___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_hw_bench___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_hw_bench___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @([hybrid] tb_hw_bench.dut.pse_start)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @([hybrid] tb_hw_bench.dut.pse_assign_broadcast_valid)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @([hybrid] tb_hw_bench.dut.pse_assign_broadcast_var)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @([hybrid] tb_hw_bench.dut.pse_assign_broadcast_value)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @([hybrid] tb_hw_bench.dut.cae_start)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 5U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 5 is active: @([hybrid] tb_hw_bench.dut.trail_query_valid)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 6U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 6 is active: @([hybrid] tb_hw_bench.dut.trail_query_value)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 7U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 7 is active: @([hybrid] tb_hw_bench.dut.trail_query_level)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 8U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 8 is active: @(posedge tb_hw_bench.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 9U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 9 is active: @(negedge tb_hw_bench.rst_n)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 0x0000000aU)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 10 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_hw_bench___024root___ctor_var_reset(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___ctor_var_reset\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_hw_bench__DOT__clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 523619526641205143ull);
    vlSelf->tb_hw_bench__DOT__rst_n = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16141090983853571657ull);
    vlSelf->tb_hw_bench__DOT__start_solve = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9696659107850794498ull);
    vlSelf->tb_hw_bench__DOT__solve_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 120783962562861654ull);
    vlSelf->tb_hw_bench__DOT__is_sat = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2180499538506164123ull);
    vlSelf->tb_hw_bench__DOT__is_unsat = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 990408955516321747ull);
    vlSelf->tb_hw_bench__DOT__load_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5168511465180769840ull);
    vlSelf->tb_hw_bench__DOT__load_literal = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10713405675865911664ull);
    vlSelf->tb_hw_bench__DOT__load_clause_end = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6864451352550069737ull);
    vlSelf->tb_hw_bench__DOT__load_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18015165879082078684ull);
    vlSelf->tb_hw_bench__DOT__cycle_count = 0;
    vlSelf->tb_hw_bench__DOT__decision_count = 0;
    vlSelf->tb_hw_bench__DOT__conflict_count = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__state_q = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 6246227428534362602ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__state_d = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 5894143383284875638ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__cycle_count_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 5313197477452800728ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__cycle_count_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 5753888343139434397ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__decision_level_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 12579055398902325526ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__decision_level_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6369890226231327233ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__prop_count_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 14935376225138090591ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__prop_count_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 2186342999884617823ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_seen_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1529739265168349543ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_seen_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16592127634868326878ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__resync_idx_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8318593402994563425ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__resync_idx_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13019446551011843642ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__resync_started_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3086885952603088583ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__resync_started_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11800812535917844447ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_started_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1188465700254228342ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_started_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15761565433596520348ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__last_decision_var_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 14916418549955173848ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__last_decision_var_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13219509769170686169ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__last_decision_phase_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2739361432749392907ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__last_decision_phase_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17232600332136723069ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__tried_both_phases_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11357593784088236512ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__tried_both_phases_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6635431863344823017ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__level0_conflict_count_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 9945359225654969091ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__level0_conflict_count_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 11428916193801488036ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_counter_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3347741860143056511ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_counter_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7865677436265539514ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__restart_count_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2277650740058961962ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__restart_count_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2898914585350702289ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__verify_mode_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17742794395023876292ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__verify_mode_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12884694483195264501ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__restart_pending_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14090851256736083880ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__restart_pending_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9395650726352706815ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__query_index_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 6136614709403677061ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__query_index_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 2863891170321598329ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_push = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7870106478430681455ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_push_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1476114390114478968ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_push_value = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3386473827320009136ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_push_level = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 17346700674613665759ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_push_is_decision = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13356819413558656413ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_backtrack_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16193494135994497429ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_backtrack_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17353418740969098226ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_backtrack_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16881197977554154598ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_backtrack_value = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11807165826882862114ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_backtrack_is_decision = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1584837063408213870ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_query_level = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7559726182073901645ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_query_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2422616327523333220ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_query_value = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2453078079652017167ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__trail_clear_all = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10258018508701905006ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_start = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12791003743129232986ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7271388931842196050ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_conflict = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17107796123392956544ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_propagated_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16394848898286683153ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_propagated_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11166985431981795626ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_clear_assignments = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7273860106251507486ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_conflict_clause_len = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 10135353244577471320ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__pse_conflict_clause[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7443564750124651541ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4058511736821823346ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1866876447822745565ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4917068831440559056ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 4400433876298816834ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_clause_len_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 15347147590452880027ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_clause_q[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10143139092597990171ull);
    }
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_clause_d[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3858630966577184959ull);
    }
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_levels_q[__Vi0] = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 11129902352438074ull);
    }
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__conflict_levels_d[__Vi0] = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 14894510302841311474ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__learn_idx_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 11549327423610628304ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__learn_idx_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 10640384314510528959ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__cae_start = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17907062683784334404ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__cae_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17447156671244017685ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__cae_learned_len = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 5590200130074018203ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__cae_learned_lits[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15905032747846357883ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__cae_backtrack_level = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 3931379136964791099ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_request = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17197668249237366833ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_decision_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10275875158045646077ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_decision_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 14867208109153792294ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_decision_phase = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7059108358136311464ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_all_assigned = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7410742696878158159ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_assign_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12174704224223295442ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_assign_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15603148652278497779ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_assign_value = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13584316698587567954ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_max_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11747678075567154058ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_clear_all = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5902975993491121631ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_clear_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5485772499572627586ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_clear_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 781258687655168685ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_bump_count = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 12496175893719178799ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__vde_bump_vars[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15474530449407708095ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__vde_decay = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13950747479719423601ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__decision_lit_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10997575504282874153ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__decision_lit_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 14319095735502474482ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_var = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10187487843392541879ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_already_assigned = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 566316167771490565ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__lit = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6435812701232220726ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__var_idx = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 113013592642015254ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 9543707170641256548ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_d = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 10867234617332309091ull);
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 41323228139911163ull);
    }
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned[__Vi0] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8499655894693897461ull);
    }
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint[__Vi0] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7655749816371841403ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10628333402584244808ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7002922350742792170ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15716095952897972856ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 12451089799448224554ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7094658106737138023ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2786740160124213813ull);
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail[__Vi0] = VL_SCOPED_RAND_RESET_Q(50, __VscopeHash, 1577166525935699683ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4663221802992346700ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6075326671592888620ull);
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15859257488626511261ull);
    }
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15706522648772887414ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 1619411398421674565ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_d = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17747375610542899538ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 1655437766792191872ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16095658542855826284ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 14208405760848144373ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16568640448077864816ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h3fedabd8__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hbcbfc3d7__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h65c98558__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h5df078f0__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h00d61c0b__1 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h29b188f6__1 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h40ce9c10__1 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h604b715b__1 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h00d61c0b__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h29b188f6__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h40ce9c10__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h604b715b__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hefbe1e22__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hc8ff74ca__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h89617ee6__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h5838062a__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hc7e6b68a__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hcead6646__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h1fa06947__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h39167de9__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h7f3f1653__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h81e6d567__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h38aa84f1__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h0f6e9a5b__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_ha6773321__0 = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h68eec191__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state[__Vi0] = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17160636690053231767ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6373059896200022121ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7672204901337385856ull);
    }
    for (int __Vi0 = 0; __Vi0 < 516; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3866671978142839362ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 742400552652351291ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6451032677237833698ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1_d[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4538181083749375097ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2_d[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2940611165623014786ull);
    }
    for (int __Vi0 = 0; __Vi0 < 128; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6113676961755346971ull);
    }
    for (int __Vi0 = 0; __Vi0 < 128; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16981223373740354084ull);
    }
    for (int __Vi0 = 0; __Vi0 < 128; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 17374996973054535505ull);
    }
    for (int __Vi0 = 0; __Vi0 < 128; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 5271481220846002382ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2524664441957884797ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 18194743390865856160ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1_d[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 10987722314659300374ull);
    }
    for (int __Vi0 = 0; __Vi0 < 192; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2_d[__Vi0] = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6979871962395307531ull);
    }
    for (int __Vi0 = 0; __Vi0 < 516; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10384212773669704894ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 11313599220778170377ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 12612951392213773320ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3684401836241490092ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15971545576964516393ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 13626211603799454326ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 289255619725092493ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15744321194240425904ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2108923445830587217ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6899964706295993040ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 12813194378186578958ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 8168928203642790015ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4663487684517029151ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 1387749164350711987ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3948420492432986990ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9985938277684021902ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5980436829193522638ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11956292251735060442ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_d = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 29741278671812967ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2574933888646364910ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6777865588994655087ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7177552638542672729ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 12578978647147613090ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 10149488183412656109ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4861273519604502518ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4397787697488566595ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_idx = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 14154091631927633718ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_val = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 18355830654984195391ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7650825542368024243ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push_val = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 17841659889301090925ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10660951285803693914ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5065359086297641276ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__v = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7686354312376610099ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15288302248932128618ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15842695867989189294ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__base = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7731621670109756853ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__len = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 9670639031258460319ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w1 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 8477763132305669278ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__w2 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7407981866012410148ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit1 = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 74983493670905147ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit2 = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10361884042421929425ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx1 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 13819262037399804816ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__idx2 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15722493210943908699ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8232869947829045304ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13750136011222036749ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 18217289348294569393ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 278902822394415402ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_idx = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7712842477759517969ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_head_idx = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 10782889067111185475ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__old_head_idx = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6380782837504951739ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10408739587774133687ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__cstart = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15255071597847591180ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__clen = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2270189488404054311ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__l = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13481882372003401042ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__t = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 4436129751134322795ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__var_idx_b = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 12765065132542997552ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk1__DOT__unnamedblk5__DOT__j = 0;
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk7__DOT__var_idx = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1626268964916449398ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5603739458749260930ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15601111200021924737ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16782289907094198743ull);
    }
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 5092225365099914387ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 8027746335496751643ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_q = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13662180568845251967ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 16892327707229073402ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15782842865365664914ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11506977638538694346ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 6264961834485008103ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15868525519475736530ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 10211452164497461159ull);
    vlSelf->tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8226672214537514195ull);
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__Vfuncout = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__lit = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__1__v = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__Vfuncout = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__lit = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_truth__2__v = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__Vfuncout = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__lit = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout = 0;
    vlSelf->__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit = 0;
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_start__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__cae_start__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_valid__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_value__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_level__0 = 0;
    vlSelf->__VstlDidInit = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_start__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__cae_start__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_valid__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_value__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_level__1 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_hw_bench__DOT__rst_n__0 = 0;
    vlSelf->__VactDidInit = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
}
