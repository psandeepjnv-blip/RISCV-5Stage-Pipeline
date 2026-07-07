// rtl/riscv_top.v
// Top-Level Module: The "Motherboard" that connects all components.

module riscv_top (
    input  wire        clk,
    input  wire        rst
);

    // --- Internal Wiring (The "Cables") ---
    wire [31:0] pc_out_w;
    wire [31:0] pc_next_w;
    wire [31:0] instr_w;
    wire [31:0] imm_ext_w;
    wire [31:0] rd1_w, rd2_w;
    wire [31:0] alu_result_w;
    wire [31:0] alu_b_w;
    wire        zero_w;

    // Control Signals
    wire reg_write_w, alu_src_w, mem_to_reg_w, mem_read_w, mem_write_w, branch_w;
    wire [3:0] alu_op_w;

    // --- Logic: PC increment (PC = PC + 4) ---
    assign pc_next_w = pc_out_w + 4;

    // --- 1. PC Module ---
    pc pc_unit (
        .clk(clk),
        .rst(rst),
        .stall(1'b0),          // No stalling in single-cycle
        .pc_next(pc_next_w),
        .pc_out(pc_out_w)
    );

    // --- 2. Instruction Memory ---
    inst_mem imem_unit (
        .addr(pc_out_w),
        .instruction(instr_w)
    );

    // --- 3. Control Unit ---
       control_unit cu_u (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7_b5(instr[30]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op)
    );


    // --- 4. Register File ---
    reg_file rf_unit (
        .clk(clk),
        .rst(rst),
        .we(reg_write_w),
        .rs1(instr_w[19:15]),
        .rs2(instr_w[24:20]),
        .rd(instr_w[11:7]),
        .wd(alu_result_w),     // Writing ALU result back to register
        .rd1(rd1_w),
        .rd2(rd2_w)
    );

    // --- 5. Immediate Generator ---
    imm_gen imm_unit (
        .instr(instr_w),
        .imm_out(imm_ext_w)
    );

    // --- 6. ALU Multiplexer (Switch) ---
    assign alu_b_w = (alu_src_w) ? imm_ext_w : rd2_w;

    // --- 7. ALU ---
    alu alu_unit (
        .a(rd1_w),
        .b(alu_b_w),
        .alu_op(alu_op_w),
        .result(alu_result_w),
        .zero(zero_w)
    );

endmodule
