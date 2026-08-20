----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.05.2026 20:52:53
-- Design Name: 
-- Module Name: pn23_TB - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axis_TB is
        generic (
            DATA_WIDTH : positive := 64
        );
end axis_TB;

architecture Behavioral of axis_TB is

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
    
    component axis_master is
        generic (
            -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
            C_M_AXIS_TDATA_WIDTH	: integer	:= 64;
            -- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
            C_M_START_COUNT	: integer	:= 32;
            -- Width of FIFO status register.
             register_width : integer := 32;
            -- FIFO depth
            FIFO_DEPTH : integer := 14
        );
        port (
            -- FIFO ports
            FIFO_STATUS : out std_logic_vector(register_width - 1 downto 0);
            FIFO_DATA_IN : in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            FIFO_WR_ENA : in std_logic;
            fifo_full : out std_logic;
            PACKET_LENGTH : in std_logic_vector(register_width - 1 downto 0);
    
            -- Global ports
            M_AXIS_ACLK	: in std_logic;
            -- 
            M_AXIS_ARESETN	: in std_logic;
            -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
            M_AXIS_TVALID	: out std_logic;
            -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
            M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
            M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
            -- TLAST indicates the boundary of a packet.
            M_AXIS_TLAST	: out std_logic;
            -- TREADY indicates that the slave can accept a transfer in the current cycle.
            M_AXIS_TREADY	: in std_logic
        );
    end component;
    
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

    signal clk : std_logic := '0';
    signal rstn : std_logic := '0';
    signal value : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal ready : std_logic;
    
    signal fifo_status : std_logic_vector(32 - 1 downto 0);
    
    signal axis_tdata : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal axis_tvalid : std_logic;
    signal axis_tstrb : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal axis_tlast : std_logic;
    signal axis_tready : std_logic;
    
    signal sig_fifo_empty : std_logic;
    signal sig_fifo_status : std_logic_vector(32 - 1 downto 0);
    signal sig_fifo_data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    signal pn23_hold : std_logic;
 
begin

    clk <= not clk after 10 ns;

    process is
    begin
      rstn <= '0';
      wait for 40 ns;
      rstn <= '1';
      wait for 20us;
    end process;

    test: pn23 port map (
        clk => clk,
        rstn => rstn,
        hold => pn23_hold,
        value => value,
        valid => ready
    );
    
    axis_c2h : axis_master
    generic map (
        -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
        C_M_AXIS_TDATA_WIDTH => DATA_WIDTH,
        -- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
        C_M_START_COUNT	=> 8,
        register_width => 32,
        FIFO_DEPTH => 5
    )
    port map (
        -- FIFO ports
        FIFO_STATUS => fifo_status,
        FIFO_DATA_IN => value,
        FIFO_WR_ENA => ready,
        FIFO_FULL => pn23_hold,
        packet_length => x"00000009",
        M_AXIS_ACLK	=> clk,
        M_AXIS_ARESETN	=> rstn,
        M_AXIS_TVALID => axis_tvalid,
        M_AXIS_TDATA => axis_tdata,
        M_AXIS_TSTRB => axis_tstrb,
        M_AXIS_TLAST => axis_tlast,
        M_AXIS_TREADY => axis_tready
    );

    axis_slave_inst : axis_slave
    generic map (
        c_s_axis_tdata_width => DATA_WIDTH,
        fifo_status_width => 32,
        FIFO_DEPTH => 5
    )
    port map (
        FIFO_STATUS => sig_fifo_status,
        FIFO_DATA_OUT => sig_fifo_data_out,
        FIFO_RD_ENA => '1',
        FIFO_EMPTY => sig_fifo_empty,
        S_AXIS_ACLK => clk,
        S_AXIS_ARESETN => rstn,
        S_AXIS_TVALID => axis_tvalid,
        S_AXIS_TDATA => axis_tdata,
        S_AXIS_TSTRB => axis_tstrb,
        S_AXIS_TLAST => axis_tlast,
        S_AXIS_TREADY => axis_tready
    );


end Behavioral;