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

// ---------------------------------------------------------
// ID/EX Register: Sits between Decode and Execute.
// ---------------------------------------------------------
module id_ex_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,      // Used later for hazard handling

    // Control signals coming IN from the Decode stage
    input  wire        reg_write_in,
    input  wire        alu_src_in,
    input  wire        mem_to_reg_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        branch_in,
    input  wire [3:0]  alu_op_in,

    // Data coming IN from the Decode stage
    input  wire [31:0] pc_in,
    input  wire [31:0] rd1_in,
    input  wire [31:0] rd2_in,
    input  wire [31:0] imm_ext_in,
    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,
    input  wire [4:0]  rd_in,

    // Control signals going OUT to the Execute stage
    output reg         reg_write_out,
    output reg         alu_src_out,
    output reg         mem_to_reg_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         branch_out,
    output reg  [3:0]  alu_op_out,

    // Data going OUT to the Execute stage
    output reg  [31:0] pc_out,
    output reg  [31:0] rd1_out,
    output reg  [31:0] rd2_out,
    output reg  [31:0] imm_ext_out,
    output reg  [4:0]  rs1_out,
    output reg  [4:0]  rs2_out,
    output reg  [4:0]  rd_out
);

    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            reg_write_out  <= 1'b0;
            alu_src_out    <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            branch_out     <= 1'b0;
            alu_op_out     <= 4'b0;

            pc_out      <= 32'b0;
            rd1_out     <= 32'b0;
            rd2_out     <= 32'b0;
            imm_ext_out <= 32'b0;
            rs1_out     <= 5'b0;
            rs2_out     <= 5'b0;
            rd_out      <= 5'b0;
        end else begin
            reg_write_out  <= reg_write_in;
            alu_src_out    <= alu_src_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            branch_out     <= branch_in;
            alu_op_out     <= alu_op_in;

            pc_out      <= pc_in;
            rd1_out     <= rd1_in;
            rd2_out     <= rd2_in;
            imm_ext_out <= imm_ext_in;
            rs1_out     <= rs1_in;
            rs2_out     <= rs2_in;
            rd_out      <= rd_in;
        end
    end

endmodule

// ---------------------------------------------------------
// EX/MEM Register: Sits between Execute and Memory Access.
// ---------------------------------------------------------
module ex_mem_reg (
    input  wire        clk,
    input  wire        rst,

    // Control signals coming IN from Execute
    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,

    // Data coming IN from Execute
    input  wire [31:0] alu_result_in,
    input  wire [31:0] rd2_in,        // The value to store, if this is a SW instruction
    input  wire [4:0]  rd_in,

    // Control signals going OUT to Memory stage
    output reg         reg_write_out,
    output reg         mem_to_reg_out,
    output reg         mem_read_out,
    output reg         mem_write_out,

    // Data going OUT to Memory stage
    output reg  [31:0] alu_result_out,
    output reg  [31:0] rd2_out,
    output reg  [4:0]  rd_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;

            alu_result_out <= 32'b0;
            rd2_out        <= 32'b0;
            rd_out         <= 5'b0;
        end else begin
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;

            alu_result_out <= alu_result_in;
            rd2_out        <= rd2_in;
            rd_out         <= rd_in;
        end
    end

endmodule
// ---------------------------------------------------------
// MEM/WB Register: Sits between Memory Access and Write-Back.
// ---------------------------------------------------------
module mem_wb_reg (
    input  wire        clk,
    input  wire        rst,

    // Control signals coming IN from Memory stage
    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,

    // Data coming IN from Memory stage
    input  wire [31:0] mem_data_in,     // Value read from Data Memory (for LW)
    input  wire [31:0] alu_result_in,   // Value computed by ALU (for ADD/ADDI/etc.)
    input  wire [4:0]  rd_in,

    // Control signal going OUT to Write-Back stage
    output reg         reg_write_out,
    output reg         mem_to_reg_out,

    // Data going OUT to Write-Back stage
    output reg  [31:0] mem_data_out,
    output reg  [31:0] alu_result_out,
    output reg  [4:0]  rd_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;

            mem_data_out   <= 32'b0;
            alu_result_out <= 32'b0;
            rd_out         <= 5'b0;
        end else begin
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;

            mem_data_out   <= mem_data_in;
            alu_result_out <= alu_result_in;
            rd_out         <= rd_in;
        end
    end

endmodule


