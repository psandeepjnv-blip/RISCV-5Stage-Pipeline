// rtl/forwarding_unit.v
// Forwarding Unit: Detects when data needed by the EX stage is available
// from a later stage in the pipeline, and redirects it there directly,
// bypassing the need to wait for the Register File write-back.

module forwarding_unit (
    input  wire [4:0] rs1_ex,        // Source register 1 needed by EX stage
    input  wire [4:0] rs2_ex,        // Source register 2 needed by EX stage

    input  wire [4:0] rd_mem,        // Destination register sitting in EX/MEM
    input  wire       reg_write_mem, // Is that instruction actually going to write?

    input  wire [4:0] rd_wb,         // Destination register sitting in MEM/WB
    input  wire       reg_write_wb,  // Is that instruction actually going to write?

    output reg  [1:0] forward_a,     // Controls the mux feeding ALU input A
    output reg  [1:0] forward_b      // Controls the mux feeding ALU input B
);

    always @(*) begin
        // Default: no forwarding needed, use the normal Register File value
        forward_a = 2'b00;
        forward_b = 2'b00;

        // --- Forward A (for rs1) ---
        if (reg_write_mem && (rd_mem != 5'b0) && (rd_mem == rs1_ex)) begin
            forward_a = 2'b10; // Forward from EX/MEM (most recent result)
        end else if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs1_ex)) begin
            forward_a = 2'b01; // Forward from MEM/WB
        end

        // --- Forward B (for rs2) ---
        if (reg_write_mem && (rd_mem != 5'b0) && (rd_mem == rs2_ex)) begin
            forward_b = 2'b10;
        end else if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs2_ex)) begin
            forward_b = 2'b01;
        end
    end

endmodule
