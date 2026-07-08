// rtl/inst_mem.v
// Instruction Memory: Holds the test program as pre-loaded 32-bit instructions.

module inst_mem (
    input  wire [31:0] addr,          // Byte address (from PC)
    output wire [31:0] instruction    // Instruction stored at that address
);

    reg [31:0] memory [0:63];
    integer m;

    initial begin
        for (m = 0; m < 64; m = m + 1) begin
            memory[m] = 32'h00000013; // NOP (ADDI x0, x0, 0)
        end

        memory[0] = 32'h00500093; // ADDI x1, x0, 5
        memory[1] = 32'h00500113; // ADDI x2, x0, 5
        memory[2] = 32'h00208463; // BEQ  x1, x2, 8   -> should be taken
        memory[3] = 32'h06300193; // ADDI x3, x0, 99  -> should be SKIPPED
        memory[4] = 32'h02a00213; // ADDI x4, x0, 42  -> branch target
    end

    assign instruction = memory[addr[31:2]];

endmodule
