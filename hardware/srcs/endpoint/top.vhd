
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.utils_param.all;

-- ------------------------------------------------------------------------------------------
-- Entity
-- ------------------------------------------------------------------------------------------

entity top is
  generic (

    data_width : integer := 32;
    fifo_depth : integer := 16
  );
  port (
    -- ---------------------------------------------------
    -- Clock
    -- ---------------------------------------------------

    -- 200MHz clock
    clk200_p : in    std_logic;
    clk200_n : in    std_logic;

    -- 100MHz clock
    sys_clk_p : in    std_logic;
    sys_clk_n : in    std_logic;

    -- ---------------------------------------------------
    -- Reset
    -- ---------------------------------------------------

    sys_rst_n : in    std_logic;

    -- ---------------------------------------------------
    -- Debug
    -- ---------------------------------------------------
    led : out   std_logic

  -- ---------------------------------------------------
  -- PCIe
  -- ---------------------------------------------------

  -- TX
  -- Pcie_tx_p                            : out unsigned(C_PCIE_DWIDTH-1 downto 0);
  -- Pcie_tx_n                            : out unsigned(C_PCIE_DWIDTH-1 downto 0);

  -- RX
  -- Pcie_rx_p                            : in  unsigned(C_PCIE_DWIDTH-1 downto 0);
  -- Pcie_rx_n                            : in  unsigned(C_PCIE_DWIDTH-1 downto 0)
  );
end entity top;

-- ------------------------------------------------------------------------------------------
-- Architecture
-- ------------------------------------------------------------------------------------------

architecture rtl of top is

begin

end architecture rtl;
