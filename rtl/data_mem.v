// rtl/data_mem.v
// Data Memory: Used by Load (LW) and Store (SW) instructions.

module data_mem (
    input  wire        clk,
    input  wire [31:0] addr,        // Address to read/write (comes from ALU result)
    input  wire [31:0] write_data,  // Value to store (for SW)
    input  wire        mem_read,    // High for LW
    input  wire        mem_write,   // High for SW
    output wire [31:0] read_data    // Value loaded (for LW)
);

    // 64 slots, each 32 bits wide - same size as our instruction memory.
    reg [31:0] memory [0:63];
    integer k;

    // Initialize all memory to 0 at the start of simulation.
    initial begin
        for (k = 0; k < 64; k = k + 1) begin
            memory[k] = 32'b0;
        end
    end

    // Write Logic: Synchronous - only happens on the clock edge, and only if mem_write is high.
    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[31:2]] <= write_data;
        end
    end

    // Read Logic: Combinational - happens instantly, matching mem_read.
    // If mem_read is low, we still technically output something, but the
    // Control Unit ensures this value is only actually used when mem_read is high.
    assign read_data = memory[addr[31:2]];

endmodule
