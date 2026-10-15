library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity phase_accum is
  generic (
    REGISTER_WIDTH : positive := 32
  );
  port (
    clk  : in    std_logic;
    rstn : in    std_logic;
    inc  : in    std_logic_vector(REGISTER_WIDTH - 1 downto 0);
    ena  : out   std_logic
  );
end entity phase_accum;

architecture rtl of phase_accum is

  signal acc          : unsigned(REGISTER_WIDTH downto 0);
  signal inc_unsigned : unsigned(REGISTER_WIDTH - 1 downto 0);

begin

  inc_unsigned <= unsigned(inc);

  process (clk) is
  begin

    if rising_edge(clk) then
      if (rstn = '0') then
        acc <= (others => '0');
      else
        acc <= ('0' & acc(REGISTER_WIDTH - 1 downto 0)) + ('0' & inc_unsigned);
      end if;
    end if;

  end process;

  ena <= acc(REGISTER_WIDTH);

end architecture rtl;
