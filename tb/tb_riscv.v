// tb/tb_riscv.v
// Testbench: Provides clock and reset, then runs the processor for a fixed time.

module tb_riscv();
    reg clk;
    reg rst;

    riscv_top uut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Starting Simulation...");
        $dumpfile("waveforms/riscv_sim.vcd");
        $dumpvars(0, tb_riscv);

        clk = 0;
        rst = 1;
        #20 rst = 0;

        #150;

        $display("--------------------------------------------------");
        $display("Branch Test Register Check:");
        $display("x1 = %d (Expected: 5)",  uut.rf_u.registers[1]);
        $display("x2 = %d (Expected: 5)",  uut.rf_u.registers[2]);
        $display("x3 = %d (Expected: 0, meaning it was correctly SKIPPED)", uut.rf_u.registers[3]);
        $display("x4 = %d (Expected: 42, proving we landed on the branch target)", uut.rf_u.registers[4]);
        $display("--------------------------------------------------");

        $display("Simulation Finished. Check waveforms/riscv_sim.vcd");
        $finish;
    end
endmodule
