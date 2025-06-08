`timescale 1ns/1ps

module LDO_CONTROLLER_tb;

    // === Parameters ===
    parameter integer ARRSZ = 9;
    parameter [ARRSZ-1:0] ctrlWdRst = 9'b000000001;

    // === Inputs ===
    reg clk, reset, ctrl_in, mode;
    reg [8:0] std_pt_in_cnt;

    // === Outputs ===
    wire [ARRSZ-1:0] ctrl_word;
    wire [8:0]       ctrl_word_cnt;

    // === Instantiate DUT ===
    LDO_CONTROLLER #(.ARRSZ(ARRSZ)) dut (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .ctrl_in(ctrl_in),
        .std_pt_in_cnt(std_pt_in_cnt),
        .ctrl_word(ctrl_word),
        .ctrl_word_cnt(ctrl_word_cnt)
    );

    // === Clock generation ===
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

    // === Waveform ===
    initial begin
        $dumpfile("LDO_CONTROLLER_tb.vcd");
        $dumpvars(0, LDO_CONTROLLER_tb);
    end

    // === Reset task ===
    task apply_reset();
    begin
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        @(posedge clk);
    end
    endtask

    // === Test Test-Mode (mode=0) ===
    task test_test_mode(input [8:0] pt_in_val);
        reg [ARRSZ-1:0] expected_word;
    begin
        mode = 0;
        std_pt_in_cnt = pt_in_val;
        @(posedge clk);

        expected_word = ctrlWdRst << pt_in_val;

        // Check expected outputs
        assert(ctrl_word === expected_word)
            else $fatal("Test Mode FAILED at pt_in = %0d: got %b, expected %b", pt_in_val, ctrl_word, expected_word);
        assert(ctrl_word_cnt === pt_in_val)
            else $fatal("Test Mode Count FAIL: got %0d, expected %0d", ctrl_word_cnt, pt_in_val);
        
        $display("[PASS] Test Mode with pt_in = %0d → ctrl_word = %b", pt_in_val, ctrl_word);
    end
    endtask

    // === Test Run-Mode (mode=1) ===
    task test_run_mode_sequence();
    begin
        mode = 1;
        // Initialize to known state
        apply_reset();

        // Case 1: ctrl_in = 1 → shift right, cnt--
        ctrl_in = 1;
        repeat (3) @(posedge clk);

        // Case 2: ctrl_in = 0 → shift left, cnt++
        ctrl_in = 0;
        repeat (3) @(posedge clk);

        $display("[INFO] Run Mode sequence completed.");
        $display("ctrl_word = %b, ctrl_word_cnt = %0d", ctrl_word, ctrl_word_cnt);
    end
    endtask

    // === Initial block ===
    initial begin
        // Default values
        mode = 0;
        ctrl_in = 0;
        std_pt_in_cnt = 0;

        $display("=========== Starting LDO_CONTROLLER Testbench ===========");

        apply_reset();

        // Run test mode with several values
        test_test_mode(0);
        test_test_mode(2);
        test_test_mode(5);
        test_test_mode(ARRSZ - 1);

        // Run shift test in run mode
        test_run_mode_sequence();

        $display("=========== ALL TESTS PASSED ===========");
        #20;
        $finish;
    end

endmodule