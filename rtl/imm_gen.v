// rtl/imm_gen.v
// Immediate Generator: Extracts and sign-extends the constant value embedded in an instruction.

module imm_gen (
    input  wire [31:0] instr,      // Full 32-bit instruction
    output reg  [31:0] imm_out     // Sign-extended 32-bit immediate value
);

    wire [6:0] opcode = instr[6:0];

    // Opcodes we care about right now (from RISC-V RV32I spec)
    localparam OPCODE_I_ALU  = 7'b0010011; // ADDI, ANDI, ORI, etc.
    localparam OPCODE_LOAD   = 7'b0000011; // LW
    localparam OPCODE_STORE  = 7'b0100011; // SW
    localparam OPCODE_BRANCH = 7'b1100011; // BEQ, BNE

    always @(*) begin
        case (opcode)
            OPCODE_I_ALU, OPCODE_LOAD: begin
                // I-type: 12-bit immediate lives in bits [31:20]
                imm_out = {{20{instr[31]}}, instr[31:20]};
            end
            OPCODE_STORE: begin
                // S-type: immediate is split across two fields
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            OPCODE_BRANCH: begin
                // B-type: immediate is split across four fields, and always even (bit 0 = 0)
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            default: imm_out = 32'b0;
        endcase
    end

endmodule
