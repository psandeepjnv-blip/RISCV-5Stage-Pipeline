// rtl/riscv_top.v
// 5-Stage Pipelined RISC-V Processor Top-Level

module riscv_top (
    input  wire        clk,
    input  wire        rst
);

    // -------------------------------------------------------------------------
    // 1. IF Stage (Instruction Fetch)
    // -------------------------------------------------------------------------
    wire [31:0] pc_out_if, pc_next_if, instr_if;

    assign pc_next_if = pc_out_if + 4;

    pc pc_u (
        .clk(clk), .rst(rst), .stall(1'b0), 
        .pc_next(pc_next_if), .pc_out(pc_out_if)
    );

    inst_mem imem_u (
        .addr(pc_out_if), .instruction(instr_if)
    );

    // --- IF/ID Pipeline Register ---
    wire [31:0] pc_id, instr_id;
    if_id_reg if_id_u (
        .clk(clk), .rst(rst), .stall(1'b0), .flush(1'b0),
        .pc_in(pc_out_if), .instr_in(instr_if),
        .pc_out(pc_id), .instr_out(instr_id)
    );

    // -------------------------------------------------------------------------
    // 2. ID Stage (Instruction Decode)
    // -------------------------------------------------------------------------
    wire [31:0] rd1_id, rd2_id, imm_id;
    wire reg_write_id, alu_src_id, mem_to_reg_id, mem_read_id, mem_write_id, branch_id;
    wire [3:0] alu_op_id;
    
    // WB Stage signals needed for Register File write-back
    wire [31:0] wd_wb;
    wire [4:0]  rd_wb;
    wire        reg_write_wb;

    control_unit cu_u (
        .opcode(instr_id[6:0]), .funct3(instr_id[14:12]), .funct7_b5(instr_id[30]),
        .reg_write(reg_write_id), .alu_src(alu_src_id), .mem_to_reg(mem_to_reg_id),
        .mem_read(mem_read_id), .mem_write(mem_write_id), .branch(branch_id), .alu_op(alu_op_id)
    );

    reg_file rf_u (
        .clk(clk), .rst(rst), .we(reg_write_wb), // Writes happen from WB stage
        .rs1(instr_id[19:15]), .rs2(instr_id[24:20]), .rd(rd_wb),
        .wd(wd_wb), .rd1(rd1_id), .rd2(rd2_id)
    );

    imm_gen imm_u (
        .instr(instr_id), .imm_out(imm_id)
    );

    // --- ID/EX Pipeline Register ---
    wire [31:0] pc_ex, rd1_ex, rd2_ex, imm_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire [3:0]  alu_op_ex;
    wire reg_write_ex, alu_src_ex, mem_to_reg_ex, mem_read_ex, mem_write_ex, branch_ex;

    id_ex_reg id_ex_u (
        .clk(clk), .rst(rst), .flush(1'b0),
        .reg_write_in(reg_write_id), .alu_src_in(alu_src_id), .mem_to_reg_in(mem_to_reg_id),
        .mem_read_in(mem_read_id), .mem_write_in(mem_write_id), .branch_in(branch_id), .alu_op_in(alu_op_id),
        .pc_in(pc_id), .rd1_in(rd1_id), .rd2_in(rd2_id), .imm_ext_in(imm_id),
        .rs1_in(instr_id[19:15]), .rs2_in(instr_id[24:20]), .rd_in(instr_id[11:7]),
        .reg_write_out(reg_write_ex), .alu_src_out(alu_src_ex), .mem_to_reg_out(mem_to_reg_ex),
        .mem_read_out(mem_read_ex), .mem_write_out(mem_write_ex), .branch_out(branch_ex), .alu_op_out(alu_op_ex),
        .pc_out(pc_ex), .rd1_out(rd1_ex), .rd2_out(rd2_ex), .imm_ext_out(imm_ex),
        .rs1_out(rs1_ex), .rs2_out(rs2_ex), .rd_out(rd_ex)
    );

    // -------------------------------------------------------------------------
    // 3. EX Stage (Execute)
    // -------------------------------------------------------------------------
    wire [31:0] alu_result_ex, alu_b_ex;
    wire zero_ex;

    assign alu_b_ex = (alu_src_ex) ? imm_ex : rd2_ex;

    alu alu_u (
        .a(rd1_ex), .b(alu_b_ex), .alu_op(alu_op_ex),
        .result(alu_result_ex), .zero(zero_ex)
    );

    // --- EX/MEM Pipeline Register ---
    wire [31:0] alu_result_mem, rd2_mem;
    wire [4:0]  rd_mem;
    wire reg_write_mem, mem_to_reg_mem, mem_read_mem, mem_write_mem;

    ex_mem_reg ex_mem_u (
        .clk(clk), .rst(rst),
        .reg_write_in(reg_write_ex), .mem_to_reg_in(mem_to_reg_ex), .mem_read_in(mem_read_ex), .mem_write_in(mem_write_ex),
        .alu_result_in(alu_result_ex), .rd2_in(rd2_ex), .rd_in(rd_ex),
        .reg_write_out(reg_write_mem), .mem_to_reg_out(mem_to_reg_mem), .mem_read_out(mem_read_mem), .mem_write_out(mem_write_mem),
        .alu_result_out(alu_result_mem), .rd2_out(rd2_mem), .rd_out(rd_mem)
    );

    // -------------------------------------------------------------------------
    // 4. MEM Stage (Memory Access)
    // -------------------------------------------------------------------------
    wire [31:0] mem_data_mem;

    data_mem dmem_u (
        .clk(clk), .addr(alu_result_mem), .write_data(rd2_mem),
        .mem_read(mem_read_mem), .mem_write(mem_write_mem), .read_data(mem_data_mem)
    );

    // --- MEM/WB Pipeline Register ---
    wire [31:0] alu_result_wb, mem_data_wb;
    wire mem_to_reg_wb;

    mem_wb_reg mem_wb_u (
        .clk(clk), .rst(rst),
        .reg_write_in(reg_write_mem), .mem_to_reg_in(mem_to_reg_mem),
        .mem_data_in(mem_data_mem), .alu_result_in(alu_result_mem), .rd_in(rd_mem),
        .reg_write_out(reg_write_wb), .mem_to_reg_out(mem_to_reg_wb),
        .mem_data_out(mem_data_wb), .alu_result_out(alu_result_wb), .rd_out(rd_wb)
    );

    // -------------------------------------------------------------------------
    // 5. WB Stage (Write-Back)
    // -------------------------------------------------------------------------
    assign wd_wb = (mem_to_reg_wb) ? mem_data_wb : alu_result_wb;

endmodule
