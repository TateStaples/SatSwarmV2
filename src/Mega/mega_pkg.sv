package mega_pkg;

    // VDE Heap Entry
    typedef struct packed {
        logic [31:0] score; // Was ACT_W=32 in vde_heap
        logic [31:0] var_id; 
    } heap_entry_t;

    // Trail Entry
    typedef struct packed {
        logic [31:0] variable;
        logic        value;
        logic [15:0] level;
        logic        is_decision;
        logic [15:0] reason;
    } trail_entry_t;

endpackage
