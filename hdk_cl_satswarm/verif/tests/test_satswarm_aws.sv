// test_satswarm_aws.sv - AWS Shell BFM test for cl_satswarm
`timescale 1ns/1ps

module test_satswarm_aws();

import tb_type_defines_pkg::*;

logic [31:0] rdata;
parameter [5:0] AXI_ID = 6'h0;

initial begin
    $display("[%0t] Starting test_satswarm_aws", $time);

    // Power up the simulated AWS shell (this releases PCIe reset, etc)
    tb.power_up();

    // The CL is attached to AppPF BAR0 (OCL interface). Base address for SatSwarm is 0.
    // Let's read the Version Register at offset 0x08
    $display("[%0t] Reading Version Register (Offset 0x08)", $time);
    tb.peek_ocl(.addr(32'h08), .data(rdata), .id(AXI_ID));

    if (rdata === 32'h53415431) begin // "SAT1"
        $display("[%0t] SUCCESS: Version = 0x%08X", $time, rdata);
    end else begin
        $display("[%0t] FAIL: Expected 0x53415431, got 0x%08X", $time, rdata);
        $finish;
    end

    // Let's write a small CNF directly using DMA PCIS (BAR4)
    // The SatSwarm expects writes to offset 0x1000 for normal literals
    // and 0x1004 for the last literal in a clause.
    //
    // AXI4 byte-lane steering: a 32-bit write to byte address A places data in
    // wdata[32*(A[5:2]) +: 32].  A write to 0x1000 (offset 0) → [31:0].
    // A write to 0x1004 (offset 4) → [63:32].  The BFM must match this so
    // that simulation exercises the same extraction path as real hardware.

    $display("[%0t] Streaming CNF clauses via PCIS DMA", $time);
    // Clause 1: {1, 2}
    tb.poke_pcis(.slot_id(0), .addr(64'h1000), .data({480'h0, 32'd1}),        .id(AXI_ID), .strb(64'hFFFF_FFFF_FFFF_FFFF));
    tb.poke_pcis(.slot_id(0), .addr(64'h1004), .data({448'h0, 32'd2, 32'h0}), .id(AXI_ID), .strb(64'hFFFF_FFFF_FFFF_FFFF));

    // Clause 2: {-1, 2}
    tb.poke_pcis(.slot_id(0), .addr(64'h1000), .data({480'h0, -32'sd1}),      .id(AXI_ID), .strb(64'hFFFF_FFFF_FFFF_FFFF));
    tb.poke_pcis(.slot_id(0), .addr(64'h1004), .data({448'h0, 32'd2, 32'h0}), .id(AXI_ID), .strb(64'hFFFF_FFFF_FFFF_FFFF));

    // Start solver (Write 1 to Control Register at Offset 0x00)
    $display("[%0t] Starting Solver...", $time);
    tb.poke_ocl(.addr(32'h00), .data(32'h0000_0001), .id(AXI_ID));

    // Poll status register until done
    begin
        int timeout;
        bit done;
        timeout = 1000;
        done = 0;
        while (!done && timeout > 0) begin
            tb.nsec_delay(100);
            tb.peek_ocl(.addr(32'h00), .data(rdata), .id(AXI_ID));
            if (rdata & 32'h1) begin
                done = 1;
            end
            timeout--;
        end

        if (!done) begin
            $display("[%0t] FAIL: Solver timeout", $time);
            $finish;
        end
    end

    // Check результат
    $display("[%0t] Solver finished. Status = 0x%08X", $time, rdata);
    if ((rdata & 32'h3) == 32'h3) begin // bit 0=done, bit 1=SAT
        $display("[%0t] *** TEST PASSED ***", $time);
    end else begin
        $display("[%0t] *** TEST FAILED ***", $time);
    end

    // Power down
    tb.power_down();
    $finish;
end

endmodule
