`timescale 1ns / 1ps

`include "tb_framework.sv"

module can_filter_tb;
    // Clock and reset
    reg clk;
    reg rst_n;
    
    // CAN filter interface
    reg [10:0] id_in;
    reg id_valid_in;
    reg [10:0] accept_code;
    reg [10:0] accept_mask;
    wire id_valid_out;
    wire [10:0] id_out;
    
    // Instantiate DUT
    can_filter dut (
        .clk(clk),
        .rst_n(rst_n),
        .id_in(id_in),
        .id_valid_in(id_valid_in),
        .accept_code(accept_code),
        .accept_mask(accept_mask),
        .id_valid_out(id_valid_out),
        .id_out(id_out)
    );
    
    // Test logger
    TestLogger logger = new();
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end
    
    // Test task
    task send_can_id(input [10:0] id, input should_pass);
        begin
            @(posedge clk);
            id_in = id;
            id_valid_in = 1;
            @(posedge clk);
            // Sample output on the SAME cycle that id_valid_in is high
            // because id_valid_out follows id_valid_in in registered logic
            
            if (should_pass) begin
                logger.test_assert(id_valid_out, $sformatf("ID 0x%03x should pass filter", id));
                if (id_valid_out) begin
                    logger.test_assert(id_out == id, $sformatf("Output ID match: expected 0x%03x, got 0x%03x", id, id_out));
                end
            end else begin
                logger.test_assert(!id_valid_out, $sformatf("ID 0x%03x should be filtered", id));
            end
            
            id_valid_in = 0;  // Clear input after sampling
            @(posedge clk);
        end
    endtask
    
    // Main test sequence
    initial begin
        $dumpfile("can_filter_tb.vcd");
        $dumpvars(0, can_filter_tb);
        
        // Initialize signals
        rst_n = 0;
        id_in = 0;
        id_valid_in = 0;
        accept_code = 0;
        accept_mask = 0;
        
        // Reset
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);
        
        $display("\n========================================");
        $display("CAN Filter Testbench");
        $display("========================================\n");
        
        // TEST 1: Exact match filter (all mask bits set)
        logger.test_start("Exact match filter - accept ID 0x100");
        accept_code = 11'h100;
        accept_mask = 11'h7FF;  // All bits must match
        
        send_can_id(11'h100, 1);  // Should pass
        send_can_id(11'h101, 0);  // Should fail
        send_can_id(11'h200, 0);  // Should fail
        
        // TEST 2: Partial match with mask
        logger.test_start("Masked filter - accept 0x3xx (upper 4 bits)");
        accept_code = 11'h300;
        accept_mask = 11'h700;  // Match bits [10:8] only (upper 3 bits)
        
        send_can_id(11'h300, 1);  // Should pass: 0x300 & 0x700 = 0x300
        send_can_id(11'h310, 1);  // Should pass: 0x310 & 0x700 = 0x300
        send_can_id(11'h37F, 1);  // Should pass: 0x37F & 0x700 = 0x300
        send_can_id(11'h3FF, 1);  // Should pass: 0x3FF & 0x700 = 0x300
        send_can_id(11'h200, 0);  // Should fail: 0x200 & 0x700 = 0x200
        send_can_id(11'h400, 0);  // Should fail: 0x400 & 0x700 = 0x400
        
        // TEST 3: Accept all (mask = 0)
        logger.test_start("Accept all filter - mask = 0");
        accept_code = 11'h000;
        accept_mask = 11'h000;  // No bits need to match
        
        send_can_id(11'h123, 1);  // Should pass
        send_can_id(11'h456, 1);  // Should pass
        send_can_id(11'h7FF, 1);  // Should pass
        
        // TEST 4: Reset behavior
        logger.test_start("Reset clears output");
        accept_code = 11'h100;
        accept_mask = 11'h7FF;
        @(posedge clk);
        id_in = 11'h100;
        id_valid_in = 1;
        @(posedge clk);
        
        rst_n = 0;
        repeat(2) @(posedge clk);
        logger.test_assert(!id_valid_out, "Output should be cleared during reset");
        
        rst_n = 1;
        repeat(2) @(posedge clk);
        
        // TEST 5: Multiple consecutive frames
        logger.test_start("Multiple consecutive valid frames");
        accept_code = 11'h200;
        accept_mask = 11'h700;  // Match upper 3 bits
        
        send_can_id(11'h200, 1);
        send_can_id(11'h250, 1);
        send_can_id(11'h2AA, 1);
        
        // Summary
        repeat(10) @(posedge clk);
        logger.summary();
        
        $finish;
    end
    
    // Timeout
    initial begin
        #50000;
        $display("ERROR: Testbench timeout!");
        $finish;
    end
    
endmodule