// rtl/alu.v
// Arithmetic Logic Unit: Performs the actual computation for R-type and I-type instructions.

module alu (
    input  wire [31:0] a,          // First operand
    input  wire [31:0] b,          // Second operand
    input  wire [3:0]  alu_op,     // Operation selector
    output reg  [31:0] result,     // Computation result
    output wire        zero        // High if result == 0 (used for branches)
);

    // Operation codes - these are our own internal encoding, not RISC-V's.
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_SLT  = 4'b0100;

    always @(*) begin
        case (alu_op)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_SLT: result = (a[31] == b[31]) ? {31'b0, (a < b)} :
                               (a[31] == 1'b1)  ? 32'b1 : 32'b0;
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
