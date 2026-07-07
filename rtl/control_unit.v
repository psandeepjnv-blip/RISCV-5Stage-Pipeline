// rtl/control_unit.v
// Control Unit: Decodes the opcode and generates control signals for the datapath.

module control_unit (
    input  wire [6:0] opcode,     // 7-bit opcode from the instruction
    output reg        reg_write,  // High if we need to write to the Register File
    output reg        alu_src,    // 0: use rs2, 1: use immediate value
    output reg        mem_to_reg, // 1: write memory data to reg, 0: write ALU result to reg
    output reg        mem_read,   // High for Load instructions
    output reg        mem_write,  // High for Store instructions
    output reg        branch,     // High for Branch instructions
    output reg  [3:0] alu_op      // Tells the ALU which operation to perform
);

    // Internal ALU operation codes (must match alu.v localparams)
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_SLT  = 4'b0100;

    // RISC-V Standard Opcodes
    localparam OP_R_TYPE = 7'b0110011;
    localparam OP_I_TYPE = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;

    always @(*) begin
        // Default values (Safety first: turn everything off)
        reg_write = 1'b0;
        alu_src   = 1'b0;
        mem_to_reg= 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        branch    = 1'b0;
        alu_op    = ALU_ADD;

        case (opcode)
            OP_R_TYPE: begin
                reg_write = 1'b1; // R-type always writes to a register
                alu_op    = ALU_ADD; // Simplified: assuming ADD for now
            end
            OP_I_TYPE: begin
                reg_write = 1'b1; // I-type (like ADDI) writes to a register
                alu_src   = 1'b1; // Use the immediate value, not register rs2
                alu_op    = ALU_ADD;
            end
            OP_LOAD: begin
                reg_write = 1'b1;
                alu_src   = 1'b1; // Address = rs1 + immediate
                mem_to_reg= 1'b1; // We want the data from memory
                mem_read  = 1'b1;
            end
            OP_STORE: begin
                alu_src   = 1'b1; // Address = rs1 + immediate
                mem_write = 1'b1; // Write to memory
            end
            OP_BRANCH: begin
                branch    = 1'b1;
                alu_op    = ALU_SUB; // Branches use subtraction to compare values
            end
            default: ; // Do nothing, use defaults
        endcase
    end

endmodule
