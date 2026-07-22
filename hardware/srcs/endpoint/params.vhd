library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

-- Package declartion
package utils_param is

	component fifo is
	    generic (
	        DATA_WIDTH : positive := 32;
	        FIFO_DEPTH : positive := 5
	    );
	    port (
	        clk     : in  std_logic;
	        rstn    : in  std_logic;
	        wr      : in  std_logic;
	        rd      : in  std_logic;
	        din     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
	        empty   : out std_logic;
	        full    : out std_logic;
	        dout    : out std_logic_vector(DATA_WIDTH-1 downto 0);
	        status  : out std_logic_vector(DATA_WIDTH-1 downto 0)
	    );
	end component;
	
	component pn23 is
        generic (
            DATA_WIDTH : positive := 32;
            BITS_PER_CLK : positive := 16
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

end package utils_param;

-- Body section
package body utils_param is

end package body utils_param;