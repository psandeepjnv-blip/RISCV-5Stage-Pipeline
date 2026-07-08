// rtl/hazard_detection_unit.v
// Hazard Detection Unit: Detects the load-use hazard and stalls the
// pipeline for exactly one cycle when forwarding alone cannot help.

module hazard_detection_unit (
    input  wire        mem_read_ex,   // Is the instruction in EX stage a Load?
    input  wire [4:0]  rd_ex,         // Destination register of that Load
    input  wire [4:0]  rs1_id,        // Source register 1 needed by ID stage
    input  wire [4:0]  rs2_id,        // Source register 2 needed by ID stage

    output reg          stall         // High for one cycle when a stall is needed
);

    always @(*) begin
        stall = 1'b0;

        if (mem_read_ex && (rd_ex != 5'b0) &&
           ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall = 1'b1;
        end
    end

endmodule
