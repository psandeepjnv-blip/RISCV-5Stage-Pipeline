// rtl/reg_file.v
// Register File: Stores 32 general-purpose registers (x0 - x31).
// Supports two simultaneous reads and one write per clock cycle.

module reg_file (
    input  wire        clk,
    input  wire        rst,
    input  wire        we,        // Write Enable
    input  wire [4:0]  rs1,       // Source register 1 address
    input  wire [4:0]  rs2,       // Source register 2 address
    input  wire [4:0]  rd,        // Destination register address
    input  wire [31:0] wd,        // Write Data
    output wire [31:0] rd1,       // Read Data 1
    output wire [31:0] rd2        // Read Data 2
);

    reg [31:0] registers [0:31];
    integer i;

    // Initialize all registers to 0 at the start of simulation.
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Write Logic: Synchronous, happens only on the clock edge.
    always @(posedge clk) begin
        if (we && rd != 5'b0) begin
            registers[rd] <= wd;
        end
    end

    // Read Logic: Combinational, happens instantly, no clock needed.
    // x0 is hardwired to always read as 0, no matter what was "written" to it.
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

endmodule
