// rtl/pipeline_regs.v
// This file holds all the pipeline registers that sit between the 5 stages.

// ---------------------------------------------------------
// IF/ID Register: Sits between Fetch and Decode.
// ---------------------------------------------------------
module if_id_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,      // Freeze this register (hold its old values)
    input  wire        flush,      // Clear this register (insert a bubble/NOP)

    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,

    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out    <= 32'b0;
            instr_out <= 32'b0;
        end else if (flush) begin
            pc_out    <= 32'b0;
            instr_out <= 32'h00000013;   // Real NOP: ADDI x0, x0, 0
   // NOP encoding is also all zeros in our design... 
                                   // actually let's be precise, see explanation below
        end else if (!stall) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
        // if stall is high (and not flush/rst), hold current values - do nothing
    end

endmodule
