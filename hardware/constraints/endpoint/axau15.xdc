# ###################################################################
#
# Vivado 2025.1
# AXAU15
# 27-02-2026
#
# ###################################################################

set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

#'2.7,5.3,8.0,10.6,21.3,31.9,36.4,51.0,56.7,63.8,72.9,85.0,102.0,127.5'
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN pullnone [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

# ###################################################################
# 200MHz 
# ###################################################################
set_property PACKAGE_PIN T24 [get_ports Clk200_p]
set_property PACKAGE_PIN U24 [get_ports Clk200_n]
set_property IOSTANDARD LVDS [get_ports Clk200_p]
set_property IOSTANDARD LVDS [get_ports Clk200_n]
set_property DIFF_TERM_ADV TERM_100 [get_ports Clk200_p]

create_clock -period 5.000 -name clk200_p [get_ports Clk200_p]

# ###################################################################
# LEDs
# ###################################################################
# LED1 W21
set_property IOSTANDARD LVCMOS18 [get_ports Led]
set_property PACKAGE_PIN W21 [get_ports Led]

# ###################################################################
# PCIe 
# ###################################################################

# 100MHz Reference clock
set_property PACKAGE_PIN AB7 [get_ports {Sys_clk_p}]
set_property PACKAGE_PIN AB6 [get_ports {Sys_clk_n}]

create_clock -period 10.000 -name Sys_clk [get_ports Sys_clk_p]

# Reset
set_property IOSTANDARD LVCMOS18 [get_ports Sys_rst_n]
set_property PACKAGE_PIN T19 [get_ports Sys_rst_n]

# RX
set_property PACKAGE_PIN AB2 [get_ports {Pcie_rx_p[0]}]
set_property PACKAGE_PIN AB1 [get_ports {Pcie_rx_n[0]}]

set_property PACKAGE_PIN AD2 [get_ports {Pcie_rx_p[1]}]
set_property PACKAGE_PIN AD1 [get_ports {Pcie_rx_n[1]}]

set_property PACKAGE_PIN AE4 [get_ports {Pcie_rx_p[2]}]
set_property PACKAGE_PIN AE3 [get_ports {Pcie_rx_n[2]}]

set_property PACKAGE_PIN AF2 [get_ports {Pcie_rx_p[3]}]
set_property PACKAGE_PIN AF1 [get_ports {Pcie_rx_n[3]}]

# TX
set_property PACKAGE_PIN AC5 [get_ports {Pcie_tx_p[0]}]
set_property PACKAGE_PIN AC4 [get_ports {Pcie_tx_n[0]}]

set_property PACKAGE_PIN AD7 [get_ports {Pcie_tx_p[1]}]
set_property PACKAGE_PIN AD6 [get_ports {Pcie_tx_n[1]}]

set_property PACKAGE_PIN AE9 [get_ports {Pcie_tx_p[2]}]
set_property PACKAGE_PIN AE8 [get_ports {Pcie_tx_n[2]}]

set_property PACKAGE_PIN AF7 [get_ports {Pcie_tx_p[3]}]
set_property PACKAGE_PIN AF6 [get_ports {Pcie_tx_n[3]}]

