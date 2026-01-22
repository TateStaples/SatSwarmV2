// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mini.h for the primary calling header

#include "Vtb_mini__pch.h"

VlCoroutine Vtb_mini___024root___eval_initial__TOP__Vtiming__0(Vtb_mini___024root* vlSelf);
VlCoroutine Vtb_mini___024root___eval_initial__TOP__Vtiming__1(Vtb_mini___024root* vlSelf);
VlCoroutine Vtb_mini___024root___eval_initial__TOP__Vtiming__2(Vtb_mini___024root* vlSelf);

void Vtb_mini___024root___eval_initial(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_initial\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mini__DOT__clk = 0U;
    Vtb_mini___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_mini___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vtb_mini___024root___eval_initial__TOP__Vtiming__2(vlSelf);
}

VlCoroutine Vtb_mini___024root___eval_initial__TOP__Vtiming__0(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    QData/*63:0*/ tb_mini__DOT__cycle_count;
    tb_mini__DOT__cycle_count = 0;
    IData/*31:0*/ tb_mini__DOT__clause_count;
    tb_mini__DOT__clause_count = 0;
    double tb_mini__DOT__start_time;
    tb_mini__DOT__start_time = 0;
    double tb_mini__DOT__end_time;
    tb_mini__DOT__end_time = 0;
    CData/*0:0*/ tb_mini__DOT__expected_sat;
    tb_mini__DOT__expected_sat = 0;
    IData/*31:0*/ tb_mini__DOT__load_cnf_file__Vstatic__fd;
    tb_mini__DOT__load_cnf_file__Vstatic__fd = 0;
    CData/*0:0*/ tb_mini__DOT__run_test__Vstatic__model_valid;
    tb_mini__DOT__run_test__Vstatic__model_valid = 0;
    std::string __Vtask_tb_mini__DOT__run_test__0__cnf_file_arg;
    CData/*0:0*/ __Vtask_tb_mini__DOT__run_test__0__expected_sat_arg;
    __Vtask_tb_mini__DOT__run_test__0__expected_sat_arg = 0;
    QData/*63:0*/ __Vtask_tb_mini__DOT__run_test__0__max_cycles_arg;
    __Vtask_tb_mini__DOT__run_test__0__max_cycles_arg = 0;
    IData/*31:0*/ __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_1__DOT____Vrepeat0;
    __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_2__DOT____Vrepeat1;
    __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    std::string __Vtask_tb_mini__DOT__load_cnf_file__1__filename;
    IData/*31:0*/ __Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i;
    __Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i = 0;
    IData/*31:0*/ __Vtask_tb_mini__DOT__push_literal__2__lit;
    __Vtask_tb_mini__DOT__push_literal__2__lit = 0;
    CData/*0:0*/ __Vtask_tb_mini__DOT__push_literal__2__clause_end;
    __Vtask_tb_mini__DOT__push_literal__2__clause_end = 0;
    CData/*0:0*/ __Vtask_tb_mini__DOT__verify_model__3__valid;
    __Vtask_tb_mini__DOT__verify_model__3__valid = 0;
    IData/*31:0*/ __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c;
    __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c = 0;
    IData/*31:0*/ __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l;
    __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l = 0;
    IData/*31:0*/ __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l;
    __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l = 0;
    // Body
    if (VL_UNLIKELY(((! VL_VALUEPLUSARGS_INN(64, "CNF=%s"s, 
                                             vlSelfRef.tb_mini__DOT__cnf_file))))) {
        VL_WRITEF_NX("ERROR: No +CNF argument provided\nUsage: ./Vtb_mini +CNF=<file.cnf> +EXPECT=<SAT|UNSAT> [+MAXCYCLES=N] [+DEBUG=N]\n",0);
        VL_FINISH_MT("sv/tb_mini.sv", 269, "");
    }
    if ((! VL_VALUEPLUSARGS_INN(64, "EXPECT=%s"s, vlSelfRef.tb_mini__DOT__expect_str))) {
        vlSelfRef.tb_mini__DOT__expect_str = ""s;
    }
    tb_mini__DOT__expected_sat = ("SAT"s == vlSelfRef.tb_mini__DOT__expect_str);
    if ((! VL_VALUEPLUSARGS_INQ(64, "MAXCYCLES=%d"s, 
                                vlSelfRef.tb_mini__DOT__max_cycles))) {
        vlSelfRef.tb_mini__DOT__max_cycles = 0x00000000004c4b40ULL;
    }
    if ((! VL_VALUEPLUSARGS_INI(32, "DEBUG=%d"s, vlSelfRef.tb_mini__DOT__DEBUG))) {
        vlSelfRef.tb_mini__DOT__DEBUG = 0U;
    }
    VL_WRITEF_NX("DEBUG ARG VALUE: %11d\n\n\n=====================================\nMini DPLL Testbench\n=====================================\nClock: 100 MHz (10ns period)\nMax Vars: 256\nMax Clauses: 256\nCNF File: %@\nExpected: %@\nMax Cycles: %0#\n\n\n",0,
                 32,vlSelfRef.tb_mini__DOT__DEBUG,-1,
                 &(vlSelfRef.tb_mini__DOT__cnf_file),
                 -1,&(vlSelfRef.tb_mini__DOT__expect_str),
                 64,vlSelfRef.tb_mini__DOT__max_cycles);
    __Vtask_tb_mini__DOT__run_test__0__max_cycles_arg 
        = vlSelfRef.tb_mini__DOT__max_cycles;
    __Vtask_tb_mini__DOT__run_test__0__expected_sat_arg 
        = tb_mini__DOT__expected_sat;
    __Vtask_tb_mini__DOT__run_test__0__cnf_file_arg 
        = vlSelfRef.tb_mini__DOT__cnf_file;
    __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    tb_mini__DOT__run_test__Vstatic__model_valid = 1U;
    VL_WRITEF_NX("\n========================================\nTEST: CNF Test\n========================================\n",0);
    vlSelfRef.tb_mini__DOT__rst_n = 0U;
    vlSelfRef.tb_mini__DOT__host_load_valid = 0U;
    vlSelfRef.tb_mini__DOT__host_load_literal = 0U;
    vlSelfRef.tb_mini__DOT__host_load_clause_end = 0U;
    vlSelfRef.tb_mini__DOT__host_start = 0U;
    __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_1__DOT____Vrepeat0 = 4U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_mini.clk)", 
                                                             "sv/tb_mini.sv", 
                                                             208);
        __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (__Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_mini__DOT__rst_n = 1U;
    __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_2__DOT____Vrepeat1 = 2U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_mini.clk)", 
                                                             "sv/tb_mini.sv", 
                                                             210);
        __Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (__Vtask_tb_mini__DOT__run_test__0__tb_mini__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    tb_mini__DOT__start_time = VL_TIME_UNITED_D(1000);
    __Vtask_tb_mini__DOT__load_cnf_file__1__filename 
        = __Vtask_tb_mini__DOT__run_test__0__cnf_file_arg;
    __Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i = 0;
    VL_WRITEF_NX("[%0t] Loading CNF file: %@\n[DEBUG] host_load_ready = %0#\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9,-1,&(__Vtask_tb_mini__DOT__load_cnf_file__1__filename),
                 1,(IData)(vlSelfRef.tb_mini__DOT__host_load_ready));
    tb_mini__DOT__load_cnf_file__Vstatic__fd = VL_FOPEN_NN(__Vtask_tb_mini__DOT__load_cnf_file__1__filename
                                                           , "r"s);
    ;
    if (VL_UNLIKELY(((0U == tb_mini__DOT__load_cnf_file__Vstatic__fd)))) {
        VL_WRITEF_NX("ERROR: Cannot open file %@\n",0,
                     -1,&(__Vtask_tb_mini__DOT__load_cnf_file__1__filename));
        VL_FINISH_MT("sv/tb_mini.sv", 97, "");
    }
    tb_mini__DOT__clause_count = 0U;
    vlSelfRef.tb_mini__DOT__clause_store.clear();
    while ((! (tb_mini__DOT__load_cnf_file__Vstatic__fd ? feof(VL_CVT_I_FP(tb_mini__DOT__load_cnf_file__Vstatic__fd)) : true))) {
        {
            if ((0U != VL_FGETS_NI(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line, tb_mini__DOT__load_cnf_file__Vstatic__fd))) {
                if ((0x63U == VL_GETC_N(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,0U))) {
                    goto __Vlabel0;
                }
                if ((0x70U == VL_GETC_N(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,0U))) {
                    vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__scan_result 
                        = VL_SSCANF_INNX(64,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,"p cnf %# %#",0,
                                         32,&(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__num_vars),
                                         32,&(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__num_clauses)) ;
                    if (VL_UNLIKELY(((2U == vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__scan_result)))) {
                        VL_WRITEF_NX("  Problem: %0d variables, %0d clauses\n",0,
                                     32,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__num_vars,
                                     32,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__num_clauses);
                    }
                    goto __Vlabel0;
                }
                vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos = 0U;
                vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__literals.clear();
                {
                    while (VL_LTS_III(32, vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos, 
                                      VL_LEN_IN(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line))) {
                        vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__scan_result 
                            = VL_SSCANF_INNX(64,VL_SUBSTR_N(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos,
                                                            (VL_LEN_IN(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line) 
                                                             - (IData)(1U))),"%#",0,
                                             32,&(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__lit)) ;
                        if ((1U == vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__scan_result)) {
                            if ((0U == vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__lit)) {
                                __Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i = 0U;
                                while (VL_LTS_III(32, __Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i, vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__literals.size())) {
                                    __Vtask_tb_mini__DOT__push_literal__2__clause_end 
                                        = (__Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i 
                                           == (vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__literals.size() 
                                               - (IData)(1U)));
                                    __Vtask_tb_mini__DOT__push_literal__2__lit 
                                        = vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__literals.at(__Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i);
                                    co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                                                nullptr, 
                                                                                "@(posedge tb_mini.clk)", 
                                                                                "sv/tb_mini.sv", 
                                                                                71);
                                    while ((1U & (~ (IData)(vlSelfRef.tb_mini__DOT__host_load_ready)))) {
                                        co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                                                nullptr, 
                                                                                "@(posedge tb_mini.clk)", 
                                                                                "sv/tb_mini.sv", 
                                                                                72);
                                    }
                                    vlSelfRef.tb_mini__DOT__host_load_valid = 1U;
                                    vlSelfRef.tb_mini__DOT__host_load_literal 
                                        = __Vtask_tb_mini__DOT__push_literal__2__lit;
                                    vlSelfRef.tb_mini__DOT__host_load_clause_end 
                                        = __Vtask_tb_mini__DOT__push_literal__2__clause_end;
                                    vlSelfRef.tb_mini__DOT__host_start = 0U;
                                    co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                                                nullptr, 
                                                                                "@(posedge tb_mini.clk)", 
                                                                                "sv/tb_mini.sv", 
                                                                                77);
                                    vlSelfRef.tb_mini__DOT__host_load_valid = 0U;
                                    vlSelfRef.tb_mini__DOT__host_load_clause_end = 0U;
                                    __Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i 
                                        = ((IData)(1U) 
                                           + __Vtask_tb_mini__DOT__load_cnf_file__1__unnamedblk1__DOT__unnamedblk2__DOT__i);
                                }
                                vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__clause_copy 
                                    = vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__literals;
                                vlSelfRef.tb_mini__DOT__clause_store.push_back(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__clause_copy);
                                tb_mini__DOT__clause_count 
                                    = ((IData)(1U) 
                                       + tb_mini__DOT__clause_count);
                                goto __Vlabel1;
                            } else {
                                vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__literals.push_back(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__lit);
                            }
                            while ((VL_LTS_III(32, vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos, 
                                               VL_LEN_IN(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line)) 
                                    & ((0x20U == VL_GETC_N(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos)) 
                                       | (9U == VL_GETC_N(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos))))) {
                                vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos 
                                    = ((IData)(1U) 
                                       + vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos);
                            }
                            if (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__lit)) {
                                vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos 
                                    = ((IData)(1U) 
                                       + vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos);
                            }
                            while (((VL_LTS_III(32, vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos, 
                                                VL_LEN_IN(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line)) 
                                     & (0x30U <= VL_GETC_N(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos))) 
                                    & (0x39U >= VL_GETC_N(vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__line,vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos)))) {
                                vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos 
                                    = ((IData)(1U) 
                                       + vlSelfRef.tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos);
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
    VL_FCLOSE_I(tb_mini__DOT__load_cnf_file__Vstatic__fd); VL_WRITEF_NX("  Loaded %0d clauses\nStarting solve at time %0t\n",0,
                                                                        32,
                                                                        tb_mini__DOT__clause_count,
                                                                        64,
                                                                        VL_TIME_UNITED_Q(1000),
                                                                        -9);
    co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mini.clk)", 
                                                         "sv/tb_mini.sv", 
                                                         216);
    vlSelfRef.tb_mini__DOT__host_start = 1U;
    co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mini.clk)", 
                                                         "sv/tb_mini.sv", 
                                                         218);
    vlSelfRef.tb_mini__DOT__host_start = 0U;
    tb_mini__DOT__cycle_count = 0ULL;
    while (((~ (IData)(vlSelfRef.tb_mini__DOT__host_done)) 
            & (tb_mini__DOT__cycle_count < __Vtask_tb_mini__DOT__run_test__0__max_cycles_arg))) {
        co_await vlSelfRef.__VtrigSched_h5e3d8791__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_mini.clk)", 
                                                             "sv/tb_mini.sv", 
                                                             223);
        tb_mini__DOT__cycle_count = (1ULL + tb_mini__DOT__cycle_count);
        if (VL_UNLIKELY(((0ULL == VL_MODDIV_QQQ(64, tb_mini__DOT__cycle_count, 0x00000000000186a0ULL))))) {
            VL_WRITEF_NX("[Cycle %0#] done=%0# sat=%0# unsat=%0#\n",0,
                         64,tb_mini__DOT__cycle_count,
                         1,(IData)(vlSelfRef.tb_mini__DOT__host_done),
                         1,vlSelfRef.tb_mini__DOT__host_sat,
                         1,(IData)(vlSelfRef.tb_mini__DOT__host_unsat));
        }
    }
    tb_mini__DOT__end_time = VL_TIME_UNITED_D(1000);
    VL_WRITEF_NX("[Final Cycle %0#] done=%0# sat=%0# unsat=%0#\n",0,
                 64,tb_mini__DOT__cycle_count,1,(IData)(vlSelfRef.tb_mini__DOT__host_done),
                 1,vlSelfRef.tb_mini__DOT__host_sat,
                 1,(IData)(vlSelfRef.tb_mini__DOT__host_unsat));
    if (vlSelfRef.tb_mini__DOT__host_done) {
        vlSelfRef.tb_mini__DOT__run_test__Vstatic__unnamedblk7__DOT__time_ms 
            = ((tb_mini__DOT__end_time - tb_mini__DOT__start_time) 
               / 1.00000000000000000e+06);
        VL_WRITEF_NX("\n=== RESULTS ===\n  Status: %s\n  Expected: %s\n  Cycles: %0#\n  Conflicts: %0#\n  Decisions: %0#\n  Sim Time: %.3f ms\n",0,
                     40,((IData)(vlSelfRef.tb_mini__DOT__host_sat)
                          ? 0x0000000000534154ULL : 0x000000554e534154ULL),
                     40,((IData)(__Vtask_tb_mini__DOT__run_test__0__expected_sat_arg)
                          ? 0x0000000000534154ULL : 0x000000554e534154ULL),
                     64,tb_mini__DOT__cycle_count,32,
                     vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_q,
                     32,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_q,
                     64,vlSelfRef.tb_mini__DOT__run_test__Vstatic__unnamedblk7__DOT__time_ms);
        if (VL_UNLIKELY((vlSelfRef.tb_mini__DOT__host_sat))) {
            __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c = 0;
            __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l = 0;
            __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l = 0;
            VL_WRITEF_NX("  Verifying model...\n",0);
            __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c = 0U;
            while (VL_LTS_III(32, __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c, vlSelfRef.tb_mini__DOT__clause_store.size())) {
                vlSelfRef.tb_mini__DOT__verify_model__Vstatic__clause_sat = 0U;
                __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l = 0U;
                while (VL_LTS_III(32, __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l, vlSelfRef.tb_mini__DOT__clause_store.at(__Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c).size())) {
                    vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit 
                        = vlSelfRef.tb_mini__DOT__clause_store.at(__Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c).at(__Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l);
                    vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__var_idx 
                        = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit)
                            ? (- vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit)
                            : vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit);
                    vlSelfRef.tb_mini__DOT__verify_model__Vstatic__state 
                        = ((VL_LTS_III(32, 0U, vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__var_idx) 
                            & VL_GTES_III(32, 0x00000100U, vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__var_idx))
                            ? vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                           [(0x000000ffU & (vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__var_idx 
                                            - (IData)(1U)))]
                            : 0U);
                    if ((VL_LTS_III(32, 0U, vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit) 
                         & (2U == (IData)(vlSelfRef.tb_mini__DOT__verify_model__Vstatic__state)))) {
                        vlSelfRef.tb_mini__DOT__verify_model__Vstatic__clause_sat = 1U;
                    }
                    if ((VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit) 
                         & (1U == (IData)(vlSelfRef.tb_mini__DOT__verify_model__Vstatic__state)))) {
                        vlSelfRef.tb_mini__DOT__verify_model__Vstatic__clause_sat = 1U;
                    }
                    __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l 
                        = ((IData)(1U) + __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk4__DOT__l);
                }
                if ((1U & (~ (IData)(vlSelfRef.tb_mini__DOT__verify_model__Vstatic__clause_sat)))) {
                    vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unsat_clauses 
                        = ((IData)(1U) + vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unsat_clauses);
                    if (VL_UNLIKELY((VL_GTES_III(32, 3U, vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unsat_clauses)))) {
                        VL_WRITEF_NX("    Failed Clause %0d: {\n",0,
                                     32,__Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c);
                        __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l = 0U;
                        while (VL_LTS_III(32, __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l, vlSelfRef.tb_mini__DOT__clause_store.at(__Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c).size())) {
                            VL_WRITEF_NX("      lit=%0d\n",0,
                                         32,vlSelfRef.tb_mini__DOT__clause_store.at(__Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c).at(__Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l));
                            __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l 
                                = ((IData)(1U) + __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__unnamedblk6__DOT__l);
                        }
                        VL_WRITEF_NX("    }\n",0);
                    }
                }
                __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c 
                    = ((IData)(1U) + __Vtask_tb_mini__DOT__verify_model__3__unnamedblk3__DOT__c);
            }
            if ((0U == vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unsat_clauses)) {
                VL_WRITEF_NX("  MODEL VERIFIED: Valid.\n",0);
                __Vtask_tb_mini__DOT__verify_model__3__valid = 1U;
            } else {
                VL_WRITEF_NX("  MODEL INVALID: %0d clauses not satisfied.\n",0,
                             32,vlSelfRef.tb_mini__DOT__verify_model__Vstatic__unsat_clauses);
                __Vtask_tb_mini__DOT__verify_model__3__valid = 0U;
            }
            tb_mini__DOT__run_test__Vstatic__model_valid 
                = __Vtask_tb_mini__DOT__verify_model__3__valid;
        }
        if ((((IData)(vlSelfRef.tb_mini__DOT__host_sat) 
              == (IData)(__Vtask_tb_mini__DOT__run_test__0__expected_sat_arg)) 
             & (IData)(tb_mini__DOT__run_test__Vstatic__model_valid))) {
            VL_WRITEF_NX("\n*** TEST PASSED ***\n\n",0);
            vlSelfRef.tb_mini__DOT__passed_tests = 
                ((IData)(1U) + vlSelfRef.tb_mini__DOT__passed_tests);
        } else {
            VL_WRITEF_NX("\n*** TEST FAILED ***\n\n",0);
            vlSelfRef.tb_mini__DOT__failed_tests = 
                ((IData)(1U) + vlSelfRef.tb_mini__DOT__failed_tests);
        }
    } else {
        VL_WRITEF_NX("\n=== TIMEOUT ===\n  Exceeded %0# cycles\n\n*** TEST FAILED ***\n\n",0,
                     64,__Vtask_tb_mini__DOT__run_test__0__max_cycles_arg);
        vlSelfRef.tb_mini__DOT__failed_tests = ((IData)(1U) 
                                                + vlSelfRef.tb_mini__DOT__failed_tests);
    }
    VL_WRITEF_NX("\n\n=====================================\nMINI DPLL TEST SUMMARY\n=====================================\nPASSED: %0d\nFAILED: %0d\n=====================================\n",0,
                 32,vlSelfRef.tb_mini__DOT__passed_tests,
                 32,vlSelfRef.tb_mini__DOT__failed_tests);
    if (VL_UNLIKELY(((VL_LTS_III(32, 0U, vlSelfRef.tb_mini__DOT__passed_tests) 
                      & (0U == vlSelfRef.tb_mini__DOT__failed_tests))))) {
        VL_WRITEF_NX("TEST PASSED\n",0);
    }
    VL_FINISH_MT("sv/tb_mini.sv", 312, "");
    co_return;}

VlCoroutine Vtb_mini___024root___eval_initial__TOP__Vtiming__1(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x000110d9316ec000ULL, 
                                         nullptr, "sv/tb_mini.sv", 
                                         317);
    VL_WRITEF_NX("\n*** GLOBAL TIMEOUT - ABORTING ***\n",0);
    VL_FINISH_MT("sv/tb_mini.sv", 319, "");
    co_return;}

VlCoroutine Vtb_mini___024root___eval_initial__TOP__Vtiming__2(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_initial__TOP__Vtiming__2\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "sv/tb_mini.sv", 
                                             50);
        vlSelfRef.tb_mini__DOT__clk = (1U & (~ (IData)(vlSelfRef.tb_mini__DOT__clk)));
    }
    co_return;}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mini___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vtb_mini___024root___eval_triggers__act(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_triggers__act\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                       << 3U) 
                                                      | (((~ (IData)(vlSelfRef.tb_mini__DOT__rst_n)) 
                                                          & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__rst_n__0)) 
                                                         << 2U)) 
                                                     | ((((IData)(vlSelfRef.tb_mini__DOT__clk) 
                                                          & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__clk__0))) 
                                                         << 1U) 
                                                        | ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start) 
                                                           != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start__1))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start__1 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__clk__0 
        = vlSelfRef.tb_mini__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mini__DOT__rst_n__0 
        = vlSelfRef.tb_mini__DOT__rst_n;
    if (VL_UNLIKELY(((1U & (~ (IData)(vlSelfRef.__VactDidInit)))))) {
        vlSelfRef.__VactDidInit = 1U;
        vlSelfRef.__VactTriggered[0U] = (1ULL | vlSelfRef.__VactTriggered
                                         [0U]);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mini___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vtb_mini___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___trigger_anySet__act\n"); );
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

void Vtb_mini___024root___act_sequent__TOP__0(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___act_sequent__TOP__0\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire 
        = ((IData)(vlSelfRef.tb_mini__DOT__host_load_valid) 
           & (IData)(vlSelfRef.tb_mini__DOT__host_load_ready));
}

void Vtb_mini___024root___act_comb__TOP__0(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___act_comb__TOP__0\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done;
    tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done = 0;
    CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict;
    tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict = 0;
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v = 0;
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit = 0;
    SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1 = 0;
    SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2 = 0;
    SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart = 0;
    SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen = 0;
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch = 0;
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other = 0;
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l = 0;
    CData/*1:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth = 0;
    CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 0;
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit = 0;
    // Body
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1 = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2 = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit = 0U;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_d 
        = ((~ (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start)) 
           & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q));
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_valid = 0U;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var = 0U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done = 0U;
    if ((8U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
        if ((4U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 0U;
        } else if ((2U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 0U;
        } else if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 9U;
        } else {
            tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done = 1U;
            if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start) {
                if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q) {
                    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 4U;
                } else {
                    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d = 0U;
                    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 2U;
                }
            } else if ((1U & ((~ (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q)) 
                              & (~ (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty))))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 6U;
            } else if ((1U & (~ (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start)))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 0U;
            }
        }
    } else if ((4U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
        if ((2U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
            if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
                if ((0xffffU == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))) {
                    if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q) {
                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 6U;
                    } else {
                        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit 
                            = (- vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_q);
                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_d = 1U;
                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d 
                            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2
                            [(0x000001ffU & ([&]() {
                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit;
                                    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__raw_idx = 0;
                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__v 
                                        = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__lit)
                                            ? (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__lit)
                                            : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__lit);
                                    if (((0U == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__v) 
                                         | (0x00000100U 
                                            < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__v))) {
                                        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__Vfuncout = 0U;
                                    } else {
                                        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__raw_idx 
                                            = (0x0000ffffU 
                                               & (VL_LTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__lit)
                                                   ? 
                                                  VL_SHIFTL_III(32,32,32, 
                                                                (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__v 
                                                                 - (IData)(1U)), 1U)
                                                   : 
                                                  ((IData)(1U) 
                                                   + 
                                                   VL_SHIFTL_III(32,32,32, 
                                                                 (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__v 
                                                                  - (IData)(1U)), 1U))));
                                        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__Vfuncout 
                                            = ((0x0200U 
                                                > (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__raw_idx))
                                                ? (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__raw_idx)
                                                : 0U);
                                    }
                                }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__Vfuncout)))];
                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d = 0xffffU;
                    }
                } else if ((0x0100U <= (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))) {
                    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 8U;
                } else {
                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1 
                        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1
                        [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))];
                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2 
                        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2
                        [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))];
                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart 
                        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start
                        [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))];
                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen 
                        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len
                        [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))];
                    if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q) {
                        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch 
                            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                            [(0x000007ffU & (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2))];
                        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other 
                            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                            [(0x000007ffU & (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1))];
                    } else {
                        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch 
                            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                            [(0x000007ffU & (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1))];
                        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other 
                            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                            [(0x000007ffU & (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2))];
                    }
                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__lit 
                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other;
                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__v 
                        = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__lit)
                            ? (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__lit)
                            : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__lit);
                    if (((0U == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__v) 
                         | (0x00000100U < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__v))) {
                        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout = 0U;
                    } else {
                        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout 
                            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                            [(0x000000ffU & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__v 
                                             - (IData)(1U)))];
                        if (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__lit)) {
                            if ((1U == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout))) {
                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout = 2U;
                            } else if ((2U == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout))) {
                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout = 1U;
                            }
                        }
                    }
                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth 
                        = vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout;
                    if (((2U == (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth)) 
                         | (1U != ([&]() {
                                        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__lit 
                                            = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_watch;
                                        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__v 
                                            = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__lit)
                                                ? (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__lit)
                                                : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__lit);
                                        if (((0U == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__v) 
                                             | (0x00000100U 
                                                < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__v))) {
                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout = 0U;
                                        } else {
                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout 
                                                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                [(0x000000ffU 
                                                  & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__v 
                                                     - (IData)(1U)))];
                                            if (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__lit)) {
                                                if (
                                                    (1U 
                                                     == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout = 2U;
                                                } else if (
                                                           (2U 
                                                            == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout = 1U;
                                                }
                                            }
                                        }
                                    }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout))))) {
                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d 
                            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q;
                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d 
                            = ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q)
                                ? vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2
                               [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))]
                                : vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1
                               [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))]);
                    } else {
                        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 0U;
                        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit = 0U;
                        if ((0U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen))) {
                            if ((((IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & ((IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (1U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(1U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(1U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(1U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (2U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(2U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(2U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(2U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (3U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(3U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(3U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(3U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (4U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(4U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(4U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(4U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (5U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(5U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(5U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(5U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (6U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(6U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(6U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(6U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (7U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(7U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(7U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(7U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (8U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(8U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(8U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(8U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (9U < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(9U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(9U) + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(9U) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (0x000aU < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(0x0000000aU) 
                                   + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(0x0000000aU) 
                                     + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(0x000aU) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (0x000bU < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(0x0000000bU) 
                                   + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(0x0000000bU) 
                                     + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(0x000bU) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (0x000cU < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(0x0000000cU) 
                                   + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(0x0000000cU) 
                                     + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(0x000cU) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (0x000dU < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(0x0000000dU) 
                                   + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(0x0000000dU) 
                                     + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(0x000dU) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (0x000eU < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(0x0000000eU) 
                                   + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(0x0000000eU) 
                                     + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(0x000eU) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (((~ (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl)) 
                             & (0x000fU < (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__clen)))) {
                            if (((((IData)(0x0000000fU) 
                                   + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                  != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w1)) 
                                 & (((IData)(0x0000000fU) 
                                     + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)) 
                                    != (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__w2)))) {
                                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l 
                                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
                                    [(0x000007ffU & 
                                      ((IData)(0x000fU) 
                                       + (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__cstart)))];
                                if ((1U != ([&]() {
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit 
                                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                    = 
                                                    (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      ? 
                                                     (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)
                                                      : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit);
                                                if (
                                                    ((0U 
                                                      == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v) 
                                                     | (0x00000100U 
                                                        < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v))) {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 0U;
                                                } else {
                                                    vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout 
                                                        = 
                                                        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                                                        [
                                                        (0x000000ffU 
                                                         & (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v 
                                                            - (IData)(1U)))];
                                                    if (
                                                        VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit)) {
                                                        if (
                                                            (1U 
                                                             == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 2U;
                                                        } else if (
                                                                   (2U 
                                                                    == (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout))) {
                                                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout = 1U;
                                                        }
                                                    }
                                                }
                                            }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout)))) {
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl = 1U;
                                    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit 
                                        = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__l;
                                }
                            }
                        }
                        if (tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__found_repl) {
                            if ((1U == (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth))) {
                                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_valid = 1U;
                                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var 
                                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit;
                                if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                                    VL_WRITEF_NX("[PSE] Unit %0d from Clause %0# (after repl)\n",0,
                                                 32,
                                                 tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__repl_lit,
                                                 16,
                                                 (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q));
                                }
                            }
                            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d 
                                = ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q)
                                    ? vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2
                                   [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))]
                                    : vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1
                                   [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))]);
                        } else if ((0U == (IData)(tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__other_truth))) {
                            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_valid = 1U;
                            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var 
                                = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other;
                            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d 
                                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q;
                            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d 
                                = ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q)
                                    ? vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2
                                   [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))]
                                    : vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1
                                   [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q))]);
                            if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                                VL_WRITEF_NX("[PSE] Unit %0d from Clause %0#\n",0,
                                             32,tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__lit_other,
                                             16,(IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q));
                            }
                        } else {
                            if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                                VL_WRITEF_NX("[PSE] Conflict in Clause %0#\n",0,
                                             16,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q);
                            }
                            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_d = 1U;
                            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 8U;
                        }
                    }
                }
            } else if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty) {
                tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done = 1U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 8U;
            } else {
                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit 
                    = (- vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue
                       [(0x000007ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr))]);
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_d 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue
                    [(0x000007ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr))];
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_d = 0U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1
                    [(0x000001ffU & ([&]() {
                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__lit 
                                = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__neg_lit;
                            vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__raw_idx = 0;
                            vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__v 
                                = (VL_GTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__lit)
                                    ? (- vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__lit)
                                    : vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__lit);
                            if (((0U == vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__v) 
                                 | (0x00000100U < vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__v))) {
                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__Vfuncout = 0U;
                            } else {
                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__raw_idx 
                                    = (0x0000ffffU 
                                       & (VL_LTS_III(32, 0U, vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__lit)
                                           ? VL_SHIFTL_III(32,32,32, 
                                                           (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__v 
                                                            - (IData)(1U)), 1U)
                                           : ((IData)(1U) 
                                              + VL_SHIFTL_III(32,32,32, 
                                                              (vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__v 
                                                               - (IData)(1U)), 1U))));
                                vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__Vfuncout 
                                    = ((0x0200U > (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__raw_idx))
                                        ? (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__raw_idx)
                                        : 0U);
                            }
                        }(), (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__Vfuncout)))];
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d = 0xffffU;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 7U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 6U;
        } else {
            if ((0U != vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q)) {
                tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                    = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q)
                        ? (- vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q)
                        : vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q);
            }
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_d = 0U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 5U;
        }
    } else if ((2U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
        if (VL_LIKELY(((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))))) {
            if (VL_UNLIKELY((((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q) 
                              < (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q))))) {
                VL_WRITEF_NX("[PSE] INIT Idx: %0# Count: %0#\n",0,
                             16,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q,
                             16,(IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q));
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_d 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q)));
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 3U;
            } else {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_d = 1U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 4U;
            }
        } else {
            VL_WRITEF_NX("[PSE] RESET Idx: %0# Limit: 768\n",0,
                         16,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q);
            if ((0x0300U > (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q)));
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 2U;
            } else {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_d = 0U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 3U;
            }
        }
    } else if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
        if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire) {
            tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__host_load_literal)
                    ? (- vlSelfRef.tb_mini__DOT__host_load_literal)
                    : vlSelfRef.tb_mini__DOT__host_load_literal);
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q)));
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q)));
            if ((tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v 
                 > vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q)) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_d 
                    = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v;
            }
            if (vlSelfRef.tb_mini__DOT__host_load_clause_end) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_d 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q)));
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d = 0U;
            }
        } else if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start) {
            if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 4U;
            } else {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d = 0U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 2U;
            }
        } else {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 0U;
        }
    } else if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire) {
        tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v 
            = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__host_load_literal)
                ? (- vlSelfRef.tb_mini__DOT__host_load_literal)
                : vlSelfRef.tb_mini__DOT__host_load_literal);
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d 
            = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q)));
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_d 
            = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q)));
        if ((tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v 
             > vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q)) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_d 
                = tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__unnamedblk1__DOT__v;
        }
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 1U;
        if (vlSelfRef.tb_mini__DOT__host_load_clause_end) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_d 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q)));
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d = 0U;
        }
    } else if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start) {
        if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d 
                = (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q) 
                    < (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q))
                    ? 3U : 4U);
        } else {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d = 0U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d = 2U;
        }
    }
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_v 
        = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var)
            ? (- vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var)
            : vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var);
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_d 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start = 0U;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_decision_var = 0U;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_enable = 0U;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height = 0U;
    vlSelfRef.tb_mini__DOT__host_done = 0U;
    vlSelfRef.tb_mini__DOT__host_sat = 0U;
    vlSelfRef.tb_mini__DOT__host_unsat = 0U;
    if ((8U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
        if ((4U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            if ((2U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 0U;
            } else if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 0U;
            } else {
                vlSelfRef.tb_mini__DOT__host_done = 1U;
                vlSelfRef.tb_mini__DOT__host_unsat = 1U;
                if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                    VL_WRITEF_NX("[DPLL] Result: UNSAT\n",0);
                }
            }
        } else if ((2U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
                if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                    VL_WRITEF_NX("[DPLL] Result: SAT\n",0);
                }
                vlSelfRef.tb_mini__DOT__host_done = 1U;
                vlSelfRef.tb_mini__DOT__host_sat = 1U;
            } else if (vlSelfRef.tb_mini__DOT__host_load_ready) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 9U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_decision_var 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack
                [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                 - (IData)(1U)))];
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start = 1U;
            if ((1U & (~ (IData)(vlSelfRef.tb_mini__DOT__host_load_ready)))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 4U;
            }
        } else if (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q) 
                    > vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim
                    [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                     - (IData)(1U)))])) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_enable = 1U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim
                [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                 - (IData)(1U)))];
        } else {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 0x0aU;
        }
    } else if ((4U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
        if ((2U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
                if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                    VL_WRITEF_NX("[DPLL] Flipping to: %0# at Level %0# (undo to %0#). WRITE tried_pos[%0#] <= 1\n",0,
                                 32,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack
                                 [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                                  - (IData)(1U)))],
                                 16,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q,
                                 16,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim
                                 [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                                  - (IData)(1U)))],
                                 32,((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                     - (IData)(1U)));
                }
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_enable = 1U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim
                    [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                     - (IData)(1U)))];
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 8U;
            } else {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d 
                    = (0x0000ffffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                      - (IData)(1U)));
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_enable = 1U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim
                    [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                     - (IData)(1U)))];
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d 
                    = ((0U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d))
                        ? 0x0cU : 5U);
            }
        } else if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            if ((0U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q))) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 0x0cU;
            } else {
                if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                    VL_WRITEF_NX("[DPLL] Conflict at Level %0#. Tried Pos[%0#] = %b\n",0,
                                 16,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q,
                                 32,((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                     - (IData)(1U)),
                                 1,(1U & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[
                                          (7U & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                                  - (IData)(1U)) 
                                                 >> 5U))] 
                                          >> (0x0000001fU 
                                              & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                                 - (IData)(1U))))));
                }
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d 
                    = ((1U & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[
                              (7U & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                      - (IData)(1U)) 
                                     >> 5U))] >> (0x0000001fU 
                                                  & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q) 
                                                     - (IData)(1U)))))
                        ? 6U : 7U);
            }
        } else if (tb_mini__DOT__dut__DOT__u_solver__DOT__pse_done) {
            if (tb_mini__DOT__dut__DOT__u_solver__DOT__pse_conflict) {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_d 
                    = ((IData)(1U) + vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_q);
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 5U;
            } else {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d 
                    = ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned)
                        ? 0x0bU : 3U);
            }
        }
    } else if ((2U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
        if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            if ((0U != vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var)) {
                if (VL_UNLIKELY((VL_LTES_III(32, 1U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
                    VL_WRITEF_NX("[DPLL] Decided: %0d at Level %0# (NextVar: %0# MaxSeen: %0#)\n",0,
                                 32,(- vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var),
                                 32,((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q)),
                                 32,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var,
                                 32,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q);
                }
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q)));
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_d 
                    = ((IData)(1U) + vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_q);
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_decision_var 
                    = (- vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var);
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start = 1U;
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 4U;
            } else {
                vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 0x0bU;
            }
        } else {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 0U;
        }
    } else if ((1U & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 0U;
    } else {
        if (VL_UNLIKELY((VL_LTS_III(32, 0U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
            VL_WRITEF_NX("[CORE] State: %2# Level: %0#\n",0,
                         4,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q,
                         16,(IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q));
        }
        if (vlSelfRef.tb_mini__DOT__host_start) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d = 0U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_d = 0U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_d = 0U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start = 1U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d = 4U;
        }
    }
}

void Vtb_mini___024root___eval_act(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_act\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((2ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire 
            = ((IData)(vlSelfRef.tb_mini__DOT__host_load_valid) 
               & (IData)(vlSelfRef.tb_mini__DOT__host_load_ready));
    }
    if ((3ULL & vlSelfRef.__VactTriggered[0U])) {
        Vtb_mini___024root___act_comb__TOP__0(vlSelf);
    }
}

void Vtb_mini___024root___nba_sequent__TOP__0(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___nba_sequent__TOP__0\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<8>/*255:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg;
    VL_ZERO_W(256, tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg);
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v;
    tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v = 0;
    IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_raw_var;
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_raw_var = 0;
    IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit;
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit = 0;
    IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v;
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v = 0;
    IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__lit;
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__lit = 0;
    IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__v;
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__v = 0;
    CData/*3:0*/ __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q;
    __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q = 0;
    SData/*15:0*/ __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr;
    __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr = 0;
    SData/*15:0*/ __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q;
    __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q = 0;
    IData/*31:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v1 = 0;
    IData/*31:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0 = 0;
    SData/*10:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v0 = 0;
    SData/*8:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0 = 0;
    SData/*8:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v0 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1 = 0;
    SData/*8:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1 = 0;
    SData/*15:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1 = 0;
    SData/*8:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1 = 0;
    CData/*1:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1 = 0;
    IData/*31:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0 = 0;
    SData/*10:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0 = 0;
    IData/*31:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0 = 0;
    CData/*1:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2 = 0;
    IData/*31:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1 = 0;
    SData/*10:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1 = 0;
    IData/*31:0*/ __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1;
    __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1 = 0;
    CData/*7:0*/ __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3;
    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3 = 0;
    CData/*0:0*/ __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3 = 0;
    // Body
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0 = 0U;
    __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q;
    __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0 = 0U;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0 = 0U;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3 = 0U;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0 = 0U;
    __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0 = 0U;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1 = 0U;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2 = 0U;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0 = 0U;
    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1 = 0U;
    if (vlSelfRef.tb_mini__DOT__rst_n) {
        if (VL_UNLIKELY((VL_LTS_III(32, 0U, vlSelfRef.tb_mini__DOT__DEBUG)))) {
            VL_WRITEF_NX("[CORE] State: %2# Level: %0#\n",0,
                         4,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q,
                         16,(IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q));
        }
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_d;
        if (((3U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q)) 
             & (0U != vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var))) {
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var;
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr;
            vlSelfRef.__VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack.enqueue(__VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0, (IData)(__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v0));
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                                                                >> 5U)] 
                = ((~ ((IData)(1U) << (0x0000001fU 
                                       & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr)))) 
                   & vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[
                   ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                    >> 5U)]);
            tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg[((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                                                       >> 5U)] 
                = (tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg[
                   ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                    >> 5U)] | ((IData)(1U) << (0x0000001fU 
                                               & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr))));
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q;
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr;
            vlSelfRef.__VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim.enqueue(__VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0, (IData)(__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v0));
        }
        if ((7U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[(7U 
                                                                                & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                                                                - (IData)(1U)) 
                                                                                >> 5U))] 
                = (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[
                   (7U & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                           - (IData)(1U)) >> 5U))] 
                   | ((IData)(1U) << (0x0000001fU & 
                                      ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                       - (IData)(1U)))));
        }
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d;
        if ((6U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[(7U 
                                                                                & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                                                                - (IData)(1U)) 
                                                                                >> 5U))] 
                = ((~ ((IData)(1U) << (0x0000001fU 
                                       & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                          - (IData)(1U))))) 
                   & vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[
                   (7U & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                           - (IData)(1U)) >> 5U))]);
            tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg[(7U 
                                                                       & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                                                           - (IData)(1U)) 
                                                                          >> 5U))] 
                = ((~ ((IData)(1U) << (0x0000001fU 
                                       & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                                          - (IData)(1U))))) 
                   & tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg[
                   (7U & (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr) 
                           - (IData)(1U)) >> 5U))]);
        }
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_d;
    } else {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__state_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_q = 0U;
        while (VL_GTS_III(32, 0x00000100U, vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i)) {
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v1 
                = (0x000000ffU & vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i);
            vlSelfRef.__VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack.enqueue(0U, (IData)(__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack__v1));
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[(7U 
                                                                                & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i 
                                                                                >> 5U))] 
                = ((~ ((IData)(1U) << (0x0000001fU 
                                       & vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i))) 
                   & vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos[
                   (7U & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i 
                          >> 5U))]);
            tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg[(7U 
                                                                       & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i 
                                                                          >> 5U))] 
                = ((~ ((IData)(1U) << (0x0000001fU 
                                       & vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i))) 
                   & tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_neg[
                   (7U & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i 
                          >> 5U))]);
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v1 
                = (0x000000ffU & vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i);
            vlSelfRef.__VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim.enqueue(0U, (IData)(__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim__v1));
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i 
                = ((IData)(1U) + vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i);
        }
    }
    if (VL_UNLIKELY((vlSelfRef.tb_mini__DOT__rst_n))) {
        VL_WRITEF_NX("[PSE] State: %2# Scan: %0#\n",0,
                     4,vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q,
                     16,(IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q));
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_d;
        __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_d;
        if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire) {
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0 
                = vlSelfRef.tb_mini__DOT__host_load_literal;
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0 
                = (0x000007ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q));
            __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0 = 1U;
            if (vlSelfRef.tb_mini__DOT__host_load_clause_end) {
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0 
                    = (0x0000ffffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q) 
                                      - (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q)));
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q));
                __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0 = 1U;
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q)));
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q));
            }
        }
        if ((2U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
            if ((0x0100U > (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q))) {
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q));
                __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0 = 1U;
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q));
                __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0 = 1U;
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q));
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q));
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q));
            } else if ((0x0300U > (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q))) {
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0 
                    = (0x000001ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q) 
                                      - (IData)(0x0100U)));
                __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0 = 1U;
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v0 
                    = (0x000001ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q) 
                                      - (IData)(0x0100U)));
            }
        }
        if (((3U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
             & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q) 
                < (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q)))) {
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w1_addr;
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1 
                = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q));
            __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1 = 1U;
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w2_addr;
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1 
                = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q));
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1
                [(0x000001ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx1))];
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1 
                = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q));
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q;
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1 
                = (0x000001ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx1));
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2
                [(0x000001ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx2))];
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1 
                = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q));
            __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q;
            __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1 
                = (0x000001ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx2));
        }
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d;
        if (((4U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
             & (0U != vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q))) {
            if ((((0U < vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__seed_v) 
                  & (0x00000100U >= vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__seed_v)) 
                 & (0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                    [(0x000000ffU & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__seed_v 
                                     - (IData)(1U)))]))) {
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1 
                    = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q)
                        ? 1U : 2U);
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1 
                    = (0x000000ffU & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__seed_v 
                                      - (IData)(1U)));
                __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1 = 1U;
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q;
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0 
                    = (0x000007ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr));
                __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr)));
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q;
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q));
                __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0 = 1U;
                __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q)));
            }
        }
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d;
        if (((6U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
             & (~ (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty)))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr 
                = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr)));
        }
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_d;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q 
            = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_d;
        if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_valid) {
            if ((((0U < vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_v) 
                  & (0x00000100U >= vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_v)) 
                 & (0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                    [(0x000000ffU & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_v 
                                     - (IData)(1U)))]))) {
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2 
                    = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var)
                        ? 1U : 2U);
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2 
                    = (0x000000ffU & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_v 
                                      - (IData)(1U)));
                __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2 = 1U;
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var;
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1 
                    = (0x000007ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr));
                __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1 
                    = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var;
                __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1 
                    = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q));
                __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr)));
                __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q)));
            }
        }
        if (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q 
                = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_decision_var;
        }
        if ((((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_enable) 
              & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q) 
                 > (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height))) 
             & (9U != (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)))) {
            __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr = 0U;
            __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q = 9U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q = 0U;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr = 0U;
        }
        if ((9U == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))) {
            if (((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q) 
                 > (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height))) {
                __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q 
                    = (0x0000ffffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q) 
                                      - (IData)(1U)));
                if (((0U < vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_var_idx) 
                     & (0x00000100U >= vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_var_idx))) {
                    __VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3 
                        = (0x000000ffU & (vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_var_idx 
                                          - (IData)(1U)));
                    __VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3 = 1U;
                }
                __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q = 9U;
            } else {
                __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q = 0U;
            }
        }
    } else {
        __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr = 0U;
        __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q = 0U;
        __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q = 0xffffU;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_q = 0xffffU;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr = 0U;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q = 0U;
    }
    vlSelfRef.__VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack.commit(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack);
    vlSelfRef.__VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim.commit(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim);
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q 
        = __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr 
        = __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr;
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem__v0;
    }
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q 
        = __Vdly__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q;
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len__v0;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start__v0;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v0;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v0;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v0] = 0U;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v1;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem__v1;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue__v1;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v2;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state__v3] = 0U;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v0] = 0xffffU;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v0] = 0xffffU;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v0] = 0xffffU;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v0] = 0xffffU;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v0] = 0xffffU;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v0] = 0xffffU;
    }
    if (__VdlySet__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1__v1;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2__v1;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1__v1;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2__v1;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1__v1;
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2[__VdlyDim0__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1] 
            = __VdlyVal__tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2__v1;
    }
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr 
        = (0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q));
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__seed_v 
        = (VL_GTS_III(32, 0U, vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q)
            ? (- vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q)
            : vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q);
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty 
        = ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr) 
           == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr));
    vlSelfRef.tb_mini__DOT__host_load_ready = ((0U 
                                                == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
                                               | ((1U 
                                                   == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q)) 
                                                  | (8U 
                                                     == (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q))));
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w1_addr 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start
        [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q))];
    tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_raw_var 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem
        [(0x000000ffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q) 
                         - (IData)(1U)))];
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var = 0U;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned = 1U;
    tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v = 1U;
    while (VL_GTES_III(32, 0x00000100U, tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v)) {
        if ((((tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
               <= vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q) 
              & (0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state
                 [(0x000000ffU & (tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
                                  - (IData)(1U)))])) 
             & (0U == vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var))) {
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__next_var 
                = tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v;
            vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned = 0U;
        }
        tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v 
            = ((IData)(1U) + tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk1__DOT__v);
    }
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
        [(0x000007ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w1_addr))];
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__raw_idx = 0;
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v 
        = (VL_GTS_III(32, 0U, __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit)
            ? (- __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit)
            : __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit);
    if (((0U == __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v) 
         | (0x00000100U < __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v))) {
        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__Vfuncout = 0U;
    } else {
        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__raw_idx 
            = (0x0000ffffU & (VL_LTS_III(32, 0U, __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__lit)
                               ? VL_SHIFTL_III(32,32,32, 
                                               (__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v 
                                                - (IData)(1U)), 1U)
                               : ((IData)(1U) + VL_SHIFTL_III(32,32,32, 
                                                              (__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__v 
                                                               - (IData)(1U)), 1U))));
        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__Vfuncout 
            = ((0x0200U > (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__raw_idx))
                ? (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__raw_idx)
                : 0U);
    }
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx1 
        = vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__Vfuncout;
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w2_addr 
        = (0x0000ffffU & ((IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w1_addr) 
                          + (1U < vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len
                             [(0x000000ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q))])));
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_var_idx 
        = (VL_GTS_III(32, 0U, tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_raw_var)
            ? (- tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_raw_var)
            : tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_raw_var);
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__lit 
        = vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem
        [(0x000007ffU & (IData)(vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w2_addr))];
    vlSelf->__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__raw_idx = 0;
    __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__v 
        = (VL_GTS_III(32, 0U, __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__lit)
            ? (- __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__lit)
            : __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__lit);
    if (((0U == __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__v) 
         | (0x00000100U < __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__v))) {
        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__Vfuncout = 0U;
    } else {
        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__raw_idx 
            = (0x0000ffffU & (VL_LTS_III(32, 0U, __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__lit)
                               ? VL_SHIFTL_III(32,32,32, 
                                               (__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__v 
                                                - (IData)(1U)), 1U)
                               : ((IData)(1U) + VL_SHIFTL_III(32,32,32, 
                                                              (__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__v 
                                                               - (IData)(1U)), 1U))));
        vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__Vfuncout 
            = ((0x0200U > (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__raw_idx))
                ? (IData)(vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__raw_idx)
                : 0U);
    }
    vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx2 
        = vlSelfRef.__Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__Vfuncout;
}

void Vtb_mini___024root___eval_nba(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_nba\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((6ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_mini___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((6ULL & vlSelfRef.__VnbaTriggered[0U])) {
        vlSelfRef.tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire 
            = ((IData)(vlSelfRef.tb_mini__DOT__host_load_valid) 
               & (IData)(vlSelfRef.tb_mini__DOT__host_load_ready));
    }
    if ((7ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_mini___024root___act_comb__TOP__0(vlSelf);
    }
}

void Vtb_mini___024root___timing_commit(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___timing_commit\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (2ULL & vlSelfRef.__VactTriggered[0U]))) {
        vlSelfRef.__VtrigSched_h5e3d8791__0.commit(
                                                   "@(posedge tb_mini.clk)");
    }
}

void Vtb_mini___024root___timing_resume(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___timing_resume\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((2ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h5e3d8791__0.resume(
                                                   "@(posedge tb_mini.clk)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_mini___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_mini___024root___eval_phase__act(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_phase__act\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_mini___024root___eval_triggers__act(vlSelf);
    Vtb_mini___024root___timing_commit(vlSelf);
    Vtb_mini___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_mini___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        Vtb_mini___024root___timing_resume(vlSelf);
        Vtb_mini___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

void Vtb_mini___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_mini___024root___eval_phase__nba(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_phase__nba\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_mini___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_mini___024root___eval_nba(vlSelf);
        Vtb_mini___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_mini___024root___eval(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mini___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("sv/tb_mini.sv", 4, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vtb_mini___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("sv/tb_mini.sv", 4, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vtb_mini___024root___eval_phase__act(vlSelf));
    } while (Vtb_mini___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vtb_mini___024root___eval_debug_assertions(Vtb_mini___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mini___024root___eval_debug_assertions\n"); );
    Vtb_mini__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
