// rtl/pc.v
// Program Counter Module: Holds the address of the current instruction.

module pc (
    input  wire        clk,        // Clock signal
    input  wire        rst,        // Reset signal
    input  wire        stall,      // Freezes the PC during hazards
    input  wire [31:0] pc_next,    // The next address to load (branch target or PC+4)
    output reg  [31:0] pc_out      // The current instruction address
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'b0;      // On reset, start execution at address 0
        end else if (!stall) begin
            pc_out <= pc_next;    // Update the PC only if we are not stalling
        end
        // If stall is high, pc_out simply holds its current value implicitly.
    end

endmodule
