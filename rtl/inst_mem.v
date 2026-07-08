// rtl/inst_mem.v
// Instruction Memory: Holds the test program as pre-loaded 32-bit instructions.

module inst_mem (
    input  wire [31:0] addr,          // Byte address (from PC)
    output wire [31:0] instruction    // Instruction stored at that address
);

    reg [31:0] memory [0:63];
    integer m;

    initial begin
        // Fill everything with NOP first, so unused slots are safe
        for (m = 0; m < 64; m = m + 1) begin
            memory[m] = 32'h00000013; // NOP (ADDI x0, x0, 0)
        end

        memory[0] = 32'h00500093; // ADDI x1, x0, 5
        memory[1] = 32'h00000113; // ADDI x2, x0, 0
        memory[2] = 32'h00112023; // SW   x1, 0(x2)
        memory[3] = 32'h00212183; // LW   x3, 0(x2)
        memory[4] = 32'h00318233; // ADD  x4, x3, x3   <-- Load-Use Hazard here
        memory[5] = 32'h01400313; // ADDI x6, x0, 20
    end

    // Combinational read: convert byte address to word index by dropping bottom 2 bits
    assign instruction = memory[addr[31:2]];

endmodule
