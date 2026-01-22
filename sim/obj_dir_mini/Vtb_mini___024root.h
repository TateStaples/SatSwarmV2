// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mini.h for the primary calling header

#ifndef VERILATED_VTB_MINI___024ROOT_H_
#define VERILATED_VTB_MINI___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mini__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mini___024root final {
  public:

    // DESIGN SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        CData/*0:0*/ tb_mini__DOT__clk;
        CData/*0:0*/ tb_mini__DOT__rst_n;
        CData/*0:0*/ tb_mini__DOT__host_load_valid;
        CData/*0:0*/ tb_mini__DOT__host_load_clause_end;
        CData/*0:0*/ tb_mini__DOT__host_start;
        CData/*0:0*/ tb_mini__DOT__host_load_ready;
        CData/*0:0*/ tb_mini__DOT__host_done;
        CData/*0:0*/ tb_mini__DOT__host_sat;
        CData/*0:0*/ tb_mini__DOT__host_unsat;
        CData/*1:0*/ tb_mini__DOT__verify_model__Vstatic__state;
        CData/*0:0*/ tb_mini__DOT__verify_model__Vstatic__clause_sat;
        CData/*3:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__state_q;
        CData/*3:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__state_d;
        CData/*7:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__idx_curr;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_enable;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_valid;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__all_assigned;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_empty;
        CData/*3:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_q;
        CData/*3:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__state_d;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_q;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__initialized_d;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_q;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_list_sel_d;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_q;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__conflict_detected_d;
        CData/*0:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__load_fire;
        CData/*1:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__Vfuncout;
        CData/*1:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__Vfuncout;
        CData/*1:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__Vfuncout;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start__0;
        CData/*0:0*/ __VstlDidInit;
        CData/*0:0*/ __VstlFirstIteration;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mini__DOT__dut__DOT__u_solver__DOT__pse_start__1;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mini__DOT__clk__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mini__DOT__rst_n__0;
        CData/*0:0*/ __VactDidInit;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__decision_level_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_undo_to_height;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_wr_ptr;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_rd_ptr;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_height_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_count_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_count_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_clause_len_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_clause_idx_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__reset_idx_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_clause_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_q;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__scan_prev_d;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w1_addr;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_w2_addr;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx1;
        SData/*15:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__init_idx2;
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__Vfuncout;
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__4__raw_idx;
    };
    struct {
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__Vfuncout;
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__5__raw_idx;
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__Vfuncout;
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__raw_idx;
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__Vfuncout;
        SData/*15:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__raw_idx;
        IData/*31:0*/ tb_mini__DOT__host_load_literal;
        IData/*31:0*/ tb_mini__DOT__DEBUG;
        IData/*31:0*/ tb_mini__DOT__passed_tests;
        IData/*31:0*/ tb_mini__DOT__failed_tests;
        IData/*31:0*/ tb_mini__DOT__load_cnf_file__Vstatic__lit;
        IData/*31:0*/ tb_mini__DOT__load_cnf_file__Vstatic__scan_result;
        IData/*31:0*/ tb_mini__DOT__load_cnf_file__Vstatic__num_vars;
        IData/*31:0*/ tb_mini__DOT__load_cnf_file__Vstatic__num_clauses;
        IData/*31:0*/ tb_mini__DOT__load_cnf_file__Vstatic__unnamedblk1__DOT__pos;
        IData/*31:0*/ tb_mini__DOT__verify_model__Vstatic__unsat_clauses;
        IData/*31:0*/ tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__lit;
        IData/*31:0*/ tb_mini__DOT__verify_model__Vstatic__unnamedblk3__DOT__unnamedblk4__DOT__unnamedblk5__DOT__var_idx;
        VlWide<8>/*255:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__decision_tried_pos;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_decision_var;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__pse_propagated_var;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__next_var;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_q;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__conflict_count_d;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_q;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__decision_count_d;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__unnamedblk2__DOT__i;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_q;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__max_var_seen_d;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_q;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__cur_prop_lit_d;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__registered_decision_q;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__seed_v;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_v;
        IData/*31:0*/ tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__undo_var_idx;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__lit;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__6__v;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__lit;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__7__v;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__lit;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__8__v;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__lit;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_truth__9__v;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__lit;
        IData/*31:0*/ __Vfunc_tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__safe_lit_idx__10__v;
        IData/*31:0*/ __VactIterCount;
        QData/*63:0*/ tb_mini__DOT__max_cycles;
        VlUnpacked<IData/*31:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack;
        VlUnpacked<SData/*15:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim;
        VlUnpacked<CData/*1:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__assign_state;
        VlUnpacked<SData/*15:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_len;
        VlUnpacked<SData/*15:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__clause_start;
        VlUnpacked<IData/*31:0*/, 2048> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__lit_mem;
        VlUnpacked<SData/*15:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit1;
        VlUnpacked<SData/*15:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watched_lit2;
        VlUnpacked<SData/*15:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next1;
        VlUnpacked<SData/*15:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_next2;
        VlUnpacked<SData/*15:0*/, 512> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head1;
        VlUnpacked<SData/*15:0*/, 512> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__watch_head2;
        VlUnpacked<IData/*31:0*/, 2048> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__prop_queue;
        VlUnpacked<IData/*31:0*/, 256> tb_mini__DOT__dut__DOT__u_solver__DOT__u_pse__DOT__trail_mem;
        VlUnpacked<QData/*63:0*/, 2> __VstlTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    };
    VlNBACommitQueue<VlUnpacked<IData/*31:0*/, 256>, false, IData/*31:0*/, 1> __VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__decision_var_stack;
    VlNBACommitQueue<VlUnpacked<SData/*15:0*/, 256>, false, SData/*15:0*/, 1> __VdlyCommitQueuetb_mini__DOT__dut__DOT__u_solver__DOT__trail_lim;
    VlQueue<VlQueue<IData/*31:0*/>> tb_mini__DOT__clause_store;
    VlQueue<IData/*31:0*/> tb_mini__DOT__load_cnf_file__Vstatic__literals;
    VlQueue<IData/*31:0*/> tb_mini__DOT__load_cnf_file__Vstatic__clause_copy;
    std::string tb_mini__DOT__cnf_file;
    std::string tb_mini__DOT__expect_str;
    std::string tb_mini__DOT__load_cnf_file__Vstatic__line;
    double tb_mini__DOT__run_test__Vstatic__unnamedblk7__DOT__time_ms;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h5e3d8791__0;

    // INTERNAL VARIABLES
    Vtb_mini__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mini___024root(Vtb_mini__Syms* symsp, const char* namep);
    ~Vtb_mini___024root();
    VL_UNCOPYABLE(Vtb_mini___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
