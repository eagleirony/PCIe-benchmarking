
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

library work;
  use work.shared_param.all;
  use work.endpoint_param.all;

-- ------------------------------------------------------------------------------------------
-- Entity
-- ------------------------------------------------------------------------------------------

entity top is
  generic (
    GLOBAL_DATE          : integer := 0;
    GLOBAL_TIME          : integer := 0;
    GLOBAL_VER           : std_logic_vector(31 downto 0) := (others => '0');
    GLOBAL_SHA           : std_logic_vector(31 downto 0) := (others => '0');
    TOP_SHA              : std_logic_vector(31 downto 0) := (others => '0');
    TOP_VER              : std_logic_vector(31 downto 0) := (others => '0');
    HOG_SHA              : std_logic_vector(31 downto 0) := (others => '0');
    HOG_VER              : std_logic_vector(31 downto 0) := (others => '0');
    CON_VER              : std_logic_vector(31 downto 0) := (others => '0');
    CON_SHA              : std_logic_vector(31 downto 0) := (others => '0');
    XIL_DEFAULTLIB_VER   : std_logic_vector(31 downto 0) := (others => '0');
    XIL_DEFAULTLIB_SHA   : std_logic_vector(31 downto 0) := (others => '0');
    IPS_VER              : std_logic_vector(31 downto 0) := (others => '0');
    IPS_SHA              : std_logic_vector(31 downto 0) := (others => '0');
    ENDPOINT_VER         : std_logic_vector(31 downto 0) := (others => '0');
    ENDPOINT_SHA         : std_logic_vector(31 downto 0) := (others => '0');

    axil_data_width : integer := 32;
    axil_addr_width : integer := 8;
    axis_data_width : integer := 64;
    pcie_lanes      : integer := 4
  );
  port (
    -- ---------------------------------------------------
    -- Clock
    -- ---------------------------------------------------

    -- 200MHz clock
    clk200_p : in    std_logic;
    clk200_n : in    std_logic;

    -- 100MHz clock
    sys_clk_p : in    std_logic;
    sys_clk_n : in    std_logic;

    -- ---------------------------------------------------
    -- Reset
    -- ---------------------------------------------------

    sys_rst_n : in    std_logic;

    -- ---------------------------------------------------
    -- IO Pins
    -- ---------------------------------------------------
    led1 : out   std_logic;
    led2 : out   std_logic;

    expand_port_in  : in    std_logic;
    expand_port_out : out   std_logic;

    -- ---------------------------------------------------
    -- PCIe
    -- ---------------------------------------------------

    -- TX
    pcie_tx_p : out   std_logic_vector(pcie_lanes - 1 downto 0);
    pcie_tx_n : out   std_logic_vector(pcie_lanes - 1 downto 0);

    -- RX
    pcie_rx_p : in    std_logic_vector(pcie_lanes - 1 downto 0);
    pcie_rx_n : in    std_logic_vector(pcie_lanes - 1 downto 0)
  );
end entity top;

-- ------------------------------------------------------------------------------------------
-- Architecture
-- ------------------------------------------------------------------------------------------

architecture rtl of top is

  signal clk200_out : std_logic;
  signal sys_clk    : std_logic;
  signal sys_clk_gt : std_logic;

  signal axi_aclk    : std_logic;
  signal axi_aresetn : std_logic;

  signal aclk_double : std_logic;

  signal pcie_link_status : std_logic;
  signal msi_req          : std_logic_vector(1 downto 0);
  signal msi_ack          : std_logic_vector(1 downto 0);

  -- AXI Lite register values
  signal uptime_counter : std_logic_vector((axil_data_width * 2) - 1 downto 0);
  signal user_counter   : std_logic_vector(axil_data_width - 1 downto 0);

  signal msi_ena   : std_logic;
  signal msi_count : std_logic_vector(2 downto 0);

  signal build_ver : std_logic_vector(axil_data_width - 1 downto 0);
  signal build_id  : std_logic_vector(axil_data_width - 1 downto 0);

  -- C2H Channel 0
  signal axis_c2h_0_tdata  : std_logic_vector(axis_data_width - 1 downto 0);
  signal axis_c2h_0_tstrb  : std_logic_vector((axis_data_width / 8) - 1 downto 0);
  signal axis_c2h_0_tlast  : std_logic;
  signal axis_c2h_0_tvalid : std_logic;
  signal axis_c2h_0_tready : std_logic;
  signal axis_c2h_0_tkeep  : std_logic_vector((axis_data_width / 8) - 1 downto 0);

  signal c2h_sts_0   : std_logic_vector(7 downto 0);

  signal pn23_c2h_0_value : std_logic_vector(axis_data_width - 1 downto 0);
  signal pn23_c2h_0_valid : std_logic;
  signal pn23_c2h_0_hold  : std_logic;

  signal c2h_chan_0_packet_len : std_logic_vector(axil_data_width - 1 downto 0);
  signal c2h_0_fifo_status : std_logic_vector(axil_data_width - 1 downto 0);

  -- C2H Channel 1
  signal axis_c2h_1_tdata  : std_logic_vector(axis_data_width - 1 downto 0);
  signal axis_c2h_1_tstrb  : std_logic_vector((axis_data_width / 8) - 1 downto 0);
  signal axis_c2h_1_tlast  : std_logic;
  signal axis_c2h_1_tvalid : std_logic;
  signal axis_c2h_1_tready : std_logic;
  signal axis_c2h_1_tkeep  : std_logic_vector((axis_data_width / 8) - 1 downto 0);

  signal c2h_sts_1   : std_logic_vector(7 downto 0);

  signal pn23_c2h_1_value : std_logic_vector(axis_data_width - 1 downto 0);
  signal pn23_c2h_1_valid : std_logic;
  signal pn23_c2h_1_hold  : std_logic;

  signal c2h_chan_1_packet_len : std_logic_vector(axil_data_width - 1 downto 0);
  signal c2h_1_fifo_status : std_logic_vector(axil_data_width - 1 downto 0);

  -- H2C Channel 0
  signal axis_h2c_tdata  : std_logic_vector(axis_data_width - 1 downto 0);
  signal axis_h2c_tstrb  : std_logic_vector((axis_data_width / 8) - 1 downto 0);
  signal axis_h2c_tlast  : std_logic;
  signal axis_h2c_tvalid : std_logic;
  signal axis_h2c_tready : std_logic;
  signal axis_h2c_tkeep  : std_logic_vector((axis_data_width / 8) - 1 downto 0);

  signal h2c_sts_0   : std_logic_vector(7 downto 0);

  signal h2c_data_out : std_logic_vector(axis_data_width - 1 downto 0);
  signal h2c_rd_ena   : std_logic;
  signal h2c_empty    : std_logic;

  signal h2c_0_fifo_status : std_logic_vector(axil_data_width - 1 downto 0);

  -- AXI Lite Bar space
  signal axil_awaddr  : std_logic_vector(31 downto 0);
  signal axil_awprot  : std_logic_vector(2 downto 0);
  signal axil_awvalid : std_logic;
  signal axil_awready : std_logic;
  signal axil_wdata   : std_logic_vector(axil_data_width - 1 downto 0);
  signal axil_wstrb   : std_logic_vector((axil_data_width / 8) - 1 downto 0);
  signal axil_wvalid  : std_logic;
  signal axil_wready  : std_logic;
  signal axil_bvalid  : std_logic;
  signal axil_bresp   : std_logic_vector(1 downto 0);
  signal axil_bready  : std_logic;
  signal axil_araddr  : std_logic_vector(31 downto 0);
  signal axil_arprot  : std_logic_vector(2 downto 0);
  signal axil_arvalid : std_logic;
  signal axil_arready : std_logic;
  signal axil_rdata   : std_logic_vector(axil_data_width - 1 downto 0);
  signal axil_rresp   : std_logic_vector(1 downto 0);
  signal axil_rvalid  : std_logic;
  signal axil_rready  : std_logic;

begin

  -- Clocking
  ibufds_inst : component ibufds
    generic map (

      diff_term  => false,
      iostandard => "DEFAULT"
    )
    port map (
      o  => clk200_out,
      i  => clk200_p,
      ib => clk200_n
    );

  ibufds_gte4_inst : component ibufds_gte4
    generic map (

      refclk_en_tx_path  => '0',
      refclk_hrow_ck_sel => "00",
      refclk_icntl_rx    => "00"
    )
    port map (
      o     => sys_clk_gt,
      odiv2 => sys_clk,
      ceb   => '0',
      i     => sys_clk_p,
      ib    => sys_clk_n
    );

  -- XDMA
  pcie_dma_inst : component xdma_0
    port map (
      sys_clk             => sys_clk,
      sys_clk_gt          => sys_clk_gt,
      sys_rst_n           => sys_rst_n,
      user_lnk_up         => pcie_link_status,
      pci_exp_txp         => pcie_tx_p,
      pci_exp_txn         => pcie_tx_n,
      pci_exp_rxp         => pcie_rx_p,
      pci_exp_rxn         => pcie_rx_n,
      axi_aclk            => axi_aclk,
      axi_aresetn         => axi_aresetn,
      usr_irq_req         => msi_req,
      usr_irq_ack         => msi_ack,
      msi_enable          => msi_ena,
      msi_vector_width    => msi_count,
      m_axil_awaddr       => axil_awaddr,
      m_axil_awprot       => axil_awprot,
      m_axil_awvalid      => axil_awvalid,
      m_axil_awready      => axil_awready,
      m_axil_wdata        => axil_wdata,
      m_axil_wstrb        => axil_wstrb,
      m_axil_wvalid       => axil_wvalid,
      m_axil_wready       => axil_wready,
      m_axil_bvalid       => axil_bvalid,
      m_axil_bresp        => axil_bresp,
      m_axil_bready       => axil_bready,
      m_axil_araddr       => axil_araddr,
      m_axil_arprot       => axil_arprot,
      m_axil_arvalid      => axil_arvalid,
      m_axil_arready      => axil_arready,
      m_axil_rdata        => axil_rdata,
      m_axil_rresp        => axil_rresp,
      m_axil_rvalid       => axil_rvalid,
      m_axil_rready       => axil_rready,
      s_axis_c2h_tdata_0  => axis_c2h_0_tdata,
      s_axis_c2h_tlast_0  => axis_c2h_0_tlast,
      s_axis_c2h_tvalid_0 => axis_c2h_0_tvalid,
      s_axis_c2h_tready_0 => axis_c2h_0_tready,
      s_axis_c2h_tkeep_0  => axis_c2h_0_tkeep,
      s_axis_c2h_tdata_1  => axis_c2h_1_tdata,
      s_axis_c2h_tlast_1  => axis_c2h_1_tlast,
      s_axis_c2h_tvalid_1 => axis_c2h_1_tvalid,
      s_axis_c2h_tready_1 => axis_c2h_1_tready,
      s_axis_c2h_tkeep_1  => axis_c2h_1_tkeep,
      m_axis_h2c_tdata_0  => axis_h2c_tdata,
      m_axis_h2c_tlast_0  => axis_h2c_tlast,
      m_axis_h2c_tvalid_0 => axis_h2c_tvalid,
      m_axis_h2c_tready_0 => axis_h2c_tready,
      m_axis_h2c_tkeep_0  => axis_h2c_tkeep,
      c2h_sts_0           => c2h_sts_0,
      h2c_sts_0           => h2c_sts_0,
      c2h_sts_1           => c2h_sts_1
    );

  axis_c2h_0_tkeep <= (others => '1');
  axis_c2h_1_tkeep <= (others => '1');
  axis_h2c_tstrb   <= (others => '1');

  msi_req <= "00";

  -- C2H Channel 0
  pn23_gen_c2h_0_inst : component pn23
    port map (
      clk   => axi_aclk,
      rstn  => axi_aresetn,
      hold  => pn23_c2h_0_hold,
      valid => pn23_c2h_0_valid,
      value => pn23_c2h_0_value
    );

  axis_c2h_0_inst : component axis_master
    generic map (
      c_m_axis_tdata_width => axis_data_width,
      register_width       => axil_data_width,
      c_m_start_count      => 16,
      fifo_depth           => 10
    )
    port map (
      fifo_status    => c2h_0_fifo_status,
      fifo_data_in   => pn23_c2h_0_value,
      fifo_wr_ena    => pn23_c2h_0_valid,
      fifo_full      => pn23_c2h_0_hold,
      packet_length  => c2h_chan_0_packet_len,
      m_axis_aclk    => axi_aclk,
      m_axis_aresetn => axi_aresetn,
      m_axis_tvalid  => axis_c2h_0_tvalid,
      m_axis_tdata   => axis_c2h_0_tdata,
      m_axis_tstrb   => axis_c2h_0_tstrb,
      m_axis_tlast   => axis_c2h_0_tlast,
      m_axis_tready  => axis_c2h_0_tready
    );

  -- C2H Channel 1
  pn23_gen_c2h_1_inst : component pn23
    port map (
      clk   => axi_aclk,
      rstn  => axi_aresetn,
      hold  => pn23_c2h_1_hold,
      valid => pn23_c2h_1_valid,
      value => pn23_c2h_1_value
    );

  axis_c2h_1_inst : component axis_master
    generic map (
      c_m_axis_tdata_width => axis_data_width,
      register_width       => axil_data_width,
      c_m_start_count      => 16,
      fifo_depth           => 10
    )
    port map (
      fifo_status    => c2h_1_fifo_status,
      fifo_data_in   => pn23_c2h_1_value,
      fifo_wr_ena    => pn23_c2h_1_valid,
      fifo_full      => pn23_c2h_1_hold,
      packet_length  => c2h_chan_1_packet_len,
      m_axis_aclk    => axi_aclk,
      m_axis_aresetn => axi_aresetn,
      m_axis_tvalid  => axis_c2h_1_tvalid,
      m_axis_tdata   => axis_c2h_1_tdata,
      m_axis_tstrb   => axis_c2h_1_tstrb,
      m_axis_tlast   => axis_c2h_1_tlast,
      m_axis_tready  => axis_c2h_1_tready
    );

  -- H2C Channel 0
  h2c_rd_ena <= '0';

  axis_h2c_inst : component axis_slave
    generic map (
      c_s_axis_tdata_width => axis_data_width,
      fifo_status_width    => axil_data_width,
      fifo_depth           => 10
    )
    port map (
      fifo_status    => h2c_0_fifo_status,
      fifo_data_out  => h2c_data_out,
      fifo_rd_ena    => h2c_rd_ena,
      fifo_empty     => h2c_empty,
      s_axis_aclk    => axi_aclk,
      s_axis_aresetn => axi_aresetn,
      s_axis_tvalid  => axis_h2c_tvalid,
      s_axis_tdata   => axis_h2c_tdata,
      s_axis_tstrb   => axis_h2c_tstrb,
      s_axis_tlast   => axis_h2c_tlast,
      s_axis_tready  => axis_h2c_tready
    );

  -- AXI Lite Interface
  pcie_bar_registers_inst : component registers
    generic map (
      data_width => axil_data_width,
      addr_width => axil_addr_width
    )
    port map (
      -- Control interface (AXI4-Lite) slave
      s_axil_aclk    => axi_aclk,
      s_axil_aresetn => axi_aresetn,
      s_axil_awaddr  => axil_awaddr(AXIL_ADDR_WIDTH - 1 downto 0),
      s_axil_awprot  => axil_awprot,
      s_axil_awvalid => axil_awvalid,
      s_axil_awready => axil_awready,
      s_axil_wdata   => axil_wdata,
      s_axil_wstrb   => axil_wstrb,
      s_axil_wvalid  => axil_wvalid,
      s_axil_wready  => axil_wready,
      s_axil_bresp   => axil_bresp,
      s_axil_bvalid  => axil_bvalid,
      s_axil_bready  => axil_bready,
      s_axil_araddr  => axil_araddr(AXIL_ADDR_WIDTH - 1 downto 0),
      s_axil_arprot  => axil_arprot,
      s_axil_arvalid => axil_arvalid,
      s_axil_arready => axil_arready,
      s_axil_rdata   => axil_rdata,
      s_axil_rresp   => axil_rresp,
      s_axil_rvalid  => axil_rvalid,
      s_axil_rready  => axil_rready,

      c2h_0_fifo_status_reg => c2h_0_fifo_status,
      c2h_1_fifo_status_reg => c2h_1_fifo_status,
      h2c_0_fifo_status_reg => h2c_0_fifo_status,

      c2h_chan_0_packet_len => c2h_chan_0_packet_len,
      c2h_chan_1_packet_len => c2h_chan_1_packet_len,

      msi_ena   => msi_ena,
      msi_count => msi_count,
      c2h_sts_0   => c2h_sts_0,
      c2h_sts_1   => c2h_sts_1,
      h2c_sts_0   => h2c_sts_0,

      uptime_counter => uptime_counter,
      user_counter   => user_counter,

      build_ver => build_ver,
      build_id  => build_id
    );

  uptime_counter_inst : component counter
    generic map (
      data_width => 2 * axil_data_width
    )
    port map (
      clk   => axi_aclk,
      rstn  => sys_rst_n,
      value => uptime_counter
    );

  user_counter_inst : component counter
    generic map (
      data_width => axil_data_width
    )
    port map (
      clk   => axi_aclk,
      rstn  => sys_rst_n,
      value => user_counter
    );

  build_info_inst : component build_info
    port map (
      build_ver => build_ver,
      build_id  => build_id
    );

  -- Hardware
  led1_blink : component blink
    generic map (
      clk_freq_hz   => 250000000,
      blink_freq_hz => 1
    )
    port map (
      clk  => axi_aclk,
      rstn => sys_rst_n,
      led  => led1
    );

  led2            <= expand_port_in;
  expand_port_out <= '1';

end architecture rtl;
