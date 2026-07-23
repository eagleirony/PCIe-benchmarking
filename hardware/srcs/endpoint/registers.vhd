----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/26/2026 02:53:10 PM
-- Design Name:
-- Module Name: registers - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.utils_param.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity registers is
  generic (
    data_width : integer := 32;
    addr_width : integer := 8
  );
  port (
    -- Control interface (AXI4-Lite)
    s_axil_aclk    : in    std_logic;
    s_axil_aresetn : in    std_logic;
    s_axil_awaddr  : in    std_logic_vector(addr_width - 1 downto 0);
    s_axil_awprot  : in    std_logic_vector(2 downto 0);
    s_axil_awvalid : in    std_logic;
    s_axil_awready : out   std_logic;
    s_axil_wdata   : in    std_logic_vector(data_width - 1 downto 0);
    s_axil_wstrb   : in    std_logic_vector((data_width / 8) - 1 downto 0);
    s_axil_wvalid  : in    std_logic;
    s_axil_wready  : out   std_logic;
    s_axil_bresp   : out   std_logic_vector(1 downto 0);
    s_axil_bvalid  : out   std_logic;
    s_axil_bready  : in    std_logic;
    s_axil_araddr  : in    std_logic_vector(addr_width - 1 downto 0);
    s_axil_arprot  : in    std_logic_vector(2 downto 0);
    s_axil_arvalid : in    std_logic;
    s_axil_arready : out   std_logic;
    s_axil_rdata   : out   std_logic_vector(data_width - 1 downto 0);
    s_axil_rresp   : out   std_logic_vector(1 downto 0);
    s_axil_rvalid  : out   std_logic;
    s_axil_rready  : in    std_logic;

    -- User registers
    fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);

    msi_ena : in std_logic;
    msi_count : in std_logic_vector(2 downto 0);
    c2h_sts : in std_logic_vector(7 downto 0);
    h2c_sts : in std_logic_vector(7 downto 0);

    uptime_counter  : in    std_logic_vector((data_width * 2) - 1 downto 0);
    user_counter    : in    std_logic_vector(data_width - 1 downto 0)
  );
end entity registers;

architecture behavioral of registers is

signal pcie_status_reg : std_logic_vector(data_width - 1 downto 0);

begin

  pcie_status_reg(7 downto 0) <= c2h_sts;
  pcie_status_reg(13 downto 8) <= h2c_sts;
  pcie_status_reg(14) <= msi_ena;
  pcie_status_reg(17 downto 15) <= msi_count;
  pcie_status_reg(data_width - 1 downto 18) <= (others => '0');

  axil_bus_regs : axil_bus
  generic map (
    c_s_axi_data_width => data_width,
    c_s_axi_addr_width => addr_width
  )
  port map (
    reg_6_r => pcie_status_reg,
    reg_7_r => fifo_status_reg,
    reg_8_r => uptime_counter((data_width * 2) - 1 downto data_width),
    reg_9_r => uptime_counter(data_width - 1 downto 0),
    reg_10_r => user_counter,
    s_axi_aclk => s_axil_aclk,
    s_axi_aresetn => s_axil_aresetn,
    s_axi_awaddr => s_axil_awaddr,
    s_axi_awprot => s_axil_awprot,
    s_axi_awvalid => s_axil_awvalid,
    s_axi_awready => s_axil_awready,
    s_axi_wdata => s_axil_wdata,
    s_axi_wstrb => s_axil_wstrb,
    s_axi_wvalid => s_axil_wvalid,
    s_axi_wready => s_axil_wready,
    s_axi_bresp => s_axil_bresp,
    s_axi_bvalid => s_axil_bvalid,
    s_axi_bready => s_axil_bready,
    s_axi_araddr => s_axil_araddr,
    s_axi_arprot => s_axil_arprot,
    s_axi_arvalid => s_axil_arvalid,
    s_axi_arready => s_axil_arready,
    s_axi_rdata => s_axil_rdata,
    s_axi_rresp => s_axil_rresp,
    s_axi_rvalid => s_axil_rvalid,
    s_axi_rready => s_axil_rready
  );

end architecture behavioral;
