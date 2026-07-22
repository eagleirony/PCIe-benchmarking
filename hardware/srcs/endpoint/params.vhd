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

end package utils_param;

-- Body section
package body utils_param is

end package body utils_param;