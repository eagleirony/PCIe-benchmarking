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
            DATA_WIDTH : positive := 32
        );
end axis_TB;

architecture Behavioral of axis_TB is

    component pn23 is
        generic (
            DATA_WIDTH : positive := 32
        );
        Port ( clk : in STD_LOGIC;
               rstn : in STD_LOGIC;
               value : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
               ready : out STD_LOGIC
        );
    end component;
    
    component axis_master is
        generic (
            -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
            C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
            -- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
            C_M_START_COUNT	: integer	:= 32;
            -- FIFO depth
            FIFO_DEPTH : integer := 14
        );
        port (
            -- FIFO ports
            FIFO_STATUS : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            FIFO_DATA_IN : in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            FIFO_WR_ENA : in std_logic;
    
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

    signal clk : std_logic := '0';
    signal rstn : std_logic := '0';
    signal value : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal ready : std_logic;
    
    signal fifo_status : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    signal axis_tdata : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal axis_tvalid : std_logic;
    signal axis_tstrb : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal axis_tlast : std_logic;
    signal axis_tready : std_logic;

begin

    clk <= not clk after 10 ns;
    axis_tready <= '1';

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
        value => value,
        ready => ready
    );
    
    axis_c2h : axis_master
    generic map (
        -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
        C_M_AXIS_TDATA_WIDTH => DATA_WIDTH,
        -- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
        C_M_START_COUNT	=> 16,
        FIFO_DEPTH => 5
    )
    port map (
        -- FIFO ports
        FIFO_STATUS => fifo_status,
        FIFO_DATA_IN => value,
        FIFO_WR_ENA => ready,
        M_AXIS_ACLK	=> clk,
        M_AXIS_ARESETN	=> rstn,
        M_AXIS_TVALID => axis_tvalid,
        M_AXIS_TDATA => axis_tdata,
        M_AXIS_TSTRB => axis_tstrb,
        M_AXIS_TLAST => axis_tlast,
        M_AXIS_TREADY => axis_tready
    );

end Behavioral;