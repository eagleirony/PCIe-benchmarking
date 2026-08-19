library ieee;
  use ieee.math_real.all;
  use ieee.std_logic_1164.all;

package utils_param is

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
    usr_irq_req : in STD_LOGIC_VECTOR ( 0 to 0 );
    usr_irq_ack : out STD_LOGIC_VECTOR ( 0 to 0 );
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
    m_axis_h2c_tdata_0 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_h2c_tlast_0 : out STD_LOGIC;
    m_axis_h2c_tvalid_0 : out STD_LOGIC;
    m_axis_h2c_tready_0 : in STD_LOGIC;
    m_axis_h2c_tkeep_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    c2h_sts_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    h2c_sts_0 : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component xdma_0;

  component fifo is
    generic (
      data_width : positive := 32;
      status_width : positive := 32;
      fifo_depth : positive := 5
    );
    port (
      clk    : in    std_logic;
      rstn   : in    std_logic;
      wr     : in    std_logic;
      rd     : in    std_logic;
      din    : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      empty  : out   std_logic;
      full   : out   std_logic;
      dout   : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
      status : out   std_logic_vector(status_width - 1 downto 0)
    );
  end component fifo;

  component pn23 is
    generic (
      data_width : positive := 64
    );
    port (
      clk   : in    std_logic;
      rstn  : in    std_logic;
      hold  : in    std_logic;
      valid : out   std_logic;
      value : out   std_logic_vector(63 downto 0)
    );
  end component pn23;

  component axis_slave is
    generic (
      C_S_AXIS_TDATA_WIDTH  : integer  := 32;
      fifo_status_width : integer := 32;
      fifo_depth : integer := 14
    );
    port (
      fifo_status  : out   std_logic_vector(fifo_status_width - 1 downto 0);
      fifo_data_out: out   std_logic_vector(c_s_axis_tdata_width - 1 downto 0);
      fifo_rd_ena  : in    std_logic;
      fifo_empty   : out   std_logic;

      S_AXIS_ACLK  : in std_logic;
      S_AXIS_ARESETN  : in std_logic;
      S_AXIS_TREADY  : out std_logic;
      S_AXIS_TDATA  : in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
      S_AXIS_TSTRB  : in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
      S_AXIS_TLAST  : in std_logic;
      S_AXIS_TVALID  : in std_logic
    );
  end component;

  component axis_master is
    generic (
      c_m_axis_tdata_width : integer  := 64;
      register_width : integer := 32;
      c_m_start_count : integer  := 32;
      fifo_depth : integer := 14
    );
    port (
      fifo_status  : out   std_logic_vector(register_width - 1 downto 0);
      fifo_data_in : in    std_logic_vector(c_m_axis_tdata_width - 1 downto 0);
      fifo_wr_ena  : in    std_logic;
      fifo_full    : out   std_logic;

      packet_length : in  std_logic_vector(register_width - 1 downto 0);

      m_axis_aclk : in    std_logic;
      m_axis_aresetn : in    std_logic;
      m_axis_tvalid : out   std_logic;
      m_axis_tdata : out   std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
      m_axis_tstrb : out   std_logic_vector((C_M_AXIS_TDATA_WIDTH / 8) - 1 downto 0);
      m_axis_tlast : out   std_logic;
      m_axis_tready : in    std_logic
    );
  end component axis_master;

  component counter is
  generic (
    data_width : positive := 32
  );
  port (
    clk   : in    std_logic;
    rstn  : in    std_logic;
    value : out   std_logic_vector(data_width - 1 downto 0)
  );
  end component counter;

  component axil_bus is
  generic (
    c_s_axi_data_width : integer := 32;
    c_s_axi_addr_width : integer := 8
  );
  port (
    -- Read ports
    reg_0_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_1_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_2_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_3_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_4_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_5_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_6_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_7_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_8_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_9_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_10_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_11_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_12_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_13_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_14_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_15_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_16_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_17_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_18_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_19_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_20_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_21_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_22_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_23_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_24_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_25_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_26_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_27_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_28_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_29_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_30_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_31_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_32_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_33_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_34_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_35_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_36_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_37_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_38_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_39_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_40_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_41_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_42_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_43_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_44_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_45_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_46_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_47_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_48_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_49_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_50_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_51_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_52_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_53_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_54_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_55_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_56_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_57_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_58_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_59_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_60_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_61_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_62_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_63_r : in std_logic_vector(c_s_axi_data_width - 1 downto 0);

    -- Write ports
    reg_0_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_1_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_2_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_3_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_4_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_5_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_6_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_7_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_8_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_9_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_10_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_11_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_12_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_13_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_14_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_15_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_16_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_17_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_18_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_19_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_20_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_21_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_22_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_23_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_24_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_25_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_26_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_27_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_28_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_29_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_30_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_31_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_32_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_33_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_34_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_35_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_36_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_37_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_38_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_39_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_40_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_41_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_42_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_43_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_44_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_45_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_46_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_47_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_48_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_49_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_50_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_51_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_52_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_53_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_54_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_55_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_56_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_57_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_58_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_59_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_60_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_61_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_62_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);
    reg_63_w : out std_logic_vector(c_s_axi_data_width - 1 downto 0);

    s_axi_aclk : in    std_logic;
    s_axi_aresetn : in    std_logic;
    s_axi_awaddr : in    std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    s_axi_awprot : in    std_logic_vector(2 downto 0);
    s_axi_awvalid : in    std_logic;
    s_axi_awready : out   std_logic;
    s_axi_wdata : in    std_logic_vector(c_s_axi_data_width - 1 downto 0);
    s_axi_wstrb : in    std_logic_vector((c_s_axi_data_width / 8) - 1 downto 0);
    s_axi_wvalid : in    std_logic;
    s_axi_wready : out   std_logic;
    s_axi_bresp : out   std_logic_vector(1 downto 0);
    s_axi_bvalid : out   std_logic;
    s_axi_bready : in    std_logic;
    s_axi_araddr : in    std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    s_axi_arprot : in    std_logic_vector(2 downto 0);
    s_axi_arvalid : in    std_logic;
    s_axi_arready : out   std_logic;
    s_axi_rdata : out   std_logic_vector(c_s_axi_data_width - 1 downto 0);
    s_axi_rresp : out   std_logic_vector(1 downto 0);
    s_axi_rvalid : out   std_logic;
    s_axi_rready : in    std_logic
  );
  end component axil_bus;

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
    h2c_fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);
    c2h_fifo_status_reg : in    std_logic_vector(data_width - 1 downto 0);

    c2h_chan_0_packet_len : out std_logic_vector(data_width - 1 downto 0);

    msi_ena : in std_logic;
    msi_count : in std_logic_vector(2 downto 0);
    c2h_sts : in std_logic_vector(7 downto 0);
    h2c_sts : in std_logic_vector(7 downto 0);

    uptime_counter  : in    std_logic_vector((data_width * 2) - 1 downto 0);
    user_counter    : in    std_logic_vector(data_width - 1 downto 0)
  );
  end component registers;

end package utils_param;

package body utils_param is

end package body utils_param;
