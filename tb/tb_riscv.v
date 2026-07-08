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

        #150; // Extended run time to allow for the stall cycle

        $display("--------------------------------------------------");
        $display("Register Check:");
        $display("x1 = %d (Expected: 5)",  uut.rf_u.registers[1]);
        $display("x2 = %d (Expected: 0)",  uut.rf_u.registers[2]);
        $display("x3 = %d (Expected: 5)",  uut.rf_u.registers[3]);
        $display("x4 = %d (Expected: 10)", uut.rf_u.registers[4]);
        $display("x6 = %d (Expected: 20)", uut.rf_u.registers[6]);
        $display("--------------------------------------------------");

        $display("Simulation Finished. Check waveforms/riscv_sim.vcd");
        $finish;
    end
endmodule
