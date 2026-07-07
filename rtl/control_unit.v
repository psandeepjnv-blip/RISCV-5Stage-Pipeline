// rtl/control_unit.v
// Control Unit: Decodes opcode + funct3 + funct7 to generate control signals.

module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,      // Bits [14:12] of the instruction
    input  wire       funct7_b5,   // Bit [30] of the instruction (distinguishes ADD/SUB)
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg  [3:0] alu_op
);

    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_SLT = 4'b0100;

    localparam OP_R_TYPE = 7'b0110011;
    localparam OP_I_TYPE = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;

    // funct3 values that identify each specific R-type / I-type operation
    localparam F3_ADD_SUB = 3'b000;
    localparam F3_SLT     = 3'b010;
    localparam F3_OR      = 3'b110;
    localparam F3_AND     = 3'b111;

    always @(*) begin
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_to_reg = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        alu_op     = ALU_ADD;

        case (opcode)
            OP_R_TYPE: begin
                reg_write = 1'b1;
                case (funct3)
                    F3_ADD_SUB: alu_op = funct7_b5 ? ALU_SUB : ALU_ADD;
                    F3_SLT:     alu_op = ALU_SLT;
                    F3_OR:      alu_op = ALU_OR;
                    F3_AND:     alu_op = ALU_AND;
                    default:    alu_op = ALU_ADD;
                endcase
            end
            OP_I_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                case (funct3)
                    F3_ADD_SUB: alu_op = ALU_ADD; // ADDI
                    F3_SLT:     alu_op = ALU_SLT; // SLTI
                    F3_OR:      alu_op = ALU_OR;  // ORI
                    F3_AND:     alu_op = ALU_AND; // ANDI
                    default:    alu_op = ALU_ADD;
                endcase
            end
            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                mem_read   = 1'b1;
            end
            OP_STORE: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
            end
            OP_BRANCH: begin
                branch = 1'b1;
                alu_op = ALU_SUB;
            end
            default: ;
        endcase
    end

endmodule
