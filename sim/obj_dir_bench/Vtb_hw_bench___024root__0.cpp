// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_hw_bench.h for the primary calling header

#include "Vtb_hw_bench__pch.h"

VlCoroutine Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__0(Vtb_hw_bench___024root* vlSelf);
VlCoroutine Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__1(Vtb_hw_bench___024root* vlSelf);

void Vtb_hw_bench___024root___eval_initial(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_initial\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

VlCoroutine Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__0(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_hw_bench__DOT__clk = 0U;
    while (true) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "tb_hw_bench.sv", 
                                             63);
        vlSelfRef.tb_hw_bench__DOT__clk = (1U & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__clk)));
    }
    co_return;}

VlCoroutine Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__1(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_hw_bench__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_hw_bench__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_hw_bench__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_hw_bench__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    std::string __Vtask_tb_hw_bench__DOT__load_cnf_file__0__filename;
    IData/*31:0*/ __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos = 0;
    IData/*31:0*/ __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i = 0;
    IData/*31:0*/ __Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd = 0;
    std::string __Vtask_tb_hw_bench__DOT__load_cnf_file__0__line;
    IData/*31:0*/ __Vtask_tb_hw_bench__DOT__load_cnf_file__0__lit;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__lit = 0;
    IData/*31:0*/ __Vtask_tb_hw_bench__DOT__load_cnf_file__0__scan_result;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__scan_result = 0;
    IData/*31:0*/ __Vtask_tb_hw_bench__DOT__load_cnf_file__0__num_vars;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__num_vars = 0;
    IData/*31:0*/ __Vtask_tb_hw_bench__DOT__load_cnf_file__0__num_clauses;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__num_clauses = 0;
    VlQueue<IData/*31:0*/> __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.atDefault() = 0;
    // Body
    vlSelfRef.tb_hw_bench__DOT__decision_count = 0U;
    vlSelfRef.tb_hw_bench__DOT__conflict_count = 0U;
    vlSelfRef.tb_hw_bench__DOT__rst_n = 0U;
    vlSelfRef.tb_hw_bench__DOT__start_solve = 0U;
    vlSelfRef.tb_hw_bench__DOT__load_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__load_literal = 0U;
    vlSelfRef.tb_hw_bench__DOT__load_clause_end = 0U;
    tb_hw_bench__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0x0000000aU;
    while (VL_LTS_III(32, 0U, tb_hw_bench__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_hw_bench.clk)", 
                                                             "tb_hw_bench.sv", 
                                                             115);
        tb_hw_bench__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_hw_bench__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_hw_bench__DOT__rst_n = 1U;
    tb_hw_bench__DOT__unnamedblk1_2__DOT____Vrepeat1 = 5U;
    while (VL_LTS_III(32, 0U, tb_hw_bench__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_hw_bench.clk)", 
                                                             "tb_hw_bench.sv", 
                                                             115);
        tb_hw_bench__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (tb_hw_bench__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__filename = "/Users/tatestaples/Code/VeriSAT/sim/../tests/benchmark_test.cnf"s;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__line.clear();
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__lit = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__scan_result = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__num_vars = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__num_clauses = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.clear();
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.atDefault() = 0;
    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd 
        = VL_FOPEN_NN(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__filename
                      , "r"s);
    ;
    if (VL_UNLIKELY(((0U == __Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd)))) {
        VL_WRITEF_NX("ERROR: Cannot open %@\n",0,-1,
                     &(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__filename));
        VL_FINISH_MT("tb_hw_bench.sv", 80, "");
    }
    while ((! (__Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd ? feof(VL_CVT_I_FP(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd)) : true))) {
        {
            if ((0U != VL_FGETS_NI(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line, __Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd))) {
                if (((0x63U == VL_GETC_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,0U)) 
                     | (0x25U == VL_GETC_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,0U)))) {
                    goto __Vlabel0;
                }
                if ((0x70U == VL_GETC_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,0U))) {
                    goto __Vlabel0;
                }
                __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos = 0U;
                __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.clear();
                {
                    while (VL_LTS_III(32, __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos, 
                                      VL_LEN_IN(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line))) {
                        __Vtask_tb_hw_bench__DOT__load_cnf_file__0__scan_result 
                            = VL_SSCANF_INNX(64,VL_SUBSTR_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,__Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos,
                                                            (VL_LEN_IN(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line) 
                                                             - (IData)(1U))),"%#",0,
                                             32,&(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__lit)) ;
                        if ((1U == __Vtask_tb_hw_bench__DOT__load_cnf_file__0__scan_result)) {
                            if ((0U == __Vtask_tb_hw_bench__DOT__load_cnf_file__0__lit)) {
                                __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i = 0U;
                                while (VL_LTS_III(32, __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i, __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.size())) {
                                    co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                                                nullptr, 
                                                                                "@(posedge tb_hw_bench.clk)", 
                                                                                "tb_hw_bench.sv", 
                                                                                92);
                                    while ((1U & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__load_ready)))) {
                                        co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                                                nullptr, 
                                                                                "@(posedge tb_hw_bench.clk)", 
                                                                                "tb_hw_bench.sv", 
                                                                                92);
                                    }
                                    vlSelfRef.tb_hw_bench__DOT__load_valid = 1U;
                                    vlSelfRef.tb_hw_bench__DOT__load_literal 
                                        = __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.at(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i);
                                    vlSelfRef.tb_hw_bench__DOT__load_clause_end 
                                        = (__Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i 
                                           == (__Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.size() 
                                               - (IData)(1U)));
                                    co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                                                nullptr, 
                                                                                "@(posedge tb_hw_bench.clk)", 
                                                                                "tb_hw_bench.sv", 
                                                                                95);
                                    vlSelfRef.tb_hw_bench__DOT__load_valid = 0U;
                                    vlSelfRef.tb_hw_bench__DOT__load_clause_end = 0U;
                                    __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i 
                                        = ((IData)(1U) 
                                           + __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__unnamedblk3__DOT__i);
                                }
                                goto __Vlabel1;
                            } else {
                                __Vtask_tb_hw_bench__DOT__load_cnf_file__0__literals.push_back(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__lit);
                            }
                            while ((VL_LTS_III(32, __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos, 
                                               VL_LEN_IN(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line)) 
                                    & ((0x20U == VL_GETC_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,__Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos)) 
                                       | (9U == VL_GETC_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,__Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos))))) {
                                __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos 
                                    = ((IData)(1U) 
                                       + __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos);
                            }
                            if (VL_GTS_III(32, 0U, __Vtask_tb_hw_bench__DOT__load_cnf_file__0__lit)) {
                                __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos 
                                    = ((IData)(1U) 
                                       + __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos);
                            }
                            while (((VL_LTS_III(32, __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos, 
                                                VL_LEN_IN(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line)) 
                                     & (0x30U <= VL_GETC_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,__Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos))) 
                                    & (0x39U >= VL_GETC_N(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__line,__Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos)))) {
                                __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos 
                                    = ((IData)(1U) 
                                       + __Vtask_tb_hw_bench__DOT__load_cnf_file__0__unnamedblk2__DOT__pos);
                            }
                        } else {
                            goto __Vlabel1;
                        }
                    }
                    __Vlabel1: ;
                }
            }
            __Vlabel0: ;
        }
    }
    VL_FCLOSE_I(__Vtask_tb_hw_bench__DOT__load_cnf_file__0__fd); co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                                                nullptr, 
                                                                                "@(posedge tb_hw_bench.clk)", 
                                                                                "tb_hw_bench.sv", 
                                                                                119);
    vlSelfRef.tb_hw_bench__DOT__start_solve = 1U;
    co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_hw_bench.clk)", 
                                                         "tb_hw_bench.sv", 
                                                         119);
    vlSelfRef.tb_hw_bench__DOT__start_solve = 0U;
    while (((~ (IData)(vlSelfRef.tb_hw_bench__DOT__solve_done)) 
            & VL_GTS_III(32, 0x00989680U, vlSelfRef.tb_hw_bench__DOT__cycle_count))) {
        co_await vlSelfRef.__VtrigSched_h09a47e26__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_hw_bench.clk)", 
                                                             "tb_hw_bench.sv", 
                                                             121);
    }
    VL_WRITEF_NX("RESULT:%s\nCYCLES:%0d\nDECISIONS:%0d\nCONFLICTS:%0d\n",0,
                 56,((IData)(vlSelfRef.tb_hw_bench__DOT__is_sat)
                      ? 0x0000000000534154ULL : ((IData)(vlSelfRef.tb_hw_bench__DOT__is_unsat)
                                                  ? 0x000000554e534154ULL
                                                  : 0x0054494d454f5554ULL)),
                 32,vlSelfRef.tb_hw_bench__DOT__cycle_count,
                 32,vlSelfRef.tb_hw_bench__DOT__decision_count,
                 32,vlSelfRef.tb_hw_bench__DOT__conflict_count);
    VL_FINISH_MT("tb_hw_bench.sv", 127, "");
    co_return;}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_hw_bench___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vtb_hw_bench___024root___eval_triggers__act(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_triggers__act\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                       << 0x0000000aU) 
                                                      | ((((~ (IData)(vlSelfRef.tb_hw_bench__DOT__rst_n)) 
                                                           & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__rst_n__0)) 
                                                          << 9U) 
                                                         | (((IData)(vlSelfRef.tb_hw_bench__DOT__clk) 
                                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__clk__0))) 
                                                            << 8U))) 
                                                     | (((((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level) 
                                                             != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_level__1)) 
                                                            << 3U) 
                                                           | (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_value__1)) 
                                                              << 2U)) 
                                                          | ((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__trail_query_valid__1)) 
                                                              << 1U) 
                                                             | ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start) 
                                                                != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__cae_start__1)))) 
                                                         << 4U) 
                                                        | (((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value) 
                                                              != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value__1)) 
                                                             << 3U) 
                                                            | ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var 
                                                                != vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var__1) 
                                                               << 2U)) 
                                                           | ((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid) 
                                                                != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid__1)) 
                                                               << 1U) 
                                                              | ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start) 
                                                                 != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_hw_bench__DOT__dut__DOT__pse_start__1))))))));
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
    if (VL_UNLIKELY(((1U & (~ (IData)(vlSelfRef.__VactDidInit)))))) {
        vlSelfRef.__VactDidInit = 1U;
        vlSelfRef.__VactTriggered[0U] = (1ULL | vlSelfRef.__VactTriggered
                                         [0U]);
        vlSelfRef.__VactTriggered[0U] = (2ULL | vlSelfRef.__VactTriggered
                                         [0U]);
        vlSelfRef.__VactTriggered[0U] = (4ULL | vlSelfRef.__VactTriggered
                                         [0U]);
        vlSelfRef.__VactTriggered[0U] = (8ULL | vlSelfRef.__VactTriggered
                                         [0U]);
        vlSelfRef.__VactTriggered[0U] = (0x0000000000000010ULL 
                                         | vlSelfRef.__VactTriggered
                                         [0U]);
        vlSelfRef.__VactTriggered[0U] = (0x0000000000000020ULL 
                                         | vlSelfRef.__VactTriggered
                                         [0U]);
        vlSelfRef.__VactTriggered[0U] = (0x0000000000000040ULL 
                                         | vlSelfRef.__VactTriggered
                                         [0U]);
        vlSelfRef.__VactTriggered[0U] = (0x0000000000000080ULL 
                                         | vlSelfRef.__VactTriggered
                                         [0U]);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_hw_bench___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vtb_hw_bench___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vtb_hw_bench___024root___act_sequent__TOP__0(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___act_sequent__TOP__0\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<CData/*7:0*/, 8> tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level;
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[__Vi0] = 0;
    }
    // Body
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_done = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_q;
    if ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q))) {
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d = 1U;
        }
    } else if ((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q))) {
        if ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d = 2U;
        } else {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d = 2U;
            if (((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (0U < vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [0U]))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [0U];
            }
            if (((1U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [1U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [1U];
            }
            if (((2U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [2U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [2U];
            }
            if (((3U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [3U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [3U];
            }
            if (((4U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [4U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [4U];
            }
            if (((5U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [5U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [5U];
            }
            if (((6U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [6U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [6U];
            }
            if (((7U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [7U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [7U];
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit = 0U;
            if (((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [0U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [0U];
            }
            if ((((1U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                  & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                     [1U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))) 
                 & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [1U];
            }
            if ((((2U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                  & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                     [2U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))) 
                 & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [2U];
            }
            if ((((3U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                  & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                     [3U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))) 
                 & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [3U];
            }
            if ((((4U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                  & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                     [4U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))) 
                 & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [4U];
            }
            if ((((5U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                  & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                     [5U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))) 
                 & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [5U];
            }
            if ((((6U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                  & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                     [6U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))) 
                 & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [6U];
            }
            if ((((7U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                  & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                     [7U] == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))) 
                 & (0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [7U];
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[0U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[0U] = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[1U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[1U] = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[2U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[2U] = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[3U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[3U] = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[4U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[4U] = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[5U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[5U] = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[6U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[6U] = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[7U] = 0U;
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[7U] = 0U;
            if ((0U == vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit)) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[0U] = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d = 0U;
            } else {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[0U] 
                    = (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit);
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d = 1U;
            }
            tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[0U] 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                [0U];
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                = ((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level))
                    ? (0x000000ffU & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level) 
                                      - (IData)(1U)))
                    : 0U);
            if ((0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit)) {
                VL_ASSIGNBIT_IO((7U & ([&]() {
                                vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__lit 
                                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__uip_lit;
                                vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__Vfuncout 
                                    = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__lit)
                                        ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__lit)
                                        : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__lit);
                            }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__3__Vfuncout)), vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask);
            }
            if (((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [0U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [0U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [0U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [0U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [0U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [0U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            if (((1U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [1U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [1U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [1U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [1U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [1U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [1U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            if (((2U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [2U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [2U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [2U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [2U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [2U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [2U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            if (((3U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [3U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [3U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [3U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [3U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [3U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [3U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            if (((4U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [4U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [4U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [4U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [4U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [4U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [4U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            if (((5U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [5U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [5U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [5U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [5U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [5U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [5U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            if (((6U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [6U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [6U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [6U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [6U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [6U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [6U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            if (((7U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q)) 
                 & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                    [7U] < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx 
                    = (7U & ([&]() {
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                                [7U];
                            vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit)
                                    : vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__lit);
                        }(), vlSelfRef.__Vfunc_tb_hw_bench__DOT__dut__DOT__u_cae__DOT__abs_lit__4__Vfuncout));
                if (((~ ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                         >> (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))) 
                     & (8U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)))) {
                    if ((vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                         [7U] > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                            [7U];
                    }
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp[(7U 
                                                                                & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                        [7U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__used_mask) 
                           | (0x00ffU & ((IData)(1U) 
                                         << (7U & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__vidx))));
                    tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_level[(7U 
                                                                           & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
                        [7U];
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
                }
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_d 
                = ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__max_level)) 
                   & (0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d)));
        }
    } else if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_done = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_q;
        if ((1U & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start)))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d = 0U;
        }
    } else {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d = 0U;
    }
}

void Vtb_hw_bench___024root___act_sequent__TOP__1(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___act_sequent__TOP__1\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__load_valid) 
           & (IData)(vlSelfRef.tb_hw_bench__DOT__load_ready));
}

void Vtb_hw_bench___024root___act_comb__TOP__0(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___act_comb__TOP__0\n"); );
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

void Vtb_hw_bench___024root___act_comb__TOP__1(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___act_comb__TOP__1\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<IData/*31:0*/, 8> tb_hw_bench__DOT__dut__DOT__accumulated_props;
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        tb_hw_bench__DOT__dut__DOT__accumulated_props[__Vi0] = 0;
    }
    CData/*0:0*/ tb_hw_bench__DOT__dut__DOT__trail_backtrack_en;
    tb_hw_bench__DOT__dut__DOT__trail_backtrack_en = 0;
    SData/*15:0*/ tb_hw_bench__DOT__dut__DOT__trail_backtrack_level;
    tb_hw_bench__DOT__dut__DOT__trail_backtrack_level = 0;
    IData/*31:0*/ tb_hw_bench__DOT__dut__DOT__trail_query_var;
    tb_hw_bench__DOT__dut__DOT__trail_query_var = 0;
    CData/*0:0*/ tb_hw_bench__DOT__dut__DOT__learn_load_clause_end;
    tb_hw_bench__DOT__dut__DOT__learn_load_clause_end = 0;
    IData/*31:0*/ tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__var_idx;
    tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__var_idx = 0;
    IData/*31:0*/ tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i;
    tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i = 0;
    // Body
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_var_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_var_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_phase_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_phase_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__tried_both_phases_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__tried_both_phases_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__level0_conflict_count_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__level0_conflict_count_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_count_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_count_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__verify_mode_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__verify_mode_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_started_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_started_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[0U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [0U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[0U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [0U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[1U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [1U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[1U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [1U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[2U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [2U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[2U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [2U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[3U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [3U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[3U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [3U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[4U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [4U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[4U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [4U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[5U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [5U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[5U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [5U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[6U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [6U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[6U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [6U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[7U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
        [7U];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[7U] 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q
        [7U];
    vlSelfRef.tb_hw_bench__DOT__solve_done = 0U;
    vlSelfRef.tb_hw_bench__DOT__is_sat = 0U;
    vlSelfRef.tb_hw_bench__DOT__is_unsat = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_value = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_level 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_is_decision = 0U;
    tb_hw_bench__DOT__dut__DOT__trail_backtrack_en = 0U;
    tb_hw_bench__DOT__dut__DOT__trail_backtrack_level = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_clear_all = 0U;
    tb_hw_bench__DOT__dut__DOT__trail_query_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value = 0U;
    tb_hw_bench__DOT__dut__DOT__learn_load_clause_end = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_request = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_value = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_all = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[0U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[1U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[2U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[3U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[4U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[5U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[6U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[7U] = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decay = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_clear_assignments = 0U;
    if ((0x00000010U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0U;
    } else if ((8U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
        if ((4U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
            if ((2U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0U;
            } else if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0U;
            } else {
                vlSelfRef.tb_hw_bench__DOT__is_unsat = 1U;
                vlSelfRef.tb_hw_bench__DOT__solve_done = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0x0cU;
            }
        } else if ((2U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
            if (VL_LIKELY(((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))))) {
                vlSelfRef.tb_hw_bench__DOT__is_sat = 1U;
                vlSelfRef.tb_hw_bench__DOT__solve_done = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0x0bU;
            } else {
                VL_WRITEF_NX("[CORE 0 Cycle %0#] *** SAT CHECK: All %0# variables assigned\n",0,
                             16,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q,
                             32,vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_max_var);
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0x0bU;
                VL_WRITEF_NX("[CORE 0] Trail height: %0#, Decision level: %0#\n",0,
                             16,vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q,
                             16,(IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i = 0U;
                while (((vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i 
                         < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q)) 
                        & VL_GTS_III(32, 0x00000040U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i))) {
                    VL_WRITEF_NX("[CORE 0]   Assignment[%0d]: var=%0#, value=%0#, level=%0#, decision=%0#\n",0,
                                 32,vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i,
                                 32,(IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                             [(0x0000003fU 
                                               & vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i)] 
                                             >> 0x00000012U)),
                                 1,(1U & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                                  [
                                                  (0x0000003fU 
                                                   & vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i)] 
                                                  >> 0x00000011U))),
                                 16,(0x0000ffffU & (IData)(
                                                           (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                                            [
                                                            (0x0000003fU 
                                                             & vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i)] 
                                                            >> 1U))),
                                 1,(1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                                 [(0x0000003fU 
                                                   & vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i)])));
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i 
                        = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk8__DOT__i);
                }
            }
        } else if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
            if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_started_q) {
                tb_hw_bench__DOT__dut__DOT__trail_query_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_q;
                if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_q;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value;
                }
                if (VL_LIKELY(((vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_q 
                                < vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_max_var)))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_d 
                        = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_q);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 9U;
                } else {
                    VL_WRITEF_NX("[CORE 0] RESYNC complete, appending %0#-literal learned clause\n",0,
                                 4,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_d = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 6U;
                }
            } else {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_started_d = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_d = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 9U;
            }
        } else {
            if (VL_UNLIKELY((vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_valid))) {
                VL_WRITEF_NX("[CORE 0] BACKTRACK_UNDO: clearing var=%0#\n",0,
                             32,vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_var);
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_valid = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value = 0U;
                if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_is_decision) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_valid = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_var;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_value 
                        = (1U & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_value)));
                }
            }
            if (VL_UNLIKELY((vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_done))) {
                VL_WRITEF_NX("[CORE 0] BACKTRACK_UNDO complete, transitioning to RESYNC_PSE\n",0);
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_clear_assignments = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_started_d = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_d = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 9U;
            }
        }
    } else if ((4U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
        if ((2U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
            if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
                if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_done) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_d 
                        = (0x0000ffffU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_d)));
                    if (VL_UNLIKELY(((0x0100U <= (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_d))))) {
                        VL_WRITEF_NX("[CORE 0 Cycle %0#] RESTART: conflict threshold reached (256)\n",0,
                                     16,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_d = 1U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_d = 0U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_count_d 
                            = (0x0000ffffU & ((IData)(1U) 
                                              + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_count_q)));
                    }
                    if (VL_UNLIKELY((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_q))) {
                        VL_WRITEF_NX("[CORE 0 Cycle %0#] *** UNSAT: CAE reports UNSAT (level-0 conflict)\n",0,
                                     16,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0x0cU;
                    } else if (VL_UNLIKELY(((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))))) {
                        VL_WRITEF_NX("[CORE 0 Cycle %0#] WARNING: Empty learned clause, retrying\n",0,
                                     16,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d = 0U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_d = 0U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 1U;
                    } else if (((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q)) 
                                & (0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_backtrack_level)))) {
                        VL_WRITEF_NX("[CORE 0 Cycle %0#] *** UNSAT: Conflict at level 1, backtrack to 0 (no valid assignment)\n",0,
                                     16,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0x0cU;
                    } else {
                        VL_WRITEF_NX("[CORE 0 Cycle %0#] Backtracking: current_level=%0# -> backtrack_level=%0#, learned_len=%0#\n",0,
                                     16,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q,
                                     16,(IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q),
                                     8,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_backtrack_level,
                                     4,(IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len));
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count 
                            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[0U] 
                            = ((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [0U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [0U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [0U]) : 0U);
                        tb_hw_bench__DOT__dut__DOT__trail_backtrack_en = 1U;
                        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_q) {
                            tb_hw_bench__DOT__dut__DOT__trail_backtrack_level = 0U;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_d = 0U;
                        } else {
                            tb_hw_bench__DOT__dut__DOT__trail_backtrack_level 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_backtrack_level;
                            vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_d 
                                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_backtrack_level;
                        }
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__tried_both_phases_d = 0U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decay = 1U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 8U;
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[1U] 
                            = ((1U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [1U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [1U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [1U]) : 0U);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[2U] 
                            = ((2U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [2U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [2U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [2U]) : 0U);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[3U] 
                            = ((3U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [3U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [3U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [3U]) : 0U);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[4U] 
                            = ((4U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [4U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [4U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [4U]) : 0U);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[5U] 
                            = ((5U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [5U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [5U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [5U]) : 0U);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[6U] 
                            = ((6U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [6U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [6U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [6U]) : 0U);
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars[7U] 
                            = ((7U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))
                                ? (VL_GTS_III(32, 0U, 
                                              vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                              [7U])
                                    ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                       [7U]) : vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                   [7U]) : 0U);
                    }
                }
            } else if (VL_LIKELY((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q) 
                                   < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len))))) {
                if (vlSelfRef.tb_hw_bench__DOT__load_ready) {
                    tb_hw_bench__DOT__dut__DOT__learn_load_clause_end 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q) 
                           == (0x0000000fU & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len) 
                                              - (IData)(1U))));
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q)));
                    VL_WRITEF_NX("[CORE 0] APPEND_LEARNED[%0#/%0#]: lit=%0d end=%0#\n",0,
                                 4,vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q,
                                 4,(IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len),
                                 32,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits
                                 [(7U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q))],
                                 1,tb_hw_bench__DOT__dut__DOT__learn_load_clause_end);
                } else {
                    VL_WRITEF_NX("[CORE 0] APPEND_LEARNED waiting for load_ready\n",0);
                }
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 6U;
            } else {
                VL_WRITEF_NX("[CORE 0] APPEND_LEARNED complete: %0# literals\n",0,
                             4,vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_len);
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_d = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_d = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 2U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 0U;
        } else {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_start = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d = 0U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 7U;
        }
    } else if ((2U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
        if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
            if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_q) 
                 < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__lit 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q
                    [(7U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_q))];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__var_idx 
                    = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__lit)
                        ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__lit)
                        : vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__lit);
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d[(7U 
                                                                         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_q))] 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_d 
                    = (0x0000000fU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_q)));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 3U;
                tb_hw_bench__DOT__dut__DOT__trail_query_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk6__DOT__var_idx;
            } else {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_d = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 4U;
            }
        } else {
            if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_q) 
                 & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_d = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_d 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause_len;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[0U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [0U];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[1U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [1U];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[2U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [2U];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[3U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [3U];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[4U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [4U];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[5U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [5U];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[6U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [6U];
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d[7U] 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict_clause
                    [7U];
            }
            if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_valid) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_var 
                    = (VL_GTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var)
                        ? (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var)
                        : vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var);
                tb_hw_bench__DOT__dut__DOT__trail_query_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_already_assigned 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid;
                if (VL_UNLIKELY(((1U & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_already_assigned)))))) {
                    VL_WRITEF_NX("[CORE 0] Propagation %0#: var=%0d\n",0,
                                 4,vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_q,
                                 32,vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var);
                    tb_hw_bench__DOT__dut__DOT__accumulated_props[(7U 
                                                                   & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_q))] 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_q)));
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_var;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value 
                        = VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_valid = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_value 
                        = VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_value 
                        = VL_LTS_III(32, 0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_propagated_var);
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_level 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_is_decision = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_var;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_var 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__unnamedblk5__DOT__prop_var;
                }
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q)));
            if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_done) 
                 | (0x0064U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q)))) {
                if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_q) 
                     & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_q) 
                        | (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict)))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 3U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_d = 0U;
                } else if ((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d = 1U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_d = 0U;
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 2U;
                } else {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d 
                        = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_all_assigned)
                            ? 0x0aU : 1U);
                }
            }
        }
    } else if ((1U & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_request = 1U;
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid) {
            if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_phase) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_d 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_var_d 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_phase_d = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_valid = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_value = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_value = 1U;
            } else {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_d 
                    = (- vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var);
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_var_d 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_phase_d = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_valid = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_value = 0U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push = 1U;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_var 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var;
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_value = 0U;
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_level 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q)));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_is_decision = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q)));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 2U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_d = 0U;
        } else {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d 
                = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_all_assigned)
                    ? 0x0aU : 1U);
        }
    } else if (vlSelfRef.tb_hw_bench__DOT__start_solve) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__tried_both_phases_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__level0_conflict_count_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_clear_all = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_all = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_clear_assignments = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__verify_mode_d = 0U;
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q;
    if ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_request) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_d = 1U;
        }
    } else if ((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q) 
             >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_max_var)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_d = 2U;
        }
    } else if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        if ((1U & (~ (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_request)))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_d = 0U;
        }
    } else {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_d = 0U;
    }
    tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__var_idx 
        = (0x0000003fU & tb_hw_bench__DOT__dut__DOT__trail_query_var);
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level
        [(0x0000003fU & tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__var_idx)];
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value = 0U;
    tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i = 0U;
    while ((tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i 
            < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q))) {
        if (((IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                      [(0x0000003fU & tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i)] 
                      >> 0x00000012U)) == tb_hw_bench__DOT__dut__DOT__trail_query_var)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_valid = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_level 
                = (0x0000ffffU & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                          [(0x0000003fU 
                                            & tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i)] 
                                          >> 1U)));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_query_value 
                = (1U & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                 [(0x0000003fU & tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i)] 
                                 >> 0x00000011U)));
        }
        tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i 
            = ((IData)(1U) + tb_hw_bench__DOT__dut__DOT__u_trail__DOT__unnamedblk1__DOT__unnamedblk2__DOT__i);
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q;
    if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push) 
         & (0x0040U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q)))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_d 
            = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q)));
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_d 
        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q;
    if ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
        if (tb_hw_bench__DOT__dut__DOT__trail_backtrack_en) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_d 
                = tb_hw_bench__DOT__dut__DOT__trail_backtrack_level;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_d 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_d = 1U;
        }
    } else if ((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
        if (((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q)) 
             & ((0x0000ffffU & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                        [(0x0000003fU 
                                          & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                             - (IData)(1U)))] 
                                        >> 1U))) > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q)))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_d 
                = (0x0000ffffU & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                  - (IData)(1U)));
        }
        if ((1U & (~ ((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q)) 
                      & ((0x0000ffffU & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                                 [(0x0000003fU 
                                                   & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                                      - (IData)(1U)))] 
                                                 >> 1U))) 
                         > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q)))))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_d = 2U;
        }
    } else if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_d = 0U;
    }
    if ((0U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
        if ((1U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
            if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_d 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q;
            }
        }
    }
    IData/*31:0*/ __Vilp1;
    __Vilp1 = 0U;
    while ((__Vilp1 <= 0x0000003fU)) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d[__Vilp1] 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level
            [__Vilp1];
        __Vilp1 = ((IData)(1U) + __Vilp1);
    }
    if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push) 
         & (0x0040U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q)))) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d[(0x0000003fU 
                                                                            & vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_var)] 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_level;
    }
    if ((0U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
        if ((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q))) {
            if (((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q)) 
                 & ((0x0000ffffU & (IData)((vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                            [(0x0000003fU 
                                              & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                                 - (IData)(1U)))] 
                                            >> 1U))) 
                    > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q)))) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d[(0x0000003fU 
                                                                                & (IData)(
                                                                                (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                                                                                [
                                                                                (0x0000003fU 
                                                                                & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q) 
                                                                                - (IData)(1U)))] 
                                                                                >> 0x00000012U)))] = 0U;
            }
        }
    }
    if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_clear_all) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_d = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_d = 0U;
        IData/*31:0*/ __Vilp2;
        __Vilp2 = 0U;
        while ((__Vilp2 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d[__Vilp2] = 0U;
            __Vilp2 = ((IData)(1U) + __Vilp2);
        }
    }
}

void Vtb_hw_bench___024root___eval_act(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_act\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered
         [0U])) {
        Vtb_hw_bench___024root___act_sequent__TOP__0(vlSelf);
    }
    if ((0x0000000000000100ULL & vlSelfRef.__VactTriggered
         [0U])) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire 
            = ((IData)(vlSelfRef.tb_hw_bench__DOT__load_valid) 
               & (IData)(vlSelfRef.tb_hw_bench__DOT__load_ready));
    }
    if ((0x000000000000010fULL & vlSelfRef.__VactTriggered
         [0U])) {
        Vtb_hw_bench___024root___act_comb__TOP__0(vlSelf);
    }
    if ((0x00000000000001ffULL & vlSelfRef.__VactTriggered
         [0U])) {
        Vtb_hw_bench___024root___act_comb__TOP__1(vlSelf);
    }
}

void Vtb_hw_bench___024root___nba_sequent__TOP__0(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___nba_sequent__TOP__0\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<SData/*15:0*/, 64> tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start;
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start[__Vi0] = 0;
    }
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v1 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v2;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v2 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v3;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v3 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v4;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v4 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v5;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v5 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v6;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v6 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v7;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v7 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v8;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v8 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v1 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v2;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v2 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v3;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v3 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v4;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v4 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v5;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v5 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v6;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v6 = 0;
    CData/*7:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v7;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v7 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v8;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v8 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v0 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v73;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v73 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v74;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v74 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v75;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v75 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v76;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v76 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v77;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v77 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v78;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v78 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v79;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v79 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v80;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v80 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v81;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v81 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v82;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v82 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v83;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v83 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v84;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v84 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v85;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v85 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v86;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v86 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v87;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v87 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v88;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v88 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v89;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v89 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v90;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v90 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v91;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v91 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v92;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v92 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v93;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v93 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v94;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v94 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v95;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v95 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v96;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v96 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v97;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v97 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v98;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v98 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v99;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v99 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v100;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v100 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v101;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v101 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v102;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v102 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v103;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v103 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v104;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v104 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v105;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v105 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v106;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v106 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v107;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v107 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v108;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v108 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v109;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v109 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v110;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v110 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v111;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v111 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v112;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v112 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v113;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v113 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v114;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v114 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v115;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v115 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v116;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v116 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v117;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v117 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v118;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v118 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v119;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v119 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v120;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v120 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v121;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v121 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v122;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v122 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v123;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v123 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v124;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v124 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v125;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v125 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v126;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v126 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v127;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v127 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v128;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v128 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v129;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v129 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v130;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v130 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v131;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v131 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v132;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v132 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v133;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v133 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v134;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v134 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v135;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v135 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v0 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v0 = 0;
    CData/*0:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0 = 0;
    CData/*0:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2 = 0;
    CData/*0:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v4;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v4 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v68;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v68 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v2;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v2 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v3;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v3 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v4;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v4 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v5;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v5 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v6;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v6 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v7;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v7 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v8;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v8 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v9;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v9 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v10;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v10 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v11;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v11 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v12;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v12 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v13;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v13 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v14;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v14 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v15;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v15 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v16;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v16 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v17;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v17 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v18;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v18 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v19;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v19 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v20;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v20 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v21;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v21 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v22;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v22 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v23;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v23 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v24;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v24 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v25;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v25 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v26;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v26 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v27;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v27 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v28;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v28 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v29;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v29 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v30;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v30 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v31;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v31 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v32;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v32 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v33;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v33 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v34;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v34 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v35;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v35 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v36;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v36 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v37;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v37 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v38;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v38 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v39;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v39 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v40;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v40 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v41;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v41 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v42;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v42 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v43;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v43 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v44;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v44 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v45;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v45 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v46;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v46 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v47;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v47 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v48;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v48 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v49;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v49 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v50;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v50 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v51;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v51 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v52;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v52 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v53;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v53 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v54;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v54 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v55;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v55 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v56;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v56 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v57;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v57 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v58;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v58 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v59;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v59 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v60;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v60 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v61;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v61 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v62;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v62 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v63;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v63 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v64;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v64 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v128;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v128 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0 = 0;
    CData/*6:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0 = 0;
    CData/*6:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0 = 0;
    CData/*6:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v1;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v1 = 0;
    CData/*6:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v1;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1 = 0;
    CData/*6:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v2;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v2 = 0;
    CData/*6:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v2;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v2 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0 = 0;
    SData/*9:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v0 = 0;
    CData/*1:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64 = 0;
    CData/*1:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65 = 0;
    CData/*5:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v66;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v66 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0 = 0;
    SData/*9:0*/ __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0;
    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v2;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v2 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v3;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v3 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v4;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v4 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v5;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v5 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v6;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v6 = 0;
    IData/*31:0*/ __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v7;
    __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v7 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v8;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v8 = 0;
    CData/*0:0*/ __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v9;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v9 = 0;
    // Body
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v64 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v128 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v8 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v9 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v8 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v8 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v4 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v68 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v66 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0 = 0U;
    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0 = 0U;
    if (vlSelfRef.tb_hw_bench__DOT__rst_n) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i = 0U;
        while (VL_GTS_III(32, 0x000000c0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h604b715b__1 
                = ((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1_d
                   [(0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)]
                    : 0U);
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h604b715b__1;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v0));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h40ce9c10__1 
                = ((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2_d
                   [(0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)]
                    : 0U);
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h40ce9c10__1;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v0));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h29b188f6__1 
                = ((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1_d
                   [(0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)]
                    : 0U);
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h29b188f6__1;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v0));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h00d61c0b__1 
                = ((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))
                    ? vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2_d
                   [(0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)]
                    : 0U);
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h00d61c0b__1;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v0));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i 
                = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
        }
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i = 0U;
        while (VL_GTS_III(32, 0x00000080U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)) {
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1_d
                [(0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)];
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0 
                = (0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
            vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v0));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2_d
                [(0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)];
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0 
                = (0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
            vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v0));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i 
                = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
        }
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_clear_assignments) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i = 0x00000040U;
        }
        if ((((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q)) 
              | (1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q))) 
             & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_start))) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i = 0U;
            while (VL_GTS_III(32, 0x00000080U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)) {
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v1 
                    = (0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1.enqueue(0xffffU, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v1));
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v1 
                    = (0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2.enqueue(0xffffU, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v1));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i 
                    = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
            }
        }
    } else {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i = 0U;
        while (VL_GTS_III(32, 0x000000c0U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h604b715b__0 = 0U;
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h604b715b__0;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1__v1));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h40ce9c10__0 = 0U;
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h40ce9c10__0;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2__v1));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h29b188f6__0 = 0xffffU;
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h29b188f6__0;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1__v1));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h00d61c0b__0 = 0xffffU;
            if (VL_LIKELY(((0xbfU >= (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i))))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h00d61c0b__0;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1 
                    = (0x000000ffU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2.enqueue(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2__v1));
            }
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i 
                = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
        }
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i = 0U;
        while (VL_GTS_III(32, 0x00000080U, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i)) {
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v2 
                = (0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
            vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1.enqueue(0xffffU, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1__v2));
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v2 
                = (0x0000007fU & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
            vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2.enqueue(0xffffU, (IData)(__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2__v2));
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i 
                = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__i);
        }
    }
    if ((1U & ((~ (IData)(vlSelfRef.tb_hw_bench__DOT__rst_n)) 
               | (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_all)))) {
        __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v0 = 1U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v0 = 1U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v0 = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q = 0xffffU;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q = 0U;
    } else {
        if ((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_valid) 
              & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var)) 
             & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var))) {
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64 
                = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var 
                                  - (IData)(1U)));
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64 = 1U;
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_value;
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64 
                = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_assign_var 
                                  - (IData)(1U)));
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64 = 1U;
        }
        if ((((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_valid) 
              & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_var)) 
             & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_var))) {
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65 
                = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_clear_var 
                                  - (IData)(1U)));
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65 = 1U;
        }
        if ((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count))) {
            if ((((0U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [0U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [0U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [0U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [0U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64 = 1U;
            }
            if ((((1U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [1U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [1U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [1U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [1U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65 = 1U;
            }
            if ((((2U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [2U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [2U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [2U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [2U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66 = 1U;
            }
            if ((((3U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [3U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [3U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [3U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [3U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67 = 1U;
            }
            if ((((4U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [4U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [4U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [4U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [4U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68 = 1U;
            }
            if ((((5U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [5U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [5U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [5U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [5U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69 = 1U;
            }
            if ((((6U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [6U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [6U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [6U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [6U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70 = 1U;
            }
            if ((((7U < (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_count)) 
                  & (0U != vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                     [7U])) & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                               [7U]))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71 
                    = ((IData)(0x00002710U) + vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                       [(0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                        [7U] - (IData)(1U)))]);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_bump_vars
                                      [7U] - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71 = 1U;
            }
        }
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decay) {
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [0U], 4U));
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72 = 1U;
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v73 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [1U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [1U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v74 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [2U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [2U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v75 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [3U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [3U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v76 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [4U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [4U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v77 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [5U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [5U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v78 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [6U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [6U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v79 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [7U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [7U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v80 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [8U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [8U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v81 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [9U] - VL_SHIFTR_III(32,32,32, vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                        [9U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v82 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x0aU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x0aU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v83 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x0bU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x0bU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v84 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x0cU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x0cU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v85 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x0dU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x0dU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v86 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x0eU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x0eU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v87 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x0fU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x0fU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v88 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x10U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x10U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v89 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x11U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x11U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v90 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x12U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x12U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v91 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x13U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x13U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v92 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x14U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x14U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v93 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x15U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x15U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v94 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x16U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x16U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v95 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x17U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x17U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v96 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x18U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x18U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v97 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x19U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x19U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v98 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x1aU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x1aU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v99 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x1bU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x1bU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v100 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x1cU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x1cU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v101 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x1dU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x1dU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v102 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x1eU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x1eU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v103 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x1fU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x1fU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v104 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x20U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x20U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v105 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x21U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x21U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v106 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x22U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x22U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v107 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x23U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x23U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v108 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x24U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x24U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v109 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x25U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x25U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v110 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x26U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x26U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v111 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x27U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x27U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v112 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x28U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x28U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v113 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x29U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x29U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v114 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x2aU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x2aU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v115 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x2bU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x2bU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v116 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x2cU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x2cU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v117 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x2dU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x2dU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v118 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x2eU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x2eU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v119 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x2fU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x2fU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v120 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x30U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x30U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v121 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x31U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x31U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v122 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x32U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x32U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v123 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x33U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x33U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v124 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x34U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x34U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v125 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x35U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x35U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v126 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x36U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x36U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v127 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x37U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x37U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v128 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x38U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x38U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v129 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x39U] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x39U], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v130 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x3aU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x3aU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v131 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x3bU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x3bU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v132 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x3cU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x3cU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v133 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x3dU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x3dU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v134 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x3eU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x3eU], 4U));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v135 
                = (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                   [0x3fU] - VL_SHIFTR_III(32,32,32, 
                                           vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity
                                           [0x3fU], 4U));
        }
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_act_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__scan_idx_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_d;
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_seen_d));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_phase_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_phase_d));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__tried_both_phases_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__tried_both_phases_d));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__verify_mode_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__verify_mode_d));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_pending_d));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_started_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_started_d));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__unsat_d));
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_list_sel_d));
    if (vlSelfRef.tb_hw_bench__DOT__rst_n) {
        vlSelfRef.tb_hw_bench__DOT__cycle_count = ((IData)(1U) 
                                                   + vlSelfRef.tb_hw_bench__DOT__cycle_count);
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0U];
        __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0 = 1U;
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v1 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [1U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v2 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [2U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v3 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [3U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v4 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [4U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v5 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [5U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v6 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [6U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v7 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [7U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v8 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [8U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v9 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [9U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v10 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x0aU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v11 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x0bU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v12 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x0cU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v13 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x0dU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v14 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x0eU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v15 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x0fU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v16 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x10U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v17 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x11U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v18 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x12U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v19 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x13U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v20 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x14U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v21 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x15U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v22 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x16U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v23 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x17U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v24 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x18U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v25 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x19U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v26 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x1aU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v27 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x1bU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v28 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x1cU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v29 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x1dU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v30 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x1eU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v31 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x1fU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v32 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x20U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v33 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x21U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v34 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x22U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v35 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x23U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v36 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x24U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v37 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x25U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v38 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x26U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v39 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x27U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v40 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x28U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v41 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x29U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v42 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x2aU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v43 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x2bU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v44 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x2cU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v45 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x2dU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v46 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x2eU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v47 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x2fU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v48 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x30U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v49 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x31U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v50 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x32U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v51 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x33U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v52 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x34U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v53 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x35U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v54 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x36U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v55 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x37U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v56 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x38U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v57 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x39U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v58 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x3aU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v59 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x3bU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v60 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x3cU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v61 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x3dU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v62 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x3eU];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v63 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level_d
            [0x3fU];
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_clear_all) {
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v64 = 1U;
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v4 = 1U;
        }
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [0U];
        __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0 = 1U;
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v1 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [1U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v2 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [2U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v3 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [3U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v4 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [4U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v5 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [5U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v6 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [6U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v7 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_d
            [7U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [0U];
        __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0 = 1U;
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v1 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [1U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v2 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [2U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v3 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [3U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v4 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [4U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v5 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [5U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v6 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [6U];
        __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v7 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_d
            [7U];
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h5df078f0__0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_push_val;
            if ((0x0203U >= (0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q)))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h5df078f0__0;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0 
                    = (0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0 = 1U;
            }
        }
        if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push) 
             & (0x0040U > (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q)))) {
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_var;
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0 
                = (0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q));
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0 = 1U;
            if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_is_decision) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0 
                    = (0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_level));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0 = 1U;
            }
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_value;
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1 
                = (0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q));
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1 = 1U;
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_level;
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2 
                = (0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q));
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_push_is_decision;
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3 
                = (0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q));
        }
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_clear_assignments) {
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v0 = 1U;
        }
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_valid) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk7__DOT__var_idx 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_var;
            if (((0U < vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk7__DOT__var_idx) 
                 & (0x00000040U >= vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk7__DOT__var_idx))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64 
                    = ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_assign_broadcast_value)
                        ? 2U : 1U);
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64 
                    = (0x0000003fU & (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__unnamedblk7__DOT__var_idx 
                                      - (IData)(1U)));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64 = 1U;
            }
        }
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_en) {
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_val;
            __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65 
                = (0x0000003fU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_wr_idx));
            __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65 = 1U;
        }
        if (vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h65c98558__0 
                = vlSelfRef.tb_hw_bench__DOT__load_literal;
            if ((0x0203U >= (0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q)))) {
                __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0 
                    = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h65c98558__0;
                __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0 
                    = (0x000003ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q));
                __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0 = 1U;
            }
            if (vlSelfRef.tb_hw_bench__DOT__load_clause_end) {
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hbcbfc3d7__0 
                    = (0x0000ffffU & ((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q) 
                                      - (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q)));
                vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h3fedabd8__0 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q)));
                if ((0xbfU >= (0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q)))) {
                    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_hbcbfc3d7__0;
                    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0 
                        = (0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q));
                    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0 = 1U;
                    __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0 
                        = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT____Vlvbound_h3fedabd8__0;
                    __VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0 
                        = (0x000000ffU & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q));
                    __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0 = 1U;
                }
            }
        }
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_var_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_var_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__level0_conflict_count_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__level0_conflict_count_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_count_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_count_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_d;
        if ((1U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q))) {
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [0U];
            __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0 = 1U;
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_backtrack_level 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_d;
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [1U];
            __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1 = 1U;
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v2 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [2U];
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v3 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [3U];
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v4 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [4U];
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v5 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [5U];
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v6 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [6U];
            __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v7 
                = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_tmp
                [7U];
        }
    } else {
        vlSelfRef.tb_hw_bench__DOT__cycle_count = 0U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v128 = 1U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v8 = 1U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v8 = 1U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v68 = 1U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v66 = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_counter_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_level_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__state_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cycle_count_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__prop_count_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__last_decision_var_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__level0_conflict_count_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__restart_count_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__query_index_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__learn_idx_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__resync_idx_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__learned_count_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__backtrack_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_len_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_target_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_index_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__bt_state_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__decision_lit_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__init_clause_idx_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_head_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_clause_q = 0xffffU;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__scan_prev_q = 0xffffU;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_prop_lit_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__max_var_seen_q = 0U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v8 = 1U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_backtrack_level = 0U;
        __VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v9 = 1U;
    }
    vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1.commit(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit1);
    vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2.commit(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watched_lit2);
    vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1.commit(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next1);
    vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2.commit(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_next2);
    vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1.commit(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head1);
    vlSelfRef.__VdlyCommitQueuetb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2.commit(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__watch_head2);
    if (vlSelfRef.tb_hw_bench__DOT__rst_n) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_d;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q 
            = vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_d;
    } else {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_tail_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail_height_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_count_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__cur_clause_len_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_count_q = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_cae__DOT__state_q = 0U;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v0) {
        IData/*31:0*/ __Vilp1;
        __Vilp1 = 0U;
        while ((__Vilp1 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned[__Vilp1] = 0U;
            __Vilp1 = ((IData)(1U) + __Vilp1);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v64] = 1U;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__assigned__v65] = 0U;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v0) {
        IData/*31:0*/ __Vilp2;
        __Vilp2 = 0U;
        while ((__Vilp2 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint[__Vilp2] = 1U;
            __Vilp2 = ((IData)(1U) + __Vilp2);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__phase_hint__v64;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v0;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[1U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v1;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[2U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v2;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[3U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v3;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[4U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v4;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[5U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v5;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[6U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v6;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[7U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v7;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[8U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v8;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[9U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v9;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x0aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v10;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x0bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v11;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x0cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v12;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x0dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v13;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x0eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v14;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x0fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v15;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x10U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v16;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x11U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v17;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x12U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v18;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x13U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v19;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x14U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v20;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x15U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v21;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x16U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v22;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x17U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v23;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x18U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v24;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x19U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v25;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x1aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v26;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x1bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v27;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x1cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v28;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x1dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v29;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x1eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v30;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x1fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v31;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x20U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v32;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x21U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v33;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x22U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v34;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x23U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v35;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x24U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v36;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x25U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v37;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x26U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v38;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x27U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v39;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x28U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v40;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x29U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v41;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x2aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v42;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x2bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v43;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x2cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v44;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x2dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v45;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x2eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v46;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x2fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v47;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x30U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v48;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x31U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v49;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x32U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v50;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x33U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v51;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x34U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v52;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x35U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v53;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x36U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v54;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x37U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v55;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x38U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v56;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x39U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v57;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x3aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v58;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x3bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v59;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x3cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v60;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x3dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v61;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x3eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v62;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[0x3fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v63;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v64) {
        IData/*31:0*/ __Vilp3;
        __Vilp3 = 0U;
        while ((__Vilp3 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[__Vilp3] = 0U;
            __Vilp3 = ((IData)(1U) + __Vilp3);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level__v128) {
        IData/*31:0*/ __Vilp4;
        __Vilp4 = 0U;
        while ((__Vilp4 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__var_to_level[__Vilp4] = 0U;
            __Vilp4 = ((IData)(1U) + __Vilp4);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[0U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v0;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[1U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v1;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[2U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v2;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[3U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v3;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[4U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v4;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[5U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v5;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[6U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v6;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[7U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v7;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_clause_q__v8) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[0U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[1U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[2U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[3U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[4U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[5U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[6U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_clause_q[7U] = 0U;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[0U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v0;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[1U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v1;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[2U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v2;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[3U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v3;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[4U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v4;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[5U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v5;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[6U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v6;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[7U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v7;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__conflict_levels_q__v8) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[0U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[1U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[2U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[3U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[4U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[5U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[6U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__conflict_levels_q[7U] = 0U;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v0) {
        IData/*31:0*/ __Vilp5;
        __Vilp5 = 0U;
        while ((__Vilp5 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__Vilp5] = 0U;
            __Vilp5 = ((IData)(1U) + __Vilp5);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v64;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v65;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v66;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v67;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v68;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v69;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v70;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v71;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v72;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[1U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v73;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[2U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v74;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[3U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v75;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[4U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v76;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[5U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v77;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[6U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v78;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[7U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v79;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[8U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v80;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[9U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v81;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x0aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v82;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x0bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v83;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x0cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v84;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x0dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v85;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x0eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v86;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x0fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v87;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x10U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v88;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x11U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v89;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x12U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v90;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x13U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v91;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x14U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v92;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x15U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v93;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x16U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v94;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x17U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v95;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x18U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v96;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x19U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v97;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x1aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v98;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x1bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v99;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x1cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v100;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x1dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v101;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x1eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v102;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x1fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v103;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x20U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v104;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x21U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v105;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x22U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v106;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x23U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v107;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x24U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v108;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x25U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v109;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x26U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v110;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x27U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v111;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x28U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v112;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x29U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v113;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x2aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v114;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x2bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v115;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x2cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v116;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x2dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v117;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x2eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v118;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x2fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v119;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x30U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v120;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x31U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v121;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x32U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v122;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x33U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v123;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x34U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v124;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x35U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v125;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x36U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v126;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x37U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v127;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x38U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v128;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x39U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v129;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x3aU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v130;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x3bU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v131;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x3cU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v132;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x3dU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v133;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x3eU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v134;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity[0x3fU] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_vde__DOT__activity__v135;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__prop_q__v0;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0) {
        tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start__v0;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v4) {
        IData/*31:0*/ __Vilp6;
        __Vilp6 = 0U;
        while ((__Vilp6 <= 0x0000003fU)) {
            tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start[__Vilp6] = 0U;
            __Vilp6 = ((IData)(1U) + __Vilp6);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0] 
            = ((0x000000000003ffffULL & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                [__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0]) 
               | ((QData)((IData)(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v0)) 
                  << 0x00000012U));
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1] 
            = ((0x0003fffffffdffffULL & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                [__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1]) 
               | ((QData)((IData)(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v1)) 
                  << 0x00000011U));
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2] 
            = ((0x0003fffffffe0001ULL & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                [__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2]) 
               | ((QData)((IData)(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v2)) 
                  << 1U));
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3] 
            = ((0x0003fffffffffffeULL & vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail
                [__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3]) 
               | (IData)((IData)(__VdlyVal__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v3)));
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v4) {
        IData/*31:0*/ __Vilp7;
        __Vilp7 = 0U;
        while ((__Vilp7 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail[__Vilp7] = 0ULL;
            __Vilp7 = ((IData)(1U) + __Vilp7);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail__v68) {
        IData/*31:0*/ __Vilp8;
        __Vilp8 = 0U;
        while ((__Vilp8 <= 0x0000003fU)) {
            tb_hw_bench__DOT__dut__DOT__u_trail__DOT__level_start[__Vilp8] = 0U;
            __Vilp8 = ((IData)(1U) + __Vilp8);
        }
        IData/*31:0*/ __Vilp9;
        __Vilp9 = 0U;
        while ((__Vilp9 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_trail__DOT__trail[__Vilp9] = 0ULL;
            __Vilp9 = ((IData)(1U) + __Vilp9);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v0) {
        IData/*31:0*/ __Vilp10;
        __Vilp10 = 0U;
        while ((__Vilp10 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state[__Vilp10] = 0U;
            __Vilp10 = ((IData)(1U) + __Vilp10);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v64;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v65;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state__v66) {
        IData/*31:0*/ __Vilp11;
        __Vilp11 = 0U;
        while ((__Vilp11 <= 0x0000003fU)) {
            vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__assign_state[__Vilp11] = 0U;
            __Vilp11 = ((IData)(1U) + __Vilp11);
        }
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__lit_mem__v0;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_start__v0;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len[__VdlyDim0__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__u_pse__DOT__clause_len__v0;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[0U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v0;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[1U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v1;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[2U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v2;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[3U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v3;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[4U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v4;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[5U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v5;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[6U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v6;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[7U] 
            = __VdlyVal__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v7;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v8) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[0U] = 0U;
    }
    if (__VdlySet__tb_hw_bench__DOT__dut__DOT__cae_learned_lits__v9) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[1U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[2U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[3U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[4U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[5U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[6U] = 0U;
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__cae_learned_lits[7U] = 0U;
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_all_assigned = 0U;
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_phase = 0U;
    if ((0U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        if ((1U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
            if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
                if ((0xffffU != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_var 
                        = ((IData)(1U) + (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q));
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
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__trail_backtrack_done = 0U;
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
    vlSelfRef.tb_hw_bench__DOT__load_ready = ((0U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q)) 
                                              | (1U 
                                                 == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__state_q)));
}

void Vtb_hw_bench___024root___nba_sequent__TOP__1(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___nba_sequent__TOP__1\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vdly__tb_hw_bench__DOT__decision_count;
    __Vdly__tb_hw_bench__DOT__decision_count = 0;
    IData/*31:0*/ __VdlyMask__tb_hw_bench__DOT__decision_count;
    __VdlyMask__tb_hw_bench__DOT__decision_count = 0;
    IData/*31:0*/ __Vdly__tb_hw_bench__DOT__conflict_count;
    __Vdly__tb_hw_bench__DOT__conflict_count = 0;
    IData/*31:0*/ __VdlyMask__tb_hw_bench__DOT__conflict_count;
    __VdlyMask__tb_hw_bench__DOT__conflict_count = 0;
    // Body
    if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid) 
         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_request))) {
        __Vdly__tb_hw_bench__DOT__decision_count = 
            ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__decision_count);
        __VdlyMask__tb_hw_bench__DOT__decision_count = 0xffffffffU;
    }
    if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict) 
         & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_q))) {
        __Vdly__tb_hw_bench__DOT__conflict_count = 
            ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__conflict_count);
        __VdlyMask__tb_hw_bench__DOT__conflict_count = 0xffffffffU;
    }
    vlSelfRef.tb_hw_bench__DOT__decision_count = ((__Vdly__tb_hw_bench__DOT__decision_count 
                                                   & __VdlyMask__tb_hw_bench__DOT__decision_count) 
                                                  | (vlSelfRef.tb_hw_bench__DOT__decision_count 
                                                     & (~ __VdlyMask__tb_hw_bench__DOT__decision_count)));
    __VdlyMask__tb_hw_bench__DOT__decision_count = 0U;
    vlSelfRef.tb_hw_bench__DOT__conflict_count = ((__Vdly__tb_hw_bench__DOT__conflict_count 
                                                   & __VdlyMask__tb_hw_bench__DOT__conflict_count) 
                                                  | (vlSelfRef.tb_hw_bench__DOT__conflict_count 
                                                     & (~ __VdlyMask__tb_hw_bench__DOT__conflict_count)));
    __VdlyMask__tb_hw_bench__DOT__conflict_count = 0U;
}

void Vtb_hw_bench___024root___nba_sequent__TOP__2(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___nba_sequent__TOP__2\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid = 0U;
    if ((0U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
        if ((1U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
            if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
                if ((0xffffU != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q))) {
                    vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid = 1U;
                }
            }
        }
    }
    vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_q 
        = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d));
}

void Vtb_hw_bench___024root___nba_comb__TOP__2(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___nba_comb__TOP__2\n"); );
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

void Vtb_hw_bench___024root___eval_nba(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_nba\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__decision_count;
    __Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__decision_count = 0;
    IData/*31:0*/ __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__decision_count;
    __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__decision_count = 0;
    IData/*31:0*/ __Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__conflict_count;
    __Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__conflict_count = 0;
    IData/*31:0*/ __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__conflict_count;
    __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__conflict_count = 0;
    // Body
    if ((0x0000000000000300ULL & vlSelfRef.__VnbaTriggered
         [0U])) {
        Vtb_hw_bench___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((0x0000000000000100ULL & vlSelfRef.__VnbaTriggered
         [0U])) {
        if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid) 
             & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_request))) {
            __Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__decision_count 
                = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__decision_count);
            __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__decision_count = 0xffffffffU;
        }
        if (((IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_conflict) 
             & (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_q))) {
            __Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__conflict_count 
                = ((IData)(1U) + vlSelfRef.tb_hw_bench__DOT__conflict_count);
            __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__conflict_count = 0xffffffffU;
        }
        vlSelfRef.tb_hw_bench__DOT__decision_count 
            = ((__Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__decision_count 
                & __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__decision_count) 
               | (vlSelfRef.tb_hw_bench__DOT__decision_count 
                  & (~ __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__decision_count)));
        __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__decision_count = 0U;
        vlSelfRef.tb_hw_bench__DOT__conflict_count 
            = ((__Vinline__nba_sequent__TOP__1___Vdly__tb_hw_bench__DOT__conflict_count 
                & __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__conflict_count) 
               | (vlSelfRef.tb_hw_bench__DOT__conflict_count 
                  & (~ __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__conflict_count)));
        __Vinline__nba_sequent__TOP__1___VdlyMask__tb_hw_bench__DOT__conflict_count = 0U;
    }
    if ((0x0000000000000310ULL & vlSelfRef.__VnbaTriggered
         [0U])) {
        Vtb_hw_bench___024root___act_sequent__TOP__0(vlSelf);
    }
    if ((0x0000000000000300ULL & vlSelfRef.__VnbaTriggered
         [0U])) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_pse__DOT__load_fire 
            = ((IData)(vlSelfRef.tb_hw_bench__DOT__load_valid) 
               & (IData)(vlSelfRef.tb_hw_bench__DOT__load_ready));
    }
    if ((0x0000000000000300ULL & vlSelfRef.__VnbaTriggered
         [0U])) {
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid = 0U;
        if ((0U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
            if ((1U != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
                if ((2U == (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__state_q))) {
                    if ((0xffffU != (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__u_vde__DOT__best_idx_q))) {
                        vlSelfRef.tb_hw_bench__DOT__dut__DOT__vde_decision_valid = 1U;
                    }
                }
            }
        }
        vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_q 
            = ((IData)(vlSelfRef.tb_hw_bench__DOT__rst_n) 
               && (IData)(vlSelfRef.tb_hw_bench__DOT__dut__DOT__pse_started_d));
    }
    if ((0x000000000000030fULL & vlSelfRef.__VnbaTriggered
         [0U])) {
        Vtb_hw_bench___024root___nba_comb__TOP__2(vlSelf);
    }
    if ((0x00000000000003ffULL & vlSelfRef.__VnbaTriggered
         [0U])) {
        Vtb_hw_bench___024root___act_comb__TOP__1(vlSelf);
    }
}

void Vtb_hw_bench___024root___timing_commit(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___timing_commit\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (0x0000000000000100ULL & vlSelfRef.__VactTriggered
            [0U]))) {
        vlSelfRef.__VtrigSched_h09a47e26__0.commit(
                                                   "@(posedge tb_hw_bench.clk)");
    }
}

void Vtb_hw_bench___024root___timing_resume(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___timing_resume\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0x0000000000000100ULL & vlSelfRef.__VactTriggered
         [0U])) {
        vlSelfRef.__VtrigSched_h09a47e26__0.resume(
                                                   "@(posedge tb_hw_bench.clk)");
    }
    if ((0x0000000000000400ULL & vlSelfRef.__VactTriggered
         [0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_hw_bench___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_hw_bench___024root___eval_phase__act(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_phase__act\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_hw_bench___024root___eval_triggers__act(vlSelf);
    Vtb_hw_bench___024root___timing_commit(vlSelf);
    Vtb_hw_bench___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_hw_bench___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        Vtb_hw_bench___024root___timing_resume(vlSelf);
        Vtb_hw_bench___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

void Vtb_hw_bench___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_hw_bench___024root___eval_phase__nba(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_phase__nba\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_hw_bench___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_hw_bench___024root___eval_nba(vlSelf);
        Vtb_hw_bench___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_hw_bench___024root___eval(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_hw_bench___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("tb_hw_bench.sv", 2, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vtb_hw_bench___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("tb_hw_bench.sv", 2, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vtb_hw_bench___024root___eval_phase__act(vlSelf));
    } while (Vtb_hw_bench___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vtb_hw_bench___024root___eval_debug_assertions(Vtb_hw_bench___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_hw_bench___024root___eval_debug_assertions\n"); );
    Vtb_hw_bench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
