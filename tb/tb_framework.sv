`timescale 1ns / 1ps

/**
 * Avionics Gateway Testbench Framework
 * Provides common utilities for all module testing
 */

// Simple test logger
class TestLogger;
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    function void test_start(string name);
        test_count++;
        $display("[TEST %0d] START: %s", test_count, name);
    endfunction
    
    function void test_pass(string msg);
        pass_count++;
        $display("  ✓ PASS: %s", msg);
    endfunction
    
    function void test_fail(string msg);
        fail_count++;
        $display("  ✗ FAIL: %s", msg);
    endfunction
    
    function void test_assert(bit condition, string msg);
        if (condition)
            test_pass(msg);
        else
            test_fail(msg);
    endfunction
    
    function void summary();
        $display("\n======================================");
        $display("TEST SUMMARY");
        $display("======================================");
        $display("Total: %0d | Pass: %0d | Fail: %0d", test_count, pass_count, fail_count);
        if (fail_count == 0)
            $display("✓ ALL TESTS PASSED");
        else
            $display("✗ %0d TESTS FAILED", fail_count);
        $display("======================================\n");
    endfunction
endclass

// AXI Stream transaction generator
class AXI_Stream_Transaction;
    rand bit [31:0] data;
    rand bit keep;
    rand bit last;
    
    function string to_string();
        return $sformatf("data=0x%08x keep=%b last=%b", data, keep, last);
    endfunction
endclass

// CAN frame transaction generator (Icarus Verilog compatible)
class CAN_Frame_Transaction;
    rand bit [10:0] can_id;
    rand bit [7:0] dlc;
    rand bit [63:0] payload;
    
    // post_randomize fixes DLC to valid range (0-8)
    // Replaces constraint block which isn't supported by Icarus Verilog
    function void post_randomize();
        if (dlc > 8)
            dlc = dlc % 9;  // Clamp to 0-8 range
    endfunction
    
    function string to_string();
        return $sformatf("CAN_ID=0x%03x DLC=%0d PAYLOAD=0x%016x", can_id, dlc, payload);
    endfunction
endclass