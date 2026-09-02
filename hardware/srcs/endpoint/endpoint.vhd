library ieee;
  use ieee.math_real.all;
  use ieee.std_logic_1164.all;

package endpoint_param is

  component registers is
  generic (
    data_width : integer := 32;
    addr_width : integer := 8
  );
  port (
    -- Control interface (AXI4-Lite) slave
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
    c2h_0_fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);
    c2h_1_fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);
    h2c_0_fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);

    c2h_chan_0_packet_len : out std_logic_vector(data_width - 1 downto 0);
    c2h_chan_1_packet_len : out std_logic_vector(data_width - 1 downto 0);

    msi_ena : in std_logic;
    msi_count : in std_logic_vector(2 downto 0);
    c2h_sts_0 : in std_logic_vector(7 downto 0);
    c2h_sts_1 : in std_logic_vector(7 downto 0);
    h2c_sts_0 : in std_logic_vector(7 downto 0);

    uptime_counter  : in    std_logic_vector((data_width * 2) - 1 downto 0);
    user_counter    : in    std_logic_vector(data_width - 1 downto 0);

    build_ver : in std_logic_vector(data_width - 1 downto 0);
    build_id : in std_logic_vector(data_width - 1 downto 0)
  );
  end component registers;
  
  component xdma_0 is
  Port ( 
    sys_clk : in STD_LOGIC;
    sys_clk_gt : in STD_LOGIC;
    sys_rst_n : in STD_LOGIC;
    user_lnk_up : out STD_LOGIC;
    pci_exp_txp : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pci_exp_txn : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pci_exp_rxp : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pci_exp_rxn : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi_aclk : out STD_LOGIC;
    axi_aresetn : out STD_LOGIC;
    usr_irq_req : in STD_LOGIC_VECTOR ( 1 downto 0 );
    usr_irq_ack : out STD_LOGIC_VECTOR ( 1 downto 0 );
    msi_enable : out STD_LOGIC;
    msi_vector_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_awvalid : out STD_LOGIC;
    m_axil_awready : in STD_LOGIC;
    m_axil_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axil_wvalid : out STD_LOGIC;
    m_axil_wready : in STD_LOGIC;
    m_axil_bvalid : in STD_LOGIC;
    m_axil_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axil_bready : out STD_LOGIC;
    m_axil_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_arvalid : out STD_LOGIC;
    m_axil_arready : in STD_LOGIC;
    m_axil_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axil_rvalid : in STD_LOGIC;
    m_axil_rready : out STD_LOGIC;
    s_axis_c2h_tdata_0 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_c2h_tlast_0 : in STD_LOGIC;
    s_axis_c2h_tvalid_0 : in STD_LOGIC;
    s_axis_c2h_tready_0 : out STD_LOGIC;
    s_axis_c2h_tkeep_0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_c2h_tdata_1 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_c2h_tlast_1 : in STD_LOGIC;
    s_axis_c2h_tvalid_1 : in STD_LOGIC;
    s_axis_c2h_tready_1 : out STD_LOGIC;
    s_axis_c2h_tkeep_1 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_h2c_tdata_0 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_h2c_tlast_0 : out STD_LOGIC;
    m_axis_h2c_tvalid_0 : out STD_LOGIC;
    m_axis_h2c_tready_0 : in STD_LOGIC;
    m_axis_h2c_tkeep_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    c2h_sts_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    h2c_sts_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    c2h_sts_1 : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component xdma_0;

end package endpoint_param;

package body endpoint_param is

end package body endpoint_param;
