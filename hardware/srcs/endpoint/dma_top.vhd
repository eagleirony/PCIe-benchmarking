-- ------------------------------------------------------------------------------------------
--
-- Filename     : dma_top.vhd
-- HDL-Standard : VHDL-93
-- Version      : 1.0
-- Formatted    : Notepad++
-- Description  : DMA top level                        
--                BAR0 (32-bit) - PCIe to AXI Lite Master
--                BAR1 (32-bit) - DMA
--
-- ------------------------------------------------------------------------------------------
--
-- Structure    : dma_top  
--                   |
--                   +-- PCIE_DMA_INST (pcie_dma)           
--
-- ------------------------------------------------------------------------------------------
--
-- History      : 1.0
--
-- ------------------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

-- ------------------------------------------------------------------------------------------
-- Entity 
-- ------------------------------------------------------------------------------------------
entity dma_top is
generic 
(
  -- PCIe link data width
  -- The Xilinx core must be re-generated if this parameter is changed
  C_PCIE_DWIDTH                        : integer := 4;
  
  -- AXI Lite Master address width
  -- The Xilinx core must be re-generated if this parameter is changed
  C_AXI_LM_AWIDTH                      : integer := 64;
  
  -- AXI Lite Master data path width
  -- The Xilinx core must be re-generated if this parameter is changed
  C_AXI_LM_DWIDTH                      : integer := 64;
  
  -- AXI Stream data path width
  -- The Xilinx core must be re-generated if this parameter is changed
  C_AXI_ST_DWIDTH                      : integer := 64;
  
  -- Number of user interrupts
  -- The Xilinx core must be re-generated if this parameter is changed
  C_NUM_INT                            : integer := 1
);
port 
(
  -- ---------------------------------------------------
  -- Clock
  -- ---------------------------------------------------  

  -- 100MHz clock
  Sys_clk                              : in  std_logic;
  
  -- 100MHz clock
  Sys_clk_gt                           : in  std_logic;

  -- 125MHz clock
  Axi_aclk                             : out std_logic;

  -- ---------------------------------------------------
  -- Reset
  -- --------------------------------------------------- 

  -- Active low reset
  Sys_rst_n                            : in  std_logic;
    
  -- Active low reset
  Axi_aresetn                          : out std_logic;
 
  -- ---------------------------------------------------
  -- PCIe
  -- ---------------------------------------------------  
 
  -- TX
  Pcie_tx_p                            : out unsigned(C_PCIE_DWIDTH-1 downto 0);
  Pcie_tx_n                            : out unsigned(C_PCIE_DWIDTH-1 downto 0);
  
  -- RX
  Pcie_rx_p                            : in  unsigned(C_PCIE_DWIDTH-1 downto 0);
  Pcie_rx_n                            : in  unsigned(C_PCIE_DWIDTH-1 downto 0);
  
  -- Link status  
  User_lnk_up                          : out std_logic;
);
end entity dma_top;

-- ------------------------------------------------------------------------------------------
-- Architecture 
-- ------------------------------------------------------------------------------------------
architecture rtl of dma_top is

-- -----------------------------------------------------------------------------
-- Components
-- -----------------------------------------------------------------------------
component pcie_dma
port 
(
  sys_clk                              : in  std_logic;
  sys_clk_gt                           : in  std_logic;
  sys_rst_n                            : in  std_logic;
  user_lnk_up                          : out std_logic;
  pci_exp_txp                          : out std_logic_vector(3 downto 0);
  pci_exp_txn                          : out std_logic_vector(3 downto 0);
  pci_exp_rxp                          : in  std_logic_vector(3 downto 0);
  pci_exp_rxn                          : in  std_logic_vector(3 downto 0);
  axi_aclk                             : out std_logic;
  axi_aresetn                          : out std_logic;
  usr_irq_req                          : in  std_logic_vector(7 downto 0);
  usr_irq_ack                          : out std_logic_vector(7 downto 0);
  msi_enable                           : out std_logic;
  msi_vector_width                     : out std_logic_vector(2 downto 0);
  m_axil_awaddr                        : out std_logic_vector(31 downto 0);
  m_axil_awprot                        : out std_logic_vector(2 downto 0);
  m_axil_awvalid                       : out std_logic;
  m_axil_awready                       : in  std_logic;
  m_axil_wdata                         : out std_logic_vector(31 downto 0);
  m_axil_wstrb                         : out std_logic_vector(3 downto 0);
  m_axil_wvalid                        : out std_logic;
  m_axil_wready                        : in  std_logic;
  m_axil_bvalid                        : in  std_logic;
  m_axil_bresp                         : in  std_logic_vector(1 downto 0);
  m_axil_bready                        : out std_logic;
  m_axil_araddr                        : out std_logic_vector(31 downto 0);
  m_axil_arprot                        : out std_logic_vector(2 downto 0);
  m_axil_arvalid                       : out std_logic;
  m_axil_arready                       : in  std_logic;
  m_axil_rdata                         : in  std_logic_vector(31 downto 0);
  m_axil_rresp                         : in  std_logic_vector(1 downto 0);
  m_axil_rvalid                        : in  std_logic;
  m_axil_rready                        : out std_logic;
  cfg_mgmt_addr                        : in  std_logic_vector(18 downto 0);
  cfg_mgmt_write                       : in  std_logic;
  cfg_mgmt_write_data                  : in  std_logic_vector(31 downto 0);
  cfg_mgmt_byte_enable                 : in  std_logic_vector(3 downto 0);
  cfg_mgmt_read                        : in  std_logic;
  cfg_mgmt_read_data                   : out std_logic_vector(31 downto 0);
  cfg_mgmt_read_write_done             : out std_logic;
  s_axis_c2h_tdata_0                   : in  std_logic_vector(127 downto 0);
  s_axis_c2h_tlast_0                   : in  std_logic;
  s_axis_c2h_tvalid_0                  : in  std_logic;
  s_axis_c2h_tready_0                  : out std_logic;
  s_axis_c2h_tkeep_0                   : in  std_logic_vector(15 downto 0);
  m_axis_h2c_tdata_0                   : out std_logic_vector(127 downto 0);
  m_axis_h2c_tlast_0                   : out std_logic;
  m_axis_h2c_tvalid_0                  : out std_logic;
  m_axis_h2c_tready_0                  : in  std_logic;
  m_axis_h2c_tkeep_0                   : out std_logic_vector(15 downto 0);
  s_axil_awaddr                        : in  std_logic_vector(31 downto 0);
  s_axil_awprot                        : in  std_logic_vector(2 downto 0);
  s_axil_awvalid                       : in  std_logic;
  s_axil_awready                       : out std_logic;
  s_axil_wdata                         : in  std_logic_vector(31 downto 0);
  s_axil_wstrb                         : in  std_logic_vector(3 downto 0);
  s_axil_wvalid                        : in  std_logic;
  s_axil_wready                        : out std_logic;
  s_axil_bvalid                        : out std_logic;
  s_axil_bresp                         : out std_logic_vector(1 downto 0);
  s_axil_bready                        : in  std_logic;
  s_axil_araddr                        : in  std_logic_vector(31 downto 0);
  s_axil_arprot                        : in  std_logic_vector(2 downto 0);
  s_axil_arvalid                       : in  std_logic;
  s_axil_arready                       : out std_logic;
  s_axil_rdata                         : out std_logic_vector(31 downto 0);
  s_axil_rresp                         : out std_logic_vector(1 downto 0);
  s_axil_rvalid                        : out std_logic;
  s_axil_rready                        : in  std_logic;
  c2h_dsc_byp_ready_0                  : out std_logic;
  c2h_dsc_byp_src_addr_0               : in  std_logic_vector(63 downto 0);
  c2h_dsc_byp_dst_addr_0               : in  std_logic_vector(63 downto 0);
  c2h_dsc_byp_len_0                    : in  std_logic_vector(27 downto 0);
  c2h_dsc_byp_ctl_0                    : in  std_logic_vector(15 downto 0);
  c2h_dsc_byp_load_0                   : in  std_logic;
  h2c_dsc_byp_ready_0                  : out std_logic;
  h2c_dsc_byp_src_addr_0               : in  std_logic_vector(63 downto 0);
  h2c_dsc_byp_dst_addr_0               : in  std_logic_vector(63 downto 0);
  h2c_dsc_byp_len_0                    : in  std_logic_vector(27 downto 0);
  h2c_dsc_byp_ctl_0                    : in  std_logic_vector(15 downto 0);
  h2c_dsc_byp_load_0                   : in  std_logic
);
end component;

-- -----------------------------------------------------------------------------
-- Functions
-- -----------------------------------------------------------------------------
-- N/A
  
-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------
-- N/A
   
-- -----------------------------------------------------------------------------
-- Types
-- -----------------------------------------------------------------------------
-- N/A
                   
-- -----------------------------------------------------------------------------
-- Signals
-- -----------------------------------------------------------------------------
-- PCIe - TX
signal pci_exp_tx_p_slv               : std_logic_vector(C_PCIE_DWIDTH-1 downto 0);
signal pci_exp_tx_n_slv               : std_logic_vector(C_PCIE_DWIDTH-1 downto 0);
	
-- PCIe - RX
signal pci_exp_rx_p_slv               : std_logic_vector(C_PCIE_DWIDTH-1 downto 0);
signal pci_exp_rx_n_slv               : std_logic_vector(C_PCIE_DWIDTH-1 downto 0);

-- AXI4 Lite Master - Write address channel
signal m_axil_awaddr_slv               : std_logic_vector(C_AXI_LM_AWIDTH-1 downto 0);
signal m_axil_awprot_slv               : std_logic_vector(2 downto 0);
signal m_axil_wdata_slv                : std_logic_vector(C_AXI_LM_DWIDTH-1 downto 0);

-- AXI4 Lite Master - Write data channel
signal m_axil_wstrb_slv                : std_logic_vector((C_AXI_LM_DWIDTH/8)-1 downto 0);

-- AXI4 Lite Master - Write resposne channel
signal m_axil_bresp_slv                : std_logic_vector(1 downto 0);
signal m_axil_rdata_slv                : std_logic_vector(C_AXI_LM_DWIDTH-1 downto 0); 
signal m_axil_rresp_slv                : std_logic_vector(1 downto 0);

-- AXI4 Lite Master - Read address channel
signal m_axil_araddr_slv               : std_logic_vector(C_AXI_LM_AWIDTH-1 downto 0);
signal m_axil_arprot_slv               : std_logic_vector(2 downto 0);
   
-- AXI4 Lite Master - Read data channel
-- N/A
  	
-- AXI4 stream - C2H
signal s_axis_c2h_tdata_0_slv          : std_logic_vector(C_AXI_ST_DWIDTH-1 downto 0);
signal s_axis_c2h_tkeep_0_slv          : std_logic_vector((C_AXI_ST_DWIDTH/8)-1 downto 0);

-- AXI4 stream - H2C
signal m_axis_h2c_tdata_0_slv          : std_logic_vector(C_AXI_ST_DWIDTH-1 downto 0);
signal m_axis_h2c_tkeep_0_slv          : std_logic_vector((C_AXI_ST_DWIDTH/8)-1 downto 0);
 
-- Descriptor Bypass - C2H 
signal c2h_dsc_byp_src_addr_0_slv      : std_logic_vector(63 downto 0); 
signal c2h_dsc_byp_dst_addr_0_slv      : std_logic_vector(63 downto 0); 
signal c2h_dsc_byp_len_0_slv           : std_logic_vector(27 downto 0);
signal c2h_dsc_byp_ctl_0_slv           : std_logic_vector(15 downto 0); 

-- Descriptor Bypass - H2C
signal h2c_dsc_byp_src_addr_0_slv      : std_logic_vector(63 downto 0); 
signal h2c_dsc_byp_dst_addr_0_slv      : std_logic_vector(63 downto 0); 
signal h2c_dsc_byp_len_0_slv           : std_logic_vector(27 downto 0); 
signal h2c_dsc_byp_ctl_0_slv           : std_logic_vector(15 downto 0); 

-- Configuration
signal cfg_mgmt_read_data_slv          : std_logic_vector(31 downto 0);
  
signal cfg_mgmt_addr_slv               : std_logic_vector(18 downto 0);
signal cfg_mgmt_write_data_slv         : std_logic_vector(31 downto 0);
signal cfg_mgmt_byte_enable_slv        : std_logic_vector(3 downto 0);

-- Interrupt
signal usr_irq_ack_slv                 : std_logic_vector(C_NUM_INT-1 downto 0);
signal msi_vector_width_slv            : std_logic_vector(2 downto 0);
 
signal usr_irq_req_slv                 : std_logic_vector(C_NUM_INT-1 downto 0);

-- -----------------------------------------------------------------------------
-- Attributes
-- -----------------------------------------------------------------------------
-- N/A

begin

  -- ---------------------------------------------------------------------------  
  --  "pci_dma" - Instance
  -- ---------------------------------------------------------------------------
  -- Xilinx IP
  PCIE_DMA_INST : xdma_0
  port map
  ( 
    -- ---------------------------------------------------
    -- Clock
    -- ---------------------------------------------------  

    -- 100MHz
    sys_clk                            => Sys_clk,                             -- I external
	
    -- 100MHz
    sys_clk_gt                         => Sys_clk_gt,                          -- I external
 
	-- 125MHz clock
    axi_aclk                           => Axi_aclk,                            -- O external

    -- ---------------------------------------------------
    -- Reset
    -- --------------------------------------------------- 

	-- Active low reset
    sys_rst_n                          => Sys_rst_n,                           -- I external
 
    -- Active low reset
    axi_aresetn                        => Axi_aresetn,                         -- O external 
 
    -- ---------------------------------------------------
    -- PCIe
    -- --------------------------------------------------- 
  
    -- PCIe - TX
    pci_exp_txp                        => pci_exp_tx_p_slv,                    -- O [C_PCIE_DWIDTH-1:0]
    pci_exp_txn                        => pci_exp_tx_n_slv,                    -- O [C_PCIE_DWIDTH-1:0]
	
	-- PCIe - RX
    pci_exp_rxp                        => pci_exp_rx_p_slv,                    -- I [C_PCIE_DWIDTH-1:0] 
    pci_exp_rxn                        => pci_exp_rx_n_slv,                    -- I [C_PCIE_DWIDTH-1:0]
	
    -- Link status
    user_lnk_up                        => User_lnk_up,                         -- O external
    
    -- --------------------------------------------------- 
    -- AXI4 Lite Master 
    -- ---------------------------------------------------
  	
    -- Write address channel
    m_axil_awaddr                      => m_axil_awaddr_slv,                   -- O [C_AXI_LM_AWIDTH-1:0]
    m_axil_awprot                      => m_axil_awprot_slv,                   -- O [2:0]
    m_axil_awvalid                     => M_axil_awvalid,                      -- O external 
    m_axil_awready                     => M_axil_awready,                      -- I external 

    -- Write data channel
    m_axil_wdata                       => m_axil_wdata_slv,                    -- O [C_AXI_LM_DWIDTH-1:0]
    m_axil_wstrb                       => m_axil_wstrb_slv,                    -- O [C_AXI_LM_DWIDTH/8-1:0]
    m_axil_wvalid                      => M_axil_wvalid,                       -- O external 
    m_axil_wready                      => M_axil_wready,                       -- I external 
    m_axil_bvalid                      => M_axil_bvalid,                       -- I external 
    m_axil_bresp                       => m_axil_bresp_slv,                    -- I [1:0]
    m_axil_bready                      => M_axil_bready,                       -- O external 
  
    -- Read address channel
    m_axil_araddr                      => m_axil_araddr_slv,                   -- O [C_AXI_LM_AWIDTH-1:0]
    m_axil_arprot                      => m_axil_arprot_slv,                   -- O [2:0]
    m_axil_arvalid                     => M_axil_arvalid,                      -- O external 
    m_axil_arready                     => M_axil_arready,                      -- I external 

    -- Read data channel
    m_axil_rdata                       => m_axil_rdata_slv,                    -- I [C_AXI_LM_DWIDTH-1:0]
    m_axil_rresp                       => m_axil_rresp_slv,                    -- I [1:0]
    m_axil_rvalid                      => M_axil_rvalid,                       -- I external 
    m_axil_rready                      => M_axil_rready,                       -- O external 
  
    -- ---------------------------------------------------
    -- AXI4 Lite Slave 
    -- ---------------------------------------------------

    -- Write address channel
    s_axil_awaddr                      => s_axil_awaddr_slv,                   -- I [C_AXI_LS_AWIDTH-1:0] 
    s_axil_awprot                      => s_axil_awprot_slv,                   -- I [2:0] 
    s_axil_awvalid                     => S_axil_awvalid,                      -- I external 
    s_axil_awready                     => S_axil_awready,                      -- O external 

    -- Write data channel
    s_axil_wdata                       => s_axil_wdata_slv,                    -- I [C_AXI_LS_DWIDTH-1:0]
    s_axil_wstrb                       => s_axil_wstrb_slv,                    -- I [C_AXI_LS_DWIDTH/8-1:0]
    s_axil_wvalid                      => S_axil_wvalid,                       -- I external 
    s_axil_wready                      => S_axil_wready,                       -- O external 
 
    -- Write response channel
    s_axil_bvalid                      => S_axil_bvalid,                       -- O external 
    s_axil_bresp                       => S_axil_bresp_slv,                    -- O [1:0]
    s_axil_bready                      => S_axil_bready,                       -- I external 
  
    -- Read address channel
    s_axil_araddr                      => s_axil_araddr_slv,                   -- I [C_AXI_LS_AWIDTH-1:0]
    s_axil_arprot                      => s_axil_arprot_slv,                   -- I [2:0]
    s_axil_arvalid                     => S_axil_arvalid,                      -- I external
    s_axil_arready                     => S_axil_arready,                      -- O external
 
    -- Read data channel
    s_axil_rdata                       => S_axil_rdata_slv,                    -- O [C_AXI_LS_DWIDTH-1:0]
    s_axil_rresp                       => S_axil_rresp_slv,                    -- O [1:0]
    s_axil_rvalid                      => S_axil_rvalid,                       -- O external
    s_axil_rready                      => S_axil_rready,                       -- I external
  
    -- ---------------------------------------------------
    -- AXI4 stream - C2H 
    -- ---------------------------------------------------
    s_axis_c2h_tdata_0                 => s_axis_c2h_tdata_0_slv,              -- I [C_AXI_ST_DWIDTH-1:0]
    s_axis_c2h_tlast_0                 => S_axis_c2h_tlast_0,                  -- I external
    s_axis_c2h_tvalid_0                => S_axis_c2h_tvalid_0,                 -- I external
    s_axis_c2h_tready_0                => S_axis_c2h_tready_0,                 -- O external
    s_axis_c2h_tkeep_0                 => s_axis_c2h_tkeep_0_slv,              -- I [C_AXI_ST_DWIDTH/8-1:0]
  
    -- ---------------------------------------------------
    -- AXI4 stream - H2C 
    -- ---------------------------------------------------
    m_axis_h2c_tdata_0                 => m_axis_h2c_tdata_0_slv,              -- O [C_AXI_ST_DWIDTH-1:0]
    m_axis_h2c_tlast_0                 => M_axis_h2c_tlast_0,                  -- O external
    m_axis_h2c_tvalid_0                => M_axis_h2c_tvalid_0,                 -- O external
    m_axis_h2c_tready_0                => M_axis_h2c_tready_0,                 -- I external
    m_axis_h2c_tkeep_0                 => m_axis_h2c_tkeep_0_slv,              -- O [C_AXI_ST_DWIDTH/8-1:0]  

    -- --------------------------------------------------- 
    -- Descriptor Bypass - C2H
    -- ---------------------------------------------------
    c2h_dsc_byp_ready_0                => C2h_dsc_byp_ready_0,                 -- O external
    c2h_dsc_byp_src_addr_0             => c2h_dsc_byp_src_addr_0_slv,          -- I [63:0]
    c2h_dsc_byp_dst_addr_0             => c2h_dsc_byp_dst_addr_0_slv,          -- I [63:0]
    c2h_dsc_byp_len_0                  => c2h_dsc_byp_len_0_slv,               -- I [27:0]
    c2h_dsc_byp_ctl_0                  => c2h_dsc_byp_ctl_0_slv,               -- I [15:0]
    c2h_dsc_byp_load_0                 => C2h_dsc_byp_load_0,                  -- I external
	
    -- ---------------------------------------------------
	-- Descriptor Bypass - C2H
    -- ---------------------------------------------------
    h2c_dsc_byp_ready_0                => H2c_dsc_byp_ready_0,                 -- O external
    h2c_dsc_byp_src_addr_0             => h2c_dsc_byp_src_addr_0_slv,          -- I [63:0]
    h2c_dsc_byp_dst_addr_0             => h2c_dsc_byp_dst_addr_0_slv,          -- I [63:0]
    h2c_dsc_byp_len_0                  => h2c_dsc_byp_len_0_slv,               -- I [27:0]
    h2c_dsc_byp_ctl_0                  => h2c_dsc_byp_ctl_0_slv,               -- I [15:0]
    h2c_dsc_byp_load_0                 => H2c_dsc_byp_load_0,                  -- I external 
	
    -- ---------------------------------------------------
    -- Configuration	
    -- ---------------------------------------------------	
    cfg_mgmt_addr                      => cfg_mgmt_addr_slv,                   -- I [18:0]
    cfg_mgmt_write                     => Cfg_mgmt_write,                      -- I external
    cfg_mgmt_write_data                => cfg_mgmt_write_data_slv,             -- I [31:0]
    cfg_mgmt_byte_enable               => cfg_mgmt_byte_enable_slv,            -- I [3:0]
    cfg_mgmt_read                      => Cfg_mgmt_read,                       -- I external
    cfg_mgmt_read_data                 => cfg_mgmt_read_data_slv,              -- O [31:0]
    cfg_mgmt_read_write_done           => Cfg_mgmt_read_write_done,            -- O external
    
    -- ---------------------------------------------------
    -- Interrupt	
    -- ---------------------------------------------------	
    usr_irq_req                        => usr_irq_req_slv,                     -- I [C_NUM_INT-1:0]
    usr_irq_ack                        => usr_irq_ack_slv,                     -- O [C_NUM_INT-1:0]
    msi_enable                         => Msi_enable,                          -- O external
    msi_vector_width                   => msi_vector_width_slv                 -- O [2:0]  
  );  

  -- unsigned to std_logic_vector / std_logic_vector to unsigned conversion

  -- PCIe - TX
  Pcie_tx_p <= unsigned(pci_exp_tx_p_slv); -- External
  Pcie_tx_n <= unsigned(pci_exp_tx_n_slv); -- External
	
  -- PCIe - RX
  pci_exp_rx_p_slv <= std_logic_vector(Pcie_rx_p); -- External
  pci_exp_rx_n_slv <= std_logic_vector(Pcie_rx_n); -- External

  -- AXI4 Lite Master - Write address channel
  M_axil_awaddr <= unsigned(m_axil_awaddr_slv); -- External
  M_axil_awprot <= unsigned(m_axil_awprot_slv); -- External

  -- AXI4 Lite Master - Write data channel
  M_axil_wdata  <= unsigned(m_axil_wdata_slv); -- External
  M_axil_wstrb  <= unsigned(m_axil_wstrb_slv); -- External

  -- AXI4 Lite Master - Write resposne channel
  m_axil_bresp_slv <= std_logic_vector(m_axil_bresp); 
  m_axil_rdata_slv <= std_logic_vector(m_axil_rdata); 
  m_axil_rresp_slv <= std_logic_vector(m_axil_rresp); 

  -- AXI4 Lite Master - Read address channel
  M_axil_araddr <= unsigned(m_axil_araddr_slv); -- External
  M_axil_arprot <= unsigned(m_axil_arprot_slv); -- External
   
  -- AXI4 Lite Slave - Write address channel
  s_axil_awaddr_slv <= std_logic_vector(S_axil_awaddr); 
  s_axil_awprot_slv <= std_logic_vector(S_axil_awprot); 

  -- AXI4 Lite Slave - Write data channel
  s_axil_wdata_slv <= std_logic_vector(S_axil_wdata); 
  s_axil_wstrb_slv <= std_logic_vector(S_axil_wstrb); 

  -- AXI4 Lite Slave - Write response channel
  S_axil_bresp <= unsigned(s_axil_bresp_slv); -- External
  
  -- AXI4 Lite Slave - Read address channel
  s_axil_araddr_slv <= std_logic_vector(S_axil_araddr); 
  s_axil_arprot_slv <= std_logic_vector(S_axil_arprot); 

  -- AXI4 Lite Slave - Read data channel
  S_axil_rdata <= unsigned(S_axil_rdata_slv); -- External
  S_axil_rresp <= unsigned(S_axil_rresp_slv); -- External
  	
  -- AXI4 stream - C2H
  s_axis_c2h_tdata_0_slv <= std_logic_vector(S_axis_c2h_tdata_0);
  s_axis_c2h_tkeep_0_slv <= std_logic_vector(S_axis_c2h_tkeep_0); 

  -- AXI4 stream - H2C
  M_axis_h2c_tdata_0 <= unsigned(m_axis_h2c_tdata_0_slv); -- External
  M_axis_h2c_tkeep_0 <= unsigned(m_axis_h2c_tkeep_0_slv); -- External
  
  -- Descriptor Bypass - C2H
  c2h_dsc_byp_src_addr_0_slv <= std_logic_vector(C2h_dsc_byp_src_addr_0); 
  c2h_dsc_byp_dst_addr_0_slv <= std_logic_vector(C2h_dsc_byp_dst_addr_0); 
  c2h_dsc_byp_len_0_slv <= std_logic_vector(C2h_dsc_byp_len_0); 
  c2h_dsc_byp_ctl_0_slv <= std_logic_vector(C2h_dsc_byp_ctl_0); 

  -- Descriptor Bypass - H2C
  h2c_dsc_byp_src_addr_0_slv <= std_logic_vector(H2c_dsc_byp_src_addr_0);
  h2c_dsc_byp_dst_addr_0_slv <= std_logic_vector(H2c_dsc_byp_dst_addr_0); 
  h2c_dsc_byp_len_0_slv <= std_logic_vector(H2c_dsc_byp_len_0); 
  h2c_dsc_byp_ctl_0_slv <= std_logic_vector(H2c_dsc_byp_ctl_0); 

  -- Configuration
  Cfg_mgmt_read_data <= unsigned(cfg_mgmt_read_data_slv);
  cfg_mgmt_addr_slv <= std_logic_vector(Cfg_mgmt_addr); 
  cfg_mgmt_write_data_slv <= std_logic_vector(Cfg_mgmt_write_data); 
  cfg_mgmt_byte_enable_slv <= std_logic_vector(Cfg_mgmt_byte_enable); 

  -- Interrupt
  Usr_irq_ack      <= unsigned(usr_irq_ack_slv); -- External
  Msi_vector_width <= unsigned(msi_vector_width_slv); -- External

  usr_irq_req_slv <= std_logic_vector(Usr_irq_req); -- External
	
end rtl;

