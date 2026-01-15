// Package: common parameters and types for SatSwarmv2
package satswarmv2_pkg;
  parameter int VAR_MAX        = 16384;
  parameter int LIT_MAX        = 1048576;
  parameter int CLAUSE_MAX     = 262144; // adjustable; clause table entries
  parameter int CURSOR_COUNT   = 4;
  parameter int DECLEVEL_W     = 15; // supports up to VAR_MAX levels
  parameter int LBD_W          = 8;
  parameter int PTR_W          = 32;
  parameter int ACT_W          = 32;
  parameter int HEAP_W         = 16;
  parameter real DECAY_FACTOR  = 0.95; // VSIDS activity decay

  // Swarm architecture parameters
  parameter int GRID_X         = 2;    // 2x2 grid default
  parameter int GRID_Y         = 2;
  parameter int CORE_ID_W      = 4;    // max 16 cores per grid
  parameter int VC_BITS        = 2;    // 4 virtual channels for deadlock avoidance

  // NoC packet types
  typedef enum logic [1:0] {
    MSG_DIVERGE,   // Force neighbor to assume payload_lit
    MSG_CLAUSE,    // Broadcast global pointer to learned clause
    MSG_STATUS     // Report idle/busy/sat/unsat state
  } msg_type_t;

  // NoC communication packet
  typedef struct packed {
    msg_type_t      msg_type;
    logic [63:0]    payload;           // Divergence literal (bottom 32) OR Two Clause Literals
    logic [LBD_W-1:0] quality_metric;  // LBD for clauses
    logic [CORE_ID_W-1:0] src_id;      // Originating core ID
    logic [VC_BITS-1:0] virtual_channel; // Deadlock avoidance
  } noc_packet_t;

  // Single-core variable metadata (local per core)
  typedef struct packed {
    logic assigned;         // Variable is assigned
    logic value;            // Current assignment (0=false, 1=true)
    logic [DECLEVEL_W-1:0] level;    // Decision level when assigned
    logic [PTR_W-1:0] reason;        // Clause ID that implied this (0 if decision)
    logic [ACT_W-1:0] activity;      // VSIDS activity score
    logic phase;            // Phase saving hint
    logic assumption;       // True if forced by neighbor divergence
  } var_metadata_t;

  // Clause metadata (hybrid: header is local, literals in global DDR)
  typedef struct packed {
    logic [PTR_W-1:0] global_ptr;   // Pointer to literal array in Global DDR4
    logic [15:0] length;            // Clause length
    logic signed [31:0] wlit0;      // Cached watched literals (local copy)
    logic signed [31:0] wlit1;
    logic [LBD_W-1:0] lbd;          // Literal Block Distance
    logic learnable;                // Deletion candidate
    logic [PTR_W-1:0] next_watch0;  // Watch list link for wlit0 (local BRAM ptr)
    logic [PTR_W-1:0] next_watch1;  // Watch list link for wlit1 (local BRAM ptr)
  } clause_metadata_t;

  // Trail entry with divergence flag
  typedef struct packed {
    logic signed [31:0] literal;    // Assigned literal
    logic [DECLEVEL_W-1:0] level;   // Decision level
    logic is_forced;                // Flag if forced by neighbor divergence
  } trail_entry_t;

  typedef struct packed {
    logic             valid;
    logic signed [31:0] lit;
    logic [PTR_W-1:0] clause_ptr;
  } propagation_t;

  typedef struct packed {
    logic             conflict;
    logic [PTR_W-1:0] clause_ptr;
  } conflict_t;

  typedef struct packed {
    logic [PTR_W-1:0] ptr;
    logic [15:0]      len;
  } clause_ref_t;

endpackage
