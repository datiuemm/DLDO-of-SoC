`timescale 1ns / 1ps

module ldo_top_tb;

    
    // === Parameters ===
    parameter integer ARRSZ = 9;

    // === Inputs ===
    reg clk;
    reg reset;
    reg trim1, trim2, trim3, trim4, trim5, trim6, trim7, trim8, trim9, trim10;
    reg [1:0] mode_sel;
    reg std_ctrl_in;
    reg [8:0] std_pt_in_cnt;

    // === Outputs ===
    wire cmp_out;
    wire [8:0] ctrl_out;

    // === Instantiate DUT ===
    ${design_name} #(.ARRSZ(ARRSZ)) uut (
        .clk(clk),
        .reset(reset),
        .trim1(trim1), .trim2(trim2), .trim3(trim3), .trim4(trim4), .trim5(trim5),
        .trim6(trim6), .trim7(trim7), .trim8(trim8), .trim9(trim9), .trim10(trim10),
        .mode_sel(mode_sel),
        .std_ctrl_in(std_ctrl_in),
        .std_pt_in_cnt(std_pt_in_cnt),
        .cmp_out(cmp_out),
        .ctrl_out(ctrl_out)
    );

    // === Clock Generation ===
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    // === Waveform Dump ===
    initial begin
        $dumpfile("${design_name}_tb.vcd");
        $dumpvars(0, ${design_name}_tb);
    end

    // === Monitor ===
    initial begin
        $monitor("Time: %0t | Mode: %b | cmp_out = %b | ctrl_out = %d | std_ctrl_in = %b", 
                  $time, mode_sel, cmp_out, ctrl_out, std_ctrl_in);
    end

    // === Reset ===
    task do_reset();
    begin
        reset = 1;
        #20;
        reset = 0;
    end
    endtask

    // === Mode Test Task ===
    task test_mode(input [1:0] mode, input reg ctrl_in, input [8:0] pt_cnt);
    begin
        mode_sel = mode;
        std_ctrl_in = ctrl_in;
        std_pt_in_cnt = pt_cnt;

        $display("\n--- Testing Mode: %b ---", mode);
        #100;
    end
    endtask

    // === Initial Test ===
    initial begin
        // Initial conditions
        {trim1, trim2, trim3, trim4, trim5, trim6, trim7, trim8, trim9, trim10} = 10'b0000000000;
        std_ctrl_in = 0;
        std_pt_in_cnt = 0;

        // Reset
        do_reset();

        // === Test Mode 00: Comparator & PT Array Test Mode ===
        test_mode(2'b00, 1'b1, 9'd3);

        // === Test Mode 01: Controller Test Mode ===
        test_mode(2'b01, 1'b0, 9'd5);

        // === Test Mode 10: LDO Run Mode ===
        test_mode(2'b10, 1'b0, 9'd7);

        // === Test Mode 11: Also treated as LDO Run Mode ===
        test_mode(2'b11, 1'b1, 9'd8);

        $display("\nAll test modes completed.");
        #20;
        $finish;
    end

endmodule