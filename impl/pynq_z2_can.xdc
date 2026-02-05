# ==================================================
# CAN Transceiver Pin Mapping
# ==================================================
# Using PMOD connector JB (change to your actual pins)
# Check PYNQ-Z2 schematic for exact pin numbers

# CAN RX (Input from transceiver)
set_property PACKAGE_PIN T20 [get_ports can_rx]
set_property IOSTANDARD LVCMOS33 [get_ports can_rx]

# CAN TX (Output to transceiver)
set_property PACKAGE_PIN U20 [get_ports can_tx]
set_property IOSTANDARD LVCMOS33 [get_ports can_tx]

# ==================================================
# Timing Constraints
# ==================================================
# CAN signals are relatively slow (1 Mbps max), no special timing needed
# The 100 MHz system clock from PS7 is already constrained by Vivado

# ==================================================
# Notes
# ==================================================
# PMOD JB Pin Mapping (example):
# JB1 (Top Row Pin 1)  = T20 = can_rx
# JB2 (Top Row Pin 2)  = U20 = can_tx
# JB3 (Top Row Pin 3)  = V20 = GND
# JB4 (Top Row Pin 4)  = W20 = VCC (3.3V)
#
# Connect SN65HVD230:
# - CAN_RX → FPGA can_rx (T20)
# - CAN_TX → FPGA can_tx (U20)
# - VCC → 3.3V
# - GND → GND
# - CANH/CANL → CAN bus with 120Ω termination