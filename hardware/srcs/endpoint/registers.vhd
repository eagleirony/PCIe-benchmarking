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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity registers is
  generic (
    c_s00_axi_data_width : integer := 32;
    c_s00_axi_addr_width : integer := 8
  );
  port (
    clk : in    std_logic;
    rst : in    std_logic;
    --------------------------------------------------
    -- Control interface (AXI4-Lite)
    --------------------------------------------------
    s00_axi_aclk    : in    std_logic;
    s00_axi_aresetn : in    std_logic;
    s00_axi_awaddr  : in    std_logic_vector(c_s00_axi_addr_width - 1 downto 0);
    s00_axi_awprot  : in    std_logic_vector(2 downto 0);
    s00_axi_awvalid : in    std_logic;
    s00_axi_awready : out   std_logic;
    s00_axi_wdata   : in    std_logic_vector(c_s00_axi_data_width - 1 downto 0);
    s00_axi_wstrb   : in    std_logic_vector((c_s00_axi_data_width / 8) - 1 downto 0);
    s00_axi_wvalid  : in    std_logic;
    s00_axi_wready  : out   std_logic;
    s00_axi_bresp   : out   std_logic_vector(1 downto 0);
    s00_axi_bvalid  : out   std_logic;
    s00_axi_bready  : in    std_logic;
    s00_axi_araddr  : in    std_logic_vector(c_s00_axi_addr_width - 1 downto 0);
    s00_axi_arprot  : in    std_logic_vector(2 downto 0);
    s00_axi_arvalid : in    std_logic;
    s00_axi_arready : out   std_logic;
    s00_axi_rdata   : out   std_logic_vector(c_s00_axi_data_width - 1 downto 0);
    s00_axi_rresp   : out   std_logic_vector(1 downto 0);
    s00_axi_rvalid  : out   std_logic;
    s00_axi_rready  : in    std_logic
  );
end entity registers;

architecture behavioral of registers is

  component axil_bus is
    generic (
      c_s_axi_data_width : integer  := 32;
      c_s_axi_addr_width : integer  := 8
    );
    port (
      s_axi_aclk    : in    std_logic;
      s_axi_aresetn : in    std_logic;
      s_axi_awaddr  : in    std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      s_axi_awprot  : in    std_logic_vector(2 downto 0);
      s_axi_awvalid : in    std_logic;
      s_axi_awready : out   std_logic;
      s_axi_wdata   : in    std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      s_axi_wstrb   : in    std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
      s_axi_wvalid  : in    std_logic;
      s_axi_wready  : out   std_logic;
      s_axi_bresp   : out   std_logic_vector(1 downto 0);
      s_axi_bvalid  : out   std_logic;
      s_axi_bready  : in    std_logic;
      s_axi_araddr  : in    std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      s_axi_arprot  : in    std_logic_vector(2 downto 0);
      s_axi_arvalid : in    std_logic;
      s_axi_arready : out   std_logic;
      s_axi_rdata   : out   std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      s_axi_rresp   : out   std_logic_vector(1 downto 0);
      s_axi_rvalid  : out   std_logic;
      s_axi_rready  : in    std_logic
    );
  end component axil_bus;

begin

  axil_bus_regs : component axil_bus
    generic map (
      c_s_axi_data_width => c_s00_axi_data_width,
      c_s_axi_addr_width => c_s00_axi_addr_width
    )
    port map (
      s_axi_aclk    => s00_axi_aclk,
      s_axi_aresetn => s00_axi_aresetn,
      s_axi_awaddr  => s00_axi_awaddr,
      s_axi_awprot  => s00_axi_awprot,
      s_axi_awvalid => s00_axi_awvalid,
      s_axi_awready => s00_axi_awready,
      s_axi_wdata   => s00_axi_wdata,
      s_axi_wstrb   => s00_axi_wstrb,
      s_axi_wvalid  => s00_axi_wvalid,
      s_axi_wready  => s00_axi_wready,
      s_axi_bresp   => s00_axi_bresp,
      s_axi_bvalid  => s00_axi_bvalid,
      s_axi_bready  => s00_axi_bready,
      s_axi_araddr  => s00_axi_araddr,
      s_axi_arprot  => s00_axi_arprot,
      s_axi_arvalid => s00_axi_arvalid,
      s_axi_arready => s00_axi_arready,
      s_axi_rdata   => s00_axi_rdata,
      s_axi_rresp   => s00_axi_rresp,
      s_axi_rvalid  => s00_axi_rvalid,
      s_axi_rready  => s00_axi_rready
    );

end architecture behavioral;
