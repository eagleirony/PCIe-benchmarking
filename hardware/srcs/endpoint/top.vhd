
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

-- ------------------------------------------------------------------------------------------
-- Entity 
-- ------------------------------------------------------------------------------------------
entity top is
port 
(
  -- ---------------------------------------------------
  -- Clock
  -- ---------------------------------------------------  

  -- 200MHz clock
  Clk200_p                             : in  std_logic;
  Clk200_n                             : in  std_logic;

  -- 100MHz clock
  Sys_clk_p                            : in  std_logic;
  Sys_clk_n                            : in  std_logic;

  -- ---------------------------------------------------
  -- Reset
  -- --------------------------------------------------- 

  Sys_rst_n                            : in  std_logic;

  -- ---------------------------------------------------
  -- Debug
  -- --------------------------------------------------- 
  Led                                  : out std_logic
  
  -- ---------------------------------------------------
  -- PCIe
  -- ---------------------------------------------------   

  -- TX
  --Pcie_tx_p                            : out unsigned(C_PCIE_DWIDTH-1 downto 0);
  --Pcie_tx_n                            : out unsigned(C_PCIE_DWIDTH-1 downto 0);
  
  -- RX
  --Pcie_rx_p                            : in  unsigned(C_PCIE_DWIDTH-1 downto 0);
  --Pcie_rx_n                            : in  unsigned(C_PCIE_DWIDTH-1 downto 0)
);
end entity top;

-- ------------------------------------------------------------------------------------------
-- Architecture 
-- ------------------------------------------------------------------------------------------
architecture rtl of top is
begin

end rtl;