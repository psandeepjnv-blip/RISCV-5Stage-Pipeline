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
        $display("Simulation Finished. Check waveforms/riscv_sim.vcd");
        $finish;
    end
endmodule
