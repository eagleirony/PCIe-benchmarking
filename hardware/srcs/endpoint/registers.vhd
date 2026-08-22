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
  use work.shared_param.all;

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
    h2c_fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);
    c2h_fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);

    c2h_chan_0_packet_len : out std_logic_vector(data_width - 1 downto 0);

    msi_ena : in std_logic;
    msi_count : in std_logic_vector(2 downto 0);
    c2h_sts : in std_logic_vector(7 downto 0);
    h2c_sts : in std_logic_vector(7 downto 0);

    uptime_counter  : in    std_logic_vector((data_width * 2) - 1 downto 0);
    user_counter    : in    std_logic_vector(data_width - 1 downto 0);

    build_ver : in std_logic_vector(data_width - 1 downto 0);
    build_id : in std_logic_vector(data_width - 1 downto 0)
  );
end entity registers;

architecture behavioral of registers is

signal pcie_status_reg : std_logic_vector(data_width - 1 downto 0);

signal scratch_0 : std_logic_vector(data_width - 1 downto 0);
signal scratch_1 : std_logic_vector(data_width - 1 downto 0);
signal scratch_2 : std_logic_vector(data_width - 1 downto 0);
signal scratch_3 : std_logic_vector(data_width - 1 downto 0);

signal c2h_chan_0_packet_len_sig : std_logic_vector(data_width - 1 downto 0);

begin

  pcie_status_reg(7 downto 0) <= c2h_sts;
  pcie_status_reg(15 downto 8) <= h2c_sts;
  pcie_status_reg(16) <= msi_ena;
  pcie_status_reg(19 downto 17) <= msi_count;
  pcie_status_reg(data_width - 1 downto 20) <= (others => '0');

  c2h_chan_0_packet_len <= c2h_chan_0_packet_len_sig;

  axil_bus_regs : axil_bus
  generic map (
    c_s_axi_data_width => data_width,
    c_s_axi_addr_width => addr_width
  )
  port map (
    reg_0_r => x"55AA55AA",
    reg_1_r => x"AA55AA55",
    reg_2_r => x"00000000",
    reg_3_r => x"FFFFFFFF",
    reg_4_r => x"01234567",
    reg_5_r => x"89ABCDEF",
    reg_6_r => pcie_status_reg,
    reg_7_r => c2h_fifo_status_reg,
    reg_8_r => uptime_counter((data_width * 2) - 1 downto data_width),
    reg_9_r => uptime_counter(data_width - 1 downto 0),
    reg_10_r => user_counter,
    reg_11_r => build_id,
    reg_12_r => build_ver,
    reg_13_r => x"00000000",
    reg_14_r => x"00000000",
    reg_15_r => x"00000000",
    reg_16_r => x"00000000",
    reg_17_r => x"00000000",
    reg_18_r => x"00000000",
    reg_19_r => x"00000000",
    reg_20_r => x"00000000",
    reg_21_r => x"00000000",
    reg_22_r => x"00000000",
    reg_23_r => x"00000000",
    reg_24_r => x"00000000",
    reg_25_r => x"00000000",
    reg_26_r => x"00000000",
    reg_27_r => x"00000000",
    reg_28_r => x"00000000",
    reg_29_r => x"00000000",
    reg_30_r => x"00000000",
    reg_31_r => x"00000000",
    reg_32_r => scratch_0,
    reg_33_r => scratch_1,
    reg_34_r => scratch_2,
    reg_35_r => scratch_3,
    reg_36_r => c2h_chan_0_packet_len_sig,
    reg_37_r => x"00000000",
    reg_38_r => x"00000000",
    reg_39_r => x"00000000",
    reg_40_r => x"00000000",
    reg_41_r => x"00000000",
    reg_42_r => x"00000000",
    reg_43_r => x"00000000",
    reg_44_r => x"00000000",
    reg_45_r => x"00000000",
    reg_46_r => x"00000000",
    reg_47_r => x"00000000",
    reg_48_r => x"00000000",
    reg_49_r => x"00000000",
    reg_50_r => x"00000000",
    reg_51_r => x"00000000",
    reg_52_r => x"00000000",
    reg_53_r => x"00000000",
    reg_54_r => x"00000000",
    reg_55_r => x"00000000",
    reg_56_r => x"00000000",
    reg_57_r => x"00000000",
    reg_58_r => x"00000000",
    reg_59_r => x"00000000",
    reg_60_r => x"00000000",
    reg_61_r => x"00000000",
    reg_62_r => x"00000000",
    reg_63_r => x"00000000",

    -- Write ports
    reg_0_w => open,
    reg_1_w => open,
    reg_2_w => open,
    reg_3_w => open,
    reg_4_w => open,
    reg_5_w => open,
    reg_6_w => open,
    reg_7_w => open,
    reg_8_w => open,
    reg_9_w => open,
    reg_10_w => open,
    reg_11_w => open,
    reg_12_w => open,
    reg_13_w => open,
    reg_14_w => open,
    reg_15_w => open,
    reg_16_w => open,
    reg_17_w => open,
    reg_18_w => open,
    reg_19_w => open,
    reg_20_w => open,
    reg_21_w => open,
    reg_22_w => open,
    reg_23_w => open,
    reg_24_w => open,
    reg_25_w => open,
    reg_26_w => open,
    reg_27_w => open,
    reg_28_w => open,
    reg_29_w => open,
    reg_30_w => open,
    reg_31_w => open,
    reg_32_w => scratch_0,
    reg_33_w => scratch_1,
    reg_34_w => scratch_2,
    reg_35_w => scratch_3,
    reg_36_w => c2h_chan_0_packet_len_sig,
    reg_37_w => open,
    reg_38_w => open,
    reg_39_w => open,
    reg_40_w => open,
    reg_41_w => open,
    reg_42_w => open,
    reg_43_w => open,
    reg_44_w => open,
    reg_45_w => open,
    reg_46_w => open,
    reg_47_w => open,
    reg_48_w => open,
    reg_49_w => open,
    reg_50_w => open,
    reg_51_w => open,
    reg_52_w => open,
    reg_53_w => open,
    reg_54_w => open,
    reg_55_w => open,
    reg_56_w => open,
    reg_57_w => open,
    reg_58_w => open,
    reg_59_w => open,
    reg_60_w => open,
    reg_61_w => open,
    reg_62_w => open,
    reg_63_w => open,
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
