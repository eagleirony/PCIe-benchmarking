library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity axil_bus is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Width of S_AXI data bus
    c_s_axi_data_width : integer := 32;
    -- Width of S_AXI address bus
    c_s_axi_addr_width : integer := 8
  );
  port (
    -- Users to add ports here

    -- User ports ends

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

    -- Do not modify the ports beyond this line

    -- Global Clock Signal
    s_axi_aclk : in    std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    s_axi_aresetn : in    std_logic;
    -- Write address (issued by master, acceped by Slave)
    s_axi_awaddr : in    std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    s_axi_awprot : in    std_logic_vector(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    s_axi_awvalid : in    std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    s_axi_awready : out   std_logic;
    -- Write data (issued by master, acceped by Slave)
    s_axi_wdata : in    std_logic_vector(c_s_axi_data_width - 1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.
    s_axi_wstrb : in    std_logic_vector((c_s_axi_data_width / 8) - 1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    s_axi_wvalid : in    std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    s_axi_wready : out   std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    s_axi_bresp : out   std_logic_vector(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    s_axi_bvalid : out   std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    s_axi_bready : in    std_logic;
    -- Read address (issued by master, acceped by Slave)
    s_axi_araddr : in    std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    s_axi_arprot : in    std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    s_axi_arvalid : in    std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    s_axi_arready : out   std_logic;
    -- Read data (issued by slave)
    s_axi_rdata : out   std_logic_vector(c_s_axi_data_width - 1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    s_axi_rresp : out   std_logic_vector(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    s_axi_rvalid : out   std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    s_axi_rready : in    std_logic
  );
end entity axil_bus;

architecture arch_imp of axil_bus is

  -- AXI4LITE signals
  signal axi_awaddr  : std_logic_vector(c_s_axi_addr_width - 1 downto 0);
  signal axi_awready : std_logic;
  signal axi_wready  : std_logic;
  signal axi_bresp   : std_logic_vector(1 downto 0);
  signal axi_bvalid  : std_logic;
  signal axi_araddr  : std_logic_vector(c_s_axi_addr_width - 1 downto 0);
  signal axi_arready : std_logic;
  signal axi_rresp   : std_logic_vector(1 downto 0);
  signal axi_rvalid  : std_logic;

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant addr_lsb          : integer := (c_s_axi_data_width / 32) + 1;
  constant opt_mem_addr_bits : integer := 5;
  ------------------------------------------------
  ---- Signals for user logic register space example
  --------------------------------------------------
  ---- Number of Slave Registers 64
  signal slv_reg0   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg1   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg2   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg3   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg4   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg5   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg6   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg7   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg8   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg9   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg10  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg11  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg12  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg13  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg14  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg15  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg16  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg17  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg18  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg19  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg20  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg21  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg22  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg23  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg24  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg25  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg26  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg27  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg28  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg29  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg30  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg31  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg32  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg33  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg34  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg35  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg36  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg37  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg38  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg39  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg40  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg41  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg42  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg43  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg44  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg45  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg46  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg47  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg48  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg49  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg50  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg51  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg52  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg53  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg54  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg55  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg56  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg57  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg58  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg59  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg60  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg61  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg62  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg63  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal byte_index : integer;

  signal mem_logic : std_logic_vector(addr_lsb + opt_mem_addr_bits downto addr_lsb);

  -- State machine local parameters
  constant idle  : std_logic_vector(1 downto 0) := "00";
  constant raddr : std_logic_vector(1 downto 0) := "10";
  constant rdata : std_logic_vector(1 downto 0) := "11";
  constant waddr : std_logic_vector(1 downto 0) := "10";
  constant wdata : std_logic_vector(1 downto 0) := "11";
  -- State machine variables
  signal state_read  : std_logic_vector(1 downto 0);
  signal state_write : std_logic_vector(1 downto 0);

begin

  -- I/O Connections assignments

  s_axi_awready <= axi_awready;
  s_axi_wready  <= axi_wready;
  s_axi_bresp   <= axi_bresp;
  s_axi_bvalid  <= axi_bvalid;
  s_axi_arready <= axi_arready;
  s_axi_rresp   <= axi_rresp;
  s_axi_rvalid  <= axi_rvalid;
  mem_logic     <= s_axi_awaddr(addr_lsb + opt_mem_addr_bits downto addr_lsb)
                   when (s_axi_awvalid = '1') else
                   axi_awaddr(addr_lsb + opt_mem_addr_bits downto addr_lsb);

  reg_0_w <= slv_reg0;
  reg_1_w <= slv_reg1;
  reg_2_w <= slv_reg2;
  reg_3_w <= slv_reg3;
  reg_4_w <= slv_reg4;
  reg_5_w <= slv_reg5;
  reg_6_w <= slv_reg6;
  reg_7_w <= slv_reg7;
  reg_8_w <= slv_reg8;
  reg_9_w <= slv_reg9;
  reg_10_w <= slv_reg10;
  reg_11_w <= slv_reg11;
  reg_12_w <= slv_reg12;
  reg_13_w <= slv_reg13;
  reg_14_w <= slv_reg14;
  reg_15_w <= slv_reg15;
  reg_16_w <= slv_reg16;
  reg_17_w <= slv_reg17;
  reg_18_w <= slv_reg18;
  reg_19_w <= slv_reg19;
  reg_20_w <= slv_reg20;
  reg_21_w <= slv_reg21;
  reg_22_w <= slv_reg22;
  reg_23_w <= slv_reg23;
  reg_24_w <= slv_reg24;
  reg_25_w <= slv_reg25;
  reg_26_w <= slv_reg26;
  reg_27_w <= slv_reg27;
  reg_28_w <= slv_reg28;
  reg_29_w <= slv_reg29;
  reg_30_w <= slv_reg30;
  reg_31_w <= slv_reg31;
  reg_32_w <= slv_reg32;
  reg_33_w <= slv_reg33;
  reg_34_w <= slv_reg34;
  reg_35_w <= slv_reg35;
  reg_36_w <= slv_reg36;
  reg_37_w <= slv_reg37;
  reg_38_w <= slv_reg38;
  reg_39_w <= slv_reg39;
  reg_40_w <= slv_reg40;
  reg_41_w <= slv_reg41;
  reg_42_w <= slv_reg42;
  reg_43_w <= slv_reg43;
  reg_44_w <= slv_reg44;
  reg_45_w <= slv_reg45;
  reg_46_w <= slv_reg46;
  reg_47_w <= slv_reg47;
  reg_48_w <= slv_reg48;
  reg_49_w <= slv_reg49;
  reg_50_w <= slv_reg50;
  reg_51_w <= slv_reg51;
  reg_52_w <= slv_reg52;
  reg_53_w <= slv_reg53;
  reg_54_w <= slv_reg54;
  reg_55_w <= slv_reg55;
  reg_56_w <= slv_reg56;
  reg_57_w <= slv_reg57;
  reg_58_w <= slv_reg58;
  reg_59_w <= slv_reg59;
  reg_60_w <= slv_reg60;
  reg_61_w <= slv_reg61;
  reg_62_w <= slv_reg62;
  reg_63_w <= slv_reg63;

  -- Implement Write state machine
  -- Outstanding write transactions are not supported by the slave i.e.,
  -- master should assert bready to receive response on or before it starts
  -- sending the new transaction
  process (s_axi_aclk) is
  begin

    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        -- asserting initial values to all 0's during reset
        axi_awready <= '0';
        axi_wready  <= '0';
        axi_bvalid  <= '0';
        axi_bresp   <= (others => '0');
        state_write <= idle;
      else

        case (state_write) is

          when idle =>

            -- Initial state inidicating reset is done and ready to receive
            -- read/write transactions

            if (s_axi_aresetn = '1') then
              axi_awready <= '1';
              axi_wready  <= '1';
              state_write <= waddr;
            else
              state_write <= state_write;
            end if;

          when waddr =>

            -- At this state, slave is ready to receive address along with
            -- corresponding control signals and first data packet. Response
            -- valid is also handled at this state

            if (s_axi_awvalid = '1' and axi_awready = '1') then
              axi_awaddr <= s_axi_awaddr;
              if (s_axi_wvalid = '1') then
                axi_awready <= '1';
                state_write <= waddr;
                axi_bvalid  <= '1';
              else
                axi_awready <= '0';
                state_write <= wdata;
                if (s_axi_bready = '1' and axi_bvalid = '1') then
                  axi_bvalid <= '0';
                end if;
              end if;
            else
              state_write <= state_write;
              if (s_axi_bready = '1' and axi_bvalid = '1') then
                axi_bvalid <= '0';
              end if;
            end if;

          when wdata =>

            -- At this state, slave is ready to receive the data packets until
            -- the number of transfers is equal to burst length

            if (s_axi_wvalid = '1') then
              state_write <= waddr;
              axi_bvalid  <= '1';
              axi_awready <= '1';
            else
              state_write <= state_write;
              if (s_axi_bready = '1' and axi_bvalid = '1') then
                axi_bvalid <= '0';
              end if;
            end if;

          when others =>

            -- reserved

            axi_awready <= '0';
            axi_wready  <= '0';
            axi_bvalid  <= '0';

        end case;

      end if;
    end if;

  end process;

  -- Implement memory mapped register select and write logic generation
  -- The write data is accepted and written to memory mapped registers when
  -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  -- select byte enables of slave registers while writing.
  -- These registers are cleared when reset (active low) is applied.
  -- Slave register write enable is asserted when valid address and data are available
  -- and the slave is ready to accept the write address and write data.

  process (s_axi_aclk) is
  begin

    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '1') then
        if (s_axi_wvalid = '1') then

          case (mem_logic) is

            when b"000000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 0
                  slv_reg0(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"000001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 1
                  slv_reg1(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"000010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 2
                  slv_reg2(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"000011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 3
                  slv_reg3(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"000100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 4
                  slv_reg4(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"000101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 5
                  slv_reg5(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"000110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 6
                  slv_reg6(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"000111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 7
                  slv_reg7(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 8
                  slv_reg8(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 9
                  slv_reg9(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 10
                  slv_reg10(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 11
                  slv_reg11(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 12
                  slv_reg12(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 13
                  slv_reg13(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 14
                  slv_reg14(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 15
                  slv_reg15(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 16
                  slv_reg16(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 17
                  slv_reg17(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 18
                  slv_reg18(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 19
                  slv_reg19(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 20
                  slv_reg20(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 21
                  slv_reg21(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 22
                  slv_reg22(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 23
                  slv_reg23(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 24
                  slv_reg24(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 25
                  slv_reg25(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 26
                  slv_reg26(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 27
                  slv_reg27(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 28
                  slv_reg28(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 29
                  slv_reg29(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 30
                  slv_reg30(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 31
                  slv_reg31(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 32
                  slv_reg32(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 33
                  slv_reg33(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 34
                  slv_reg34(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 35
                  slv_reg35(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 36
                  slv_reg36(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 37
                  slv_reg37(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 38
                  slv_reg38(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 39
                  slv_reg39(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 40
                  slv_reg40(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 41
                  slv_reg41(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 42
                  slv_reg42(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 43
                  slv_reg43(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 44
                  slv_reg44(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 45
                  slv_reg45(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 46
                  slv_reg46(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 47
                  slv_reg47(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 48
                  slv_reg48(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 49
                  slv_reg49(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 50
                  slv_reg50(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 51
                  slv_reg51(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 52
                  slv_reg52(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 53
                  slv_reg53(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 54
                  slv_reg54(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 55
                  slv_reg55(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 56
                  slv_reg56(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 57
                  slv_reg57(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 58
                  slv_reg58(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 59
                  slv_reg59(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 60
                  slv_reg60(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 61
                  slv_reg61(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 62
                  slv_reg62(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 63
                  slv_reg63(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when others =>

              slv_reg0  <= slv_reg0;
              slv_reg1  <= slv_reg1;
              slv_reg2  <= slv_reg2;
              slv_reg3  <= slv_reg3;
              slv_reg4  <= slv_reg4;
              slv_reg5  <= slv_reg5;
              slv_reg6  <= slv_reg6;
              slv_reg7  <= slv_reg7;
              slv_reg8  <= slv_reg8;
              slv_reg9  <= slv_reg9;
              slv_reg10 <= slv_reg10;
              slv_reg11 <= slv_reg11;
              slv_reg12 <= slv_reg12;
              slv_reg13 <= slv_reg13;
              slv_reg14 <= slv_reg14;
              slv_reg15 <= slv_reg15;
              slv_reg16 <= slv_reg16;
              slv_reg17 <= slv_reg17;
              slv_reg18 <= slv_reg18;
              slv_reg19 <= slv_reg19;
              slv_reg20 <= slv_reg20;
              slv_reg21 <= slv_reg21;
              slv_reg22 <= slv_reg22;
              slv_reg23 <= slv_reg23;
              slv_reg24 <= slv_reg24;
              slv_reg25 <= slv_reg25;
              slv_reg26 <= slv_reg26;
              slv_reg27 <= slv_reg27;
              slv_reg28 <= slv_reg28;
              slv_reg29 <= slv_reg29;
              slv_reg30 <= slv_reg30;
              slv_reg31 <= slv_reg31;
              slv_reg32 <= slv_reg32;
              slv_reg33 <= slv_reg33;
              slv_reg34 <= slv_reg34;
              slv_reg35 <= slv_reg35;
              slv_reg36 <= slv_reg36;
              slv_reg37 <= slv_reg37;
              slv_reg38 <= slv_reg38;
              slv_reg39 <= slv_reg39;
              slv_reg40 <= slv_reg40;
              slv_reg41 <= slv_reg41;
              slv_reg42 <= slv_reg42;
              slv_reg43 <= slv_reg43;
              slv_reg44 <= slv_reg44;
              slv_reg45 <= slv_reg45;
              slv_reg46 <= slv_reg46;
              slv_reg47 <= slv_reg47;
              slv_reg48 <= slv_reg48;
              slv_reg49 <= slv_reg49;
              slv_reg50 <= slv_reg50;
              slv_reg51 <= slv_reg51;
              slv_reg52 <= slv_reg52;
              slv_reg53 <= slv_reg53;
              slv_reg54 <= slv_reg54;
              slv_reg55 <= slv_reg55;
              slv_reg56 <= slv_reg56;
              slv_reg57 <= slv_reg57;
              slv_reg58 <= slv_reg58;
              slv_reg59 <= slv_reg59;
              slv_reg60 <= slv_reg60;
              slv_reg61 <= slv_reg61;
              slv_reg62 <= slv_reg62;
              slv_reg63 <= slv_reg63;

          end case;

        end if;
      end if;
    end if;

  end process;

  -- Implement read state machine
  process (s_axi_aclk) is
  begin

    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        -- asserting initial values to all 0's during reset
        axi_arready <= '0';
        axi_rvalid  <= '0';
        axi_rresp   <= (others => '0');
        state_read  <= idle;
      else

        case (state_read) is

          when idle =>
            -- Initial state inidicating reset is done and ready to receive read/write transactions

            if (s_axi_aresetn = '1') then
              axi_arready <= '1';
              state_read  <= raddr;
            else
              state_read <= state_read;
            end if;

          when raddr =>
            -- At this state, slave is ready to receive address along with corresponding control signals

            if (s_axi_arvalid = '1' and axi_arready = '1') then
              state_read  <= rdata;
              axi_rvalid  <= '1';
              axi_arready <= '0';
              axi_araddr  <= s_axi_araddr;
            else
              state_read <= state_read;
            end if;

          when rdata =>
            -- At this state, slave is ready to send the data packets until the number of transfers is equal to burst length

            if (axi_rvalid = '1' and s_axi_rready = '1') then
              axi_rvalid  <= '0';
              axi_arready <= '1';
              state_read  <= raddr;
            else
              state_read <= state_read;
            end if;

          when others =>
            -- reserved

            axi_arready <= '0';
            axi_rvalid  <= '0';

        end case;

      end if;
    end if;

  end process;

  -- Implement memory mapped register select and read logic generation
  s_axi_rdata <= reg_0_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000000") else
                 reg_1_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000001") else
                 reg_2_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000010") else
                 reg_3_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000011") else
                 reg_4_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000100") else
                 reg_5_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000101") else
                 reg_6_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000110") else
                 reg_7_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000111") else
                 reg_8_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001000") else
                 reg_9_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001001") else
                 reg_10_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001010") else
                 reg_11_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001011") else
                 reg_12_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001100") else
                 reg_13_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001101") else
                 reg_14_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001110") else
                 reg_15_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001111") else
                 reg_16_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010000") else
                 reg_17_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010001") else
                 reg_18_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010010") else
                 reg_19_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010011") else
                 reg_20_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010100") else
                 reg_21_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010101") else
                 reg_22_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010110") else
                 reg_23_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010111") else
                 reg_24_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011000") else
                 reg_25_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011001") else
                 reg_26_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011010") else
                 reg_27_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011011") else
                 reg_28_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011100") else
                 reg_29_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011101") else
                 reg_30_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011110") else
                 reg_31_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011111") else
                 reg_32_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100000") else
                 reg_33_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100001") else
                 reg_34_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100010") else
                 reg_35_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100011") else
                 reg_36_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100100") else
                 reg_37_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100101") else
                 reg_38_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100110") else
                 reg_39_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100111") else
                 reg_40_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101000") else
                 reg_41_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101001") else
                 reg_42_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101010") else
                 reg_43_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101011") else
                 reg_44_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101100") else
                 reg_45_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101101") else
                 reg_46_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101110") else
                 reg_47_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101111") else
                 reg_48_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110000") else
                 reg_49_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110001") else
                 reg_50_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110010") else
                 reg_51_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110011") else
                 reg_52_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110100") else
                 reg_53_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110101") else
                 reg_54_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110110") else
                 reg_55_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110111") else
                 reg_56_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111000") else
                 reg_57_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111001") else
                 reg_58_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111010") else
                 reg_59_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111011") else
                 reg_60_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111100") else
                 reg_61_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111101") else
                 reg_62_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111110") else
                 reg_63_r when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111111") else
                 (others => '0');

-- Add user logic here

-- User logic ends

end architecture arch_imp;
