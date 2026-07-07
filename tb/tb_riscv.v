// tb/tb_riscv.v
// Testbench: Provides clock and reset, then runs the processor for a fixed time.

module tb_riscv();
    reg clk;
    reg rst;

    // Instantiate the Top Module (the entire processor)
    riscv_top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: flips clk every 5ns, giving a 10ns period
    always #5 clk = ~clk;

    initial begin
        $display("Starting Simulation...");
        $dumpfile("waveforms/riscv_sim.vcd");
        $dumpvars(0, tb_riscv);

        clk = 0;
        rst = 1;
        #20 rst = 0; // Release reset after 2 clock cycles
        #100; // Let the processor run for 100ns

               $display("--------------------------------------------------");
        $display("Register Check:");
        // Note: rf_unit is the instance name we used inside riscv_top
        $display("x5 = %d (Expected: 10)", uut.rf_unit.registers[5]);
        $display("x6 = %d (Expected: 20)", uut.rf_unit.registers[6]);
        $display("x7 = %d (Expected: 30)", uut.rf_unit.registers[7]);
        $display("--------------------------------------------------");


    end
endmodule
