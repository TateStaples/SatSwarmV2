// satswarm_host.c — AWS F1 Host Application for SatSwarm SAT Solver
//
// Loads a DIMACS CNF file, uploads it to the FPGA via DMA,
// triggers the solver, and reads back the result.
//
// Usage: ./satswarm_host <cnf_file> [--slot N] [--timeout SECONDS]
//
// Requires: AWS FPGA SDK (libfpga_mgmt)
// Build:    make -C host/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <time.h>
#include <unistd.h>
#include <errno.h>

#include <fpga_pci.h>
#include <fpga_mgmt.h>
#include <fpga_dma.h>
#include <utils/lcd.h>

// =============================================================================
// SatSwarm Register Map (AXI-Lite OCL BAR)
// =============================================================================
#define REG_STATUS       0x00   // R: {29'b0, unsat, sat, done}  W: bit[0]=start
#define REG_CYCLES       0x04   // R: cycle_counter[31:0]
#define REG_VERSION      0x08   // R: 0x53415431 ("SAT1")
#define REG_SOFT_RESET   0x0C   // W: bit[0]=1 to reset
#define REG_DEBUG        0x10   // RW: debug_level

// DMA addresses for literal loading
#define DMA_LITERAL      0x1000 // Write literal, clause_end=0
#define DMA_CLAUSE_END   0x1004 // Write literal, clause_end=1

// Status register bits
#define STATUS_DONE   (1 << 0)
#define STATUS_SAT    (1 << 1)
#define STATUS_UNSAT  (1 << 2)

// Expected version
#define SATSWARM_VERSION 0x53415431

// =============================================================================
// Global state
// =============================================================================
static int slot_id = 0;
static pci_bar_handle_t ocl_bar_handle = PCI_BAR_HANDLE_INIT;
static int dma_write_fd = -1;

// =============================================================================
// Literal buffer for CNF loading
// =============================================================================
#define MAX_LITERALS  (1024 * 1024)

typedef struct {
    int32_t literal;
    bool    clause_end;
} literal_entry_t;

static literal_entry_t lit_buffer[MAX_LITERALS];
static int lit_count = 0;

// =============================================================================
// FPGA Init / Cleanup
// =============================================================================
static int fpga_init(void) {
    int rc;

    rc = fpga_mgmt_init();
    if (rc) {
        fprintf(stderr, "ERROR: fpga_mgmt_init failed: %d\n", rc);
        return rc;
    }

    // Check FPGA status
    struct fpga_mgmt_image_info info;
    rc = fpga_mgmt_describe_local_image(slot_id, &info, 0);
    if (rc) {
        fprintf(stderr, "ERROR: fpga_mgmt_describe_local_image failed: %d\n", rc);
        return rc;
    }

    if (info.status != FPGA_STATUS_LOADED) {
        fprintf(stderr, "ERROR: AFI not loaded on slot %d (status=%d)\n",
                slot_id, info.status);
        fprintf(stderr, "Load an AFI first: fpga-load-local-image -S %d -I <afi-id>\n",
                slot_id);
        return -1;
    }

    printf("FPGA slot %d: AFI loaded (status=%s)\n",
           slot_id, info.status == FPGA_STATUS_LOADED ? "LOADED" : "?");

    // Attach OCL BAR (BAR0)
    rc = fpga_pci_attach(slot_id, FPGA_APP_PF, APP_PF_BAR0, 0, &ocl_bar_handle);
    if (rc) {
        fprintf(stderr, "ERROR: fpga_pci_attach OCL BAR failed: %d\n", rc);
        return rc;
    }

    // Poll version register until it responds correctly (MMCM lock / reset deassertion)
    uint32_t version = 0;
    printf("Waiting for FPGA core to come out of reset...\n");
    for (int i = 0; i < 50; i++) {
        rc = fpga_pci_peek(ocl_bar_handle, REG_VERSION, &version);
        if (rc) {
            fprintf(stderr, "ERROR: Failed to read version register: %d\n", rc);
            return rc;
        }
        if (version == SATSWARM_VERSION) break;
        printf("  [%d] version=0x%08X, retrying...\n", i, version);
        usleep(100000); // 100ms
    }

    if (version != SATSWARM_VERSION) {
        fprintf(stderr, "ERROR: Core never came out of reset after 5s. version=0x%08X\n", version);
        fprintf(stderr, "       AXI-Lite interface may be broken or wrong BAR.\n");
        return -1;
    }
    printf("SatSwarm version: 0x%08X (OK)\n", version);

    // Open DMA write channel
    dma_write_fd = fpga_dma_open_queue(FPGA_DMA_XDMA, slot_id, 0, true);
    if (dma_write_fd < 0) {
        fprintf(stderr, "WARNING: DMA open failed (%d), will use MMIO for loading\n",
                dma_write_fd);
        // Fall back to MMIO writes via OCL BAR
    }

    return 0;
}

static void fpga_cleanup(void) {
    if (dma_write_fd >= 0)
        close(dma_write_fd);
    if (ocl_bar_handle != PCI_BAR_HANDLE_INIT)
        fpga_pci_detach(ocl_bar_handle);
    fpga_mgmt_close();
}

// =============================================================================
// CNF Parser (DIMACS format)
// =============================================================================
static int parse_cnf(const char *filename) {
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        fprintf(stderr, "ERROR: Cannot open %s: %s\n", filename, strerror(errno));
        return -1;
    }

    char line[4096];
    int num_vars = 0, num_clauses = 0;
    int clause_count = 0;
    lit_count = 0;

    while (fgets(line, sizeof(line), fp)) {
        // Skip comments
        if (line[0] == 'c') continue;

        // Problem line
        if (line[0] == 'p') {
            sscanf(line, "p cnf %d %d", &num_vars, &num_clauses);
            printf("Problem: %d variables, %d clauses\n", num_vars, num_clauses);
            continue;
        }

        // Parse literals in clause
        char *ptr = line;
        while (*ptr) {
            // Skip whitespace
            while (*ptr == ' ' || *ptr == '\t' || *ptr == '\n' || *ptr == '\r')
                ptr++;
            if (*ptr == '\0') break;

            int lit = (int)strtol(ptr, &ptr, 10);

            if (lit == 0) {
                // End of clause: mark the last literal as clause_end
                if (lit_count > 0) {
                    lit_buffer[lit_count - 1].clause_end = true;
                    clause_count++;
                }
            } else {
                if (lit_count >= MAX_LITERALS) {
                    fprintf(stderr, "ERROR: Too many literals (max %d)\n", MAX_LITERALS);
                    fclose(fp);
                    return -1;
                }
                lit_buffer[lit_count].literal = lit;
                lit_buffer[lit_count].clause_end = false;
                lit_count++;
            }
        }
    }

    fclose(fp);
    printf("Parsed: %d literals in %d clauses\n", lit_count, clause_count);
    return 0;
}

// =============================================================================
// Upload CNF via PCIS DMA / MMIO
// =============================================================================
static int upload_cnf(void) {
    int rc;
    printf("Uploading %d literals...\n", lit_count);

    // Soft reset first
    rc = fpga_pci_poke(ocl_bar_handle, REG_SOFT_RESET, 1);
    if (rc) {
        fprintf(stderr, "ERROR: Soft reset failed: %d\n", rc);
        return rc;
    }
    usleep(1000); // Wait for reset

    // Upload literals one at a time via MMIO (simple, works everywhere)
    // For high performance, use DMA with batched writes
    for (int i = 0; i < lit_count; i++) {
        uint32_t addr = lit_buffer[i].clause_end ? DMA_CLAUSE_END : DMA_LITERAL;
        uint32_t data = (uint32_t)lit_buffer[i].literal;

        if (dma_write_fd >= 0) {
            // DMA write (faster for large CNFs)
            rc = fpga_dma_burst_write(dma_write_fd, (uint8_t *)&data, 4, addr);
        } else {
            // MMIO fallback via OCL BAR (PCIS address space mapped to BAR4)
            rc = fpga_pci_poke(ocl_bar_handle, addr, data);
        }

        if (rc) {
            fprintf(stderr, "ERROR: Write literal %d failed: %d\n", i, rc);
            return rc;
        }
    }

    printf("Upload complete.\n");
    return 0;
}

// =============================================================================
// Start Solve and Poll for Result
// =============================================================================
static int run_solve(int timeout_sec, uint32_t *status_out, uint32_t *cycles_out) {
    int rc;

    // Start solve
    rc = fpga_pci_poke(ocl_bar_handle, REG_STATUS, 1);
    if (rc) {
        fprintf(stderr, "ERROR: Start solve failed: %d\n", rc);
        return rc;
    }

    printf("Solve started, polling (timeout=%ds)...\n", timeout_sec);

    struct timespec start, now;
    clock_gettime(CLOCK_MONOTONIC, &start);

    while (1) {
        rc = fpga_pci_peek(ocl_bar_handle, REG_STATUS, status_out);
        if (rc) {
            fprintf(stderr, "ERROR: Status read failed: %d\n", rc);
            return rc;
        }

        if (*status_out & STATUS_DONE)
            break;

        clock_gettime(CLOCK_MONOTONIC, &now);
        double elapsed = (now.tv_sec - start.tv_sec) +
                         (now.tv_nsec - start.tv_nsec) / 1e9;
        if (elapsed >= timeout_sec) {
            fprintf(stderr, "TIMEOUT after %.1fs\n", elapsed);
            *status_out = 0;
            return -1;
        }

        usleep(100); // 100us poll interval
    }

    // Read cycle count
    rc = fpga_pci_peek(ocl_bar_handle, REG_CYCLES, cycles_out);
    if (rc) {
        fprintf(stderr, "WARNING: Failed to read cycle counter: %d\n", rc);
        *cycles_out = 0;
    }

    return 0;
}

// =============================================================================
// Main
// =============================================================================
static void usage(const char *prog) {
    printf("SatSwarm AWS F1 Host Application\n\n");
    printf("Usage: %s <cnf_file> [options]\n\n", prog);
    printf("Options:\n");
    printf("  --slot N       FPGA slot (default: 0)\n");
    printf("  --timeout N    Solve timeout in seconds (default: 60)\n");
    printf("  --debug N      Debug level (default: 0)\n");
    printf("  --help         Show this help\n");
}

int main(int argc, char *argv[]) {
    const char *cnf_file = NULL;
    int timeout_sec = 15;
    int debug_level = 0;
    int rc;

    // Parse arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--slot") == 0 && i + 1 < argc) {
            slot_id = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--timeout") == 0 && i + 1 < argc) {
            timeout_sec = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--debug") == 0 && i + 1 < argc) {
            debug_level = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            usage(argv[0]);
            return 0;
        } else if (argv[i][0] != '-') {
            cnf_file = argv[i];
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            usage(argv[0]);
            return 1;
        }
    }

    if (!cnf_file) {
        fprintf(stderr, "ERROR: No CNF file specified\n\n");
        usage(argv[0]);
        return 1;
    }

    printf("===========================================\n");
    printf(" SatSwarm AWS F1 SAT Solver\n");
    printf("===========================================\n");
    printf("CNF File:  %s\n", cnf_file);
    printf("Slot:      %d\n", slot_id);
    printf("Timeout:   %ds\n", timeout_sec);
    printf("Debug:     %d\n", debug_level);
    printf("\n");

    // Initialize FPGA
    rc = fpga_init();
    if (rc) {
        fpga_cleanup();
        return 1;
    }

    // Set debug level
    if (debug_level > 0) {
        fpga_pci_poke(ocl_bar_handle, REG_DEBUG, debug_level);
    }

    // Parse CNF file
    rc = parse_cnf(cnf_file);
    if (rc) {
        fpga_cleanup();
        return 1;
    }

    // Upload to FPGA
    rc = upload_cnf();
    if (rc) {
        fpga_cleanup();
        return 1;
    }

    // Run solve
    uint32_t status, cycles;
    rc = run_solve(timeout_sec, &status, &cycles);

    printf("\n===========================================\n");
    if (rc == 0) {
        bool is_sat   = (status & STATUS_SAT) != 0;
        bool is_unsat = (status & STATUS_UNSAT) != 0;
        printf("Result:    %s\n", is_sat ? "SAT" : (is_unsat ? "UNSAT" : "UNKNOWN"));
        printf("Cycles:    %u\n", cycles);
        printf("Status:    0x%08X\n", status);
    } else {
        printf("Result:    TIMEOUT\n");
    }
    printf("===========================================\n");

    fpga_cleanup();
    return (rc == 0) ? 0 : 1;
}
