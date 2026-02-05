`timescale 1ns / 1ps

module gateway_top (
    // DDR3 Memory Interface (connects to PYNQ-Z2 DDR chip)
    inout  [14:0] DDR_addr,
    inout  [2:0]  DDR_ba,
    inout         DDR_cas_n,
    inout         DDR_ck_n,
    inout         DDR_ck_p,
    inout         DDR_cke,
    inout         DDR_cs_n,
    inout  [3:0]  DDR_dm,
    inout  [31:0] DDR_dq,
    inout  [3:0]  DDR_dqs_n,
    inout  [3:0]  DDR_dqs_p,
    inout         DDR_odt,
    inout         DDR_ras_n,
    inout         DDR_reset_n,
    inout         DDR_we_n,
    
    // Fixed IO (PS configuration pins)
    inout         FIXED_IO_ddr_vrn,
    inout         FIXED_IO_ddr_vrp,
    inout  [53:0] FIXED_IO_mio,
    inout         FIXED_IO_ps_clk,
    inout         FIXED_IO_ps_porb,
    inout         FIXED_IO_ps_srstb,
    
    // CAN Physical Layer (connect to transceiver)
    input  wire   can_rx,     // From SN65HVD230 RX pin
    output wire   can_tx      // To SN65HVD230 TX pin
);

    // ========================================
    // Instantiate Vivado Block Design
    // ========================================
    
    design_1_wrapper zynq_system (
        // DDR3 connections (pass-through to top-level ports)
        .DDR_addr       (DDR_addr),
        .DDR_ba         (DDR_ba),
        .DDR_cas_n      (DDR_cas_n),
        .DDR_ck_n       (DDR_ck_n),
        .DDR_ck_p       (DDR_ck_p),
        .DDR_cke        (DDR_cke),
        .DDR_cs_n       (DDR_cs_n),
        .DDR_dm         (DDR_dm),
        .DDR_dq         (DDR_dq),
        .DDR_dqs_n      (DDR_dqs_n),
        .DDR_dqs_p      (DDR_dqs_p),
        .DDR_odt        (DDR_odt),
        .DDR_ras_n      (DDR_ras_n),
        .DDR_reset_n    (DDR_reset_n),
        .DDR_we_n       (DDR_we_n),
        
        // Fixed IO connections
        .FIXED_IO_ddr_vrn   (FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp   (FIXED_IO_ddr_vrp),
        .FIXED_IO_mio       (FIXED_IO_mio),
        .FIXED_IO_ps_clk    (FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb   (FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb  (FIXED_IO_ps_srstb),
        
        // CAN physical layer
        .can_phy_rx_0   (can_rx),
        .can_phy_tx_0   (can_tx)
    );
    
    // ========================================
    // TODO: Add Custom Filter in Phase 3
    // ========================================
    
    // For now, CAN data flows directly:
    // CAN Bus → Transceiver → CAN IP → AXI Bus → ARM CPU
    //
    // Next phase: Intercept CAN frames before CPU
    // CAN IP → can_filter.sv → DMA → CPU

endmodule