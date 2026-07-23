
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.utils_param.all;

-- ------------------------------------------------------------------------------------------
-- Entity 
-- ------------------------------------------------------------------------------------------
entity top is
generic
(
  AXIL_DATA_WIDTH : integer := 32;
  AXIL_ADDR_WIDTH : integer := 8;
  AXIS_DATA_WIDTH : integer := 64;
  PCIE_LANES : integer := 4
);
port 
(
  -- ---------------------------------------------------
  -- Clock
  -- ---------------------------------------------------  

  -- 200MHz clock
  clk200_p                             : in  std_logic;
  clk200_n                             : in  std_logic;

  -- 100MHz clock
  sys_clk_p                            : in  std_logic;
  sys_clk_n                            : in  std_logic;

  -- ---------------------------------------------------
  -- Reset
  -- --------------------------------------------------- 

  sys_rst_n                            : in  std_logic;

  -- ---------------------------------------------------
  -- Debug
  -- --------------------------------------------------- 
  Led                                  : out std_logic;
  
  -- ---------------------------------------------------
  -- PCIe
  -- ---------------------------------------------------   

  -- TX
  pcie_tx_p                            : out std_logic_vector(PCIE_LANES-1 downto 0);
  pcie_tx_n                            : out std_logic_vector(PCIE_LANES-1 downto 0);
  
  -- RX
  pcie_rx_p                            : in  std_logic_vector(PCIE_LANES-1 downto 0);
  pcie_rx_n                            : in  std_logic_vector(PCIE_LANES-1 downto 0)
);
end entity top;

-- ------------------------------------------------------------------------------------------
-- Architecture 
-- ------------------------------------------------------------------------------------------
architecture rtl of top is

signal clk200_out : std_logic;
signal sys_clk : std_logic;
signal sys_clk_gt : std_logic;

signal axi_aclk : std_logic;
signal axi_aresetn : std_logic;

signal aclk_double : std_logic;

signal pcie_link_status : std_logic;
signal msi_req : std_logic;
signal msi_ack : std_logic;

signal pn23_value : std_logic_vector( AXIS_DATA_WIDTH - 1 downto 0 );
signal pn23_ready : std_logic;

-- AXI Lite register values
signal uptime_counter : std_logic_vector ( (AXIL_DATA_WIDTH * 2) - 1 downto 0);
signal user_counter : std_logic_vector ( AXIL_DATA_WIDTH - 1 downto 0);

signal fifo_status : std_logic_vector ( AXIL_DATA_WIDTH - 1 downto 0);

signal msi_ena : std_logic;
signal msi_count : std_logic_vector(2 downto 0);
signal c2h_sts : std_logic_vector(7 downto 0);
signal h2c_sts : std_logic_vector(7 downto 0);

-- AXI Stream Card to Host
signal axis_c2h_tdata : std_logic_vector( AXIS_DATA_WIDTH - 1 downto 0 );
signal axis_c2h_tstrb : std_logic_vector((AXIS_DATA_WIDTH / 8) - 1 downto 0);
signal axis_c2h_tlast : std_logic;
signal axis_c2h_tvalid : std_logic;
signal axis_c2h_tready : std_logic;
signal axis_c2h_tkeep : std_logic_vector( (AXIS_DATA_WIDTH / 8) - 1 downto 0 );

-- AXI Stream Host to Card
signal axis_h2c_tdata : std_logic_vector( AXIS_DATA_WIDTH - 1 downto 0 );
signal axis_h2c_tstrb : std_logic_vector((AXIS_DATA_WIDTH / 8) - 1 downto 0);
signal axis_h2c_tlast : std_logic;
signal axis_h2c_tvalid : std_logic;
signal axis_h2c_tready : std_logic;
signal axis_h2c_tkeep : std_logic_vector( (AXIS_DATA_WIDTH / 8) - 1 downto 0 );

-- AXI Lite Bar space
signal axil_awaddr  : std_logic_vector(AXIL_ADDR_WIDTH - 1 downto 0);
signal axil_awprot  : std_logic_vector(2 downto 0);
signal axil_awvalid : std_logic;
signal axil_awready : std_logic;
signal axil_wdata   : std_logic_vector(AXIL_DATA_WIDTH - 1 downto 0);
signal axil_wstrb   : std_logic_vector((AXIL_DATA_WIDTH / 8) - 1 downto 0);
signal axil_wvalid  : std_logic;
signal axil_wready  : std_logic;
signal axil_bvalid  : std_logic;
signal axil_bresp   : std_logic_vector(1 downto 0);
signal axil_bready  : std_logic;
signal axil_araddr  : std_logic_vector(AXIL_ADDR_WIDTH - 1 downto 0);
signal axil_arprot  : std_logic_vector(2 downto 0);
signal axil_arvalid : std_logic;
signal axil_arready : std_logic;
signal axil_rdata   : std_logic_vector(AXIL_DATA_WIDTH - 1 downto 0);
signal axil_rresp   : std_logic_vector(1 downto 0);
signal axil_rvalid  : std_logic;
signal axil_rready  : std_logic;

begin

  Led <= pcie_link_status;

  IBUFDS_INST : IBUFDS
  generic map
  (
    DIFF_TERM                          => false,
    IOSTANDARD                         => "DEFAULT"
  )
  port map 
  (
    O                                  => clk200_out,
    I                                  => clk200_p,
    IB                                 => clk200_n
  );

  IBUFDS_GTE4_INST : IBUFDS_GTE4
  generic map 
  (
    REFCLK_EN_TX_PATH                  => '0',
    REFCLK_HROW_CK_SEL                 => "00",
    REFCLK_ICNTL_RX                    => "00"
  )
  port map 
  (
    O                                  => sys_clk_gt,
    ODIV2                              => sys_clk,
    CEB                                => '0',
    I                                  => sys_clk_p,
    IB                                 => sys_clk_n
  );

pcie_dma_inst : xdma_0
  port map ( 
    sys_clk => sys_clk,
    sys_clk_gt => sys_clk_gt,
    sys_rst_n => sys_rst_n,
    user_lnk_up => pcie_link_status,
    pci_exp_txp => pcie_tx_p,
    pci_exp_txn => pcie_tx_n,
    pci_exp_rxp => pcie_rx_p,
    pci_exp_rxn => pcie_rx_n,
    axi_aclk => axi_aclk,
    axi_aresetn => axi_aresetn,
    usr_irq_req => msi_req,
    usr_irq_ack => msi_ack,
    msi_enable => msi_ena,
    msi_vector_width => msi_count,
    m_axil_awaddr => axil_awaddr,
    m_axil_awprot => axil_awprot,
    m_axil_awvalid => axil_awvalid,
    m_axil_awready => axil_awready,
    m_axil_wdata => axil_wdata,
    m_axil_wstrb => axil_wstrb,
    m_axil_wvalid => axil_wvalid,
    m_axil_wready => axil_wready,
    m_axil_bvalid => axil_bvalid,
    m_axil_bresp => axil_bresp,
    m_axil_bready => axil_bready,
    m_axil_araddr => axil_araddr,
    m_axil_arprot => axil_arprot,
    m_axil_arvalid => axil_arvalid,
    m_axil_arready => axil_arready,
    m_axil_rdata => axil_rdata,
    m_axil_rresp => axil_rresp,
    m_axil_rvalid => axil_rvalid,
    m_axil_rready => axil_rready,
    s_axis_c2h_tdata_0 => axis_c2h_tdata,
    s_axis_c2h_tlast_0 => axis_c2h_tlast,
    s_axis_c2h_tvalid_0 => axis_c2h_tvalid,
    s_axis_c2h_tready_0 => axis_c2h_tready,
    s_axis_c2h_tkeep_0 => axis_c2h_tkeep,
    s_axis_h2c_tdata_0 => axis_h2c_tdata,
    s_axis_h2c_tlast_0 => axis_h2c_tlast,
    s_axis_h2c_tvalid_0 => axis_h2c_tvalid,
    s_axis_h2c_tready_0 => axis_h2c_tready,
    s_axis_h2c_tkeep_0 => axis_h2c_tkeep,
    c2h_sts_0 => c2h_sts,
    h2c_sts_0 => h2c_sts
    );

   pn23_gen_comp: pn23 generic map (
    data_width => AXIS_DATA_WIDTH
  )
   port map (
        clk => axi_aclk,
        rstn => axi_aresetn,
        value => pn23_value,
        ready => pn23_ready
    );

    axis_c2h_inst : axis_master
    generic map (
        c_m_axis_tdata_width => AXIS_DATA_WIDTH,
        fifo_status_width => AXIL_DATA_WIDTH,
        C_M_START_COUNT => 16,
        FIFO_DEPTH => 5
    )
    port map (
        FIFO_STATUS => fifo_status,
        FIFO_DATA_IN => pn23_value,
        FIFO_WR_ENA => pn23_ready,
        M_AXIS_ACLK => axi_aclk,
        M_AXIS_ARESETN => axi_aresetn,
        M_AXIS_TVALID => axis_c2h_tvalid,
        M_AXIS_TDATA => axis_c2h_tdata,
        M_AXIS_TSTRB => axis_c2h_tstrb,
        M_AXIS_TLAST => axis_c2h_tlast,
        M_AXIS_TREADY => axis_c2h_tready
    );


  pcie_bar_registers_inst : registers
  generic map (
    data_width => AXIL_DATA_WIDTH,
    addr_width => AXIL_ADDR_WIDTH
  )
  port map (
    -- Control interface (AXI4-Lite) slave
    s_axil_aclk    => axi_aclk,
    s_axil_aresetn => axi_aresetn,
    s_axil_awaddr  => axil_awaddr,
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
    s_axil_araddr  => axil_araddr,
    s_axil_arprot  => axil_arprot,
    s_axil_arvalid => axil_arvalid,
    s_axil_arready => axil_arready,
    s_axil_rdata   => axil_rdata,
    s_axil_rresp   => axil_rresp,
    s_axil_rvalid  => axil_rvalid,
    s_axil_rready  => axil_rready,

    -- User registers
    fifo_status_reg => fifo_status,
    
    msi_ena => msi_ena,
    msi_count => msi_count,
    c2h_sts => c2h_sts,
    h2c_sts => h2c_sts,

    uptime_counter  => uptime_counter,
    user_counter    => user_counter
  );
  
  uptime_counter_inst : counter
  generic map (
    data_width => 2 * AXIL_DATA_WIDTH
  )
  port map (
    clk   => clk200_out,
    rstn  => sys_rst_n,
    value => uptime_counter
  );

  user_counter_inst : counter
  generic map (
    data_width => 2 * AXIL_DATA_WIDTH
  )
  port map (
    clk   => clk200_out,
    rstn  => sys_rst_n,
    value => user_counter
  );

end rtl;
