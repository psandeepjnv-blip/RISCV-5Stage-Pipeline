// rtl/inst_mem.v
// Instruction Memory: Stores our test program and returns instructions based on the PC address.

module inst_mem (
    input  wire [31:0] addr,        // Address coming from the Program Counter
    output wire [31:0] instruction  // The 32-bit instruction at that address
);

    // A simple array of 32-bit "words." We have room for 64 instructions.
    reg [31:0] memory [0:63];

    // Load our test program into memory when the simulation starts.
    initial begin
        // ADDI x5, x0, 10   -> x5 = 0 + 10  = 10
        memory[0] = 32'h00A00293;
        // ADDI x6, x0, 20   -> x6 = 0 + 20  = 20
        memory[1] = 32'h01400313;
        // ADD  x7, x5, x6   -> x7 = x5 + x6 = 30
        memory[2] = 32'h006283B3;
        // NOP (do nothing, just to have a safe instruction at the end)
        memory[3] = 32'h00000013;
    end

    // Instruction Memory is "read-only" from the pipeline's point of view.
    // We use the top bits of the address (divided by 4, since each instruction is 4 bytes)
    // to select which word in our array to output.
    assign instruction = memory[addr[31:2]];

endmodule
