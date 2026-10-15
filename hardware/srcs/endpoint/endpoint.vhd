library ieee;
  use ieee.math_real.all;
  use ieee.std_logic_1164.all;

package endpoint_param is

  component registers is
    generic (
      DATA_WIDTH : integer := 32;
      ADDR_WIDTH : integer := 8
    );
    port (
      -- Control interface (AXI4-Lite) slave
      s_axil_aclk    : in    std_logic;
      s_axil_aresetn : in    std_logic;
      s_axil_awaddr  : in    std_logic_vector(ADDR_WIDTH - 1 downto 0);
      s_axil_awprot  : in    std_logic_vector(2 downto 0);
      s_axil_awvalid : in    std_logic;
      s_axil_awready : out   std_logic;
      s_axil_wdata   : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      s_axil_wstrb   : in    std_logic_vector((DATA_WIDTH / 8) - 1 downto 0);
      s_axil_wvalid  : in    std_logic;
      s_axil_wready  : out   std_logic;
      s_axil_bresp   : out   std_logic_vector(1 downto 0);
      s_axil_bvalid  : out   std_logic;
      s_axil_bready  : in    std_logic;
      s_axil_araddr  : in    std_logic_vector(ADDR_WIDTH - 1 downto 0);
      s_axil_arprot  : in    std_logic_vector(2 downto 0);
      s_axil_arvalid : in    std_logic;
      s_axil_arready : out   std_logic;
      s_axil_rdata   : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
      s_axil_rresp   : out   std_logic_vector(1 downto 0);
      s_axil_rvalid  : out   std_logic;
      s_axil_rready  : in    std_logic;

      -- User registers
      c2h_0_fifo_status_reg : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      c2h_1_fifo_status_reg : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      h2c_0_fifo_status_reg : in    std_logic_vector(DATA_WIDTH - 1 downto 0);

      c2h_0_pn23_rate_reg : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
      c2h_1_pn23_rate_reg : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
      h2c_0_pn23_rate_reg : out   std_logic_vector(DATA_WIDTH - 1 downto 0);

      c2h_chan_0_packet_len : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
      c2h_chan_1_packet_len : out   std_logic_vector(DATA_WIDTH - 1 downto 0);

      msi_ena   : in    std_logic;
      msi_count : in    std_logic_vector(2 downto 0);
      c2h_sts_0 : in    std_logic_vector(7 downto 0);
      c2h_sts_1 : in    std_logic_vector(7 downto 0);
      h2c_sts_0 : in    std_logic_vector(7 downto 0);

      uptime_counter : in    std_logic_vector((DATA_WIDTH * 2) - 1 downto 0);
      user_counter   : in    std_logic_vector(DATA_WIDTH - 1 downto 0);

      build_ver : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      build_id  : in    std_logic_vector(DATA_WIDTH - 1 downto 0);

      wire_out        : out   std_logic;
      stop_user_clock : out   std_logic;
      irq_ack         : out   std_logic;

      validate_error   : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      validate_correct : in    std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component registers;

  component xdma_0 is
    port (
      sys_clk             : in    std_logic;
      sys_clk_gt          : in    std_logic;
      sys_rst_n           : in    std_logic;
      user_lnk_up         : out   std_logic;
      pci_exp_txp         : out   std_logic_vector( 3 downto 0);
      pci_exp_txn         : out   std_logic_vector( 3 downto 0);
      pci_exp_rxp         : in    std_logic_vector( 3 downto 0);
      pci_exp_rxn         : in    std_logic_vector( 3 downto 0);
      axi_aclk            : out   std_logic;
      axi_aresetn         : out   std_logic;
      usr_irq_req         : in    std_logic_vector( 1 downto 0);
      usr_irq_ack         : out   std_logic_vector( 1 downto 0);
      msi_enable          : out   std_logic;
      msi_vector_width    : out   std_logic_vector( 2 downto 0);
      m_axil_awaddr       : out   std_logic_vector( 31 downto 0);
      m_axil_awprot       : out   std_logic_vector( 2 downto 0);
      m_axil_awvalid      : out   std_logic;
      m_axil_awready      : in    std_logic;
      m_axil_wdata        : out   std_logic_vector( 31 downto 0);
      m_axil_wstrb        : out   std_logic_vector( 3 downto 0);
      m_axil_wvalid       : out   std_logic;
      m_axil_wready       : in    std_logic;
      m_axil_bvalid       : in    std_logic;
      m_axil_bresp        : in    std_logic_vector( 1 downto 0);
      m_axil_bready       : out   std_logic;
      m_axil_araddr       : out   std_logic_vector( 31 downto 0);
      m_axil_arprot       : out   std_logic_vector( 2 downto 0);
      m_axil_arvalid      : out   std_logic;
      m_axil_arready      : in    std_logic;
      m_axil_rdata        : in    std_logic_vector( 31 downto 0);
      m_axil_rresp        : in    std_logic_vector( 1 downto 0);
      m_axil_rvalid       : in    std_logic;
      m_axil_rready       : out   std_logic;
      s_axis_c2h_tdata_0  : in    std_logic_vector( 63 downto 0);
      s_axis_c2h_tlast_0  : in    std_logic;
      s_axis_c2h_tvalid_0 : in    std_logic;
      s_axis_c2h_tready_0 : out   std_logic;
      s_axis_c2h_tkeep_0  : in    std_logic_vector( 7 downto 0);
      s_axis_c2h_tdata_1  : in    std_logic_vector( 63 downto 0);
      s_axis_c2h_tlast_1  : in    std_logic;
      s_axis_c2h_tvalid_1 : in    std_logic;
      s_axis_c2h_tready_1 : out   std_logic;
      s_axis_c2h_tkeep_1  : in    std_logic_vector( 7 downto 0);
      m_axis_h2c_tdata_0  : out   std_logic_vector( 63 downto 0);
      m_axis_h2c_tlast_0  : out   std_logic;
      m_axis_h2c_tvalid_0 : out   std_logic;
      m_axis_h2c_tready_0 : in    std_logic;
      m_axis_h2c_tkeep_0  : out   std_logic_vector( 7 downto 0);
      c2h_sts_0           : out   std_logic_vector( 7 downto 0);
      h2c_sts_0           : out   std_logic_vector( 7 downto 0);
      c2h_sts_1           : out   std_logic_vector( 7 downto 0)
    );
  end component xdma_0;

  component msi_handler is
    port (
      clk     : in    std_logic;
      rstn    : in    std_logic;
      ack     : in    std_logic;
      req_in  : in    std_logic;
      req_out : out   std_logic
    );
  end component msi_handler;

end package endpoint_param;

package body endpoint_param is

end package body endpoint_param;
