
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity counter is
  generic (
    data_width : positive := 32
  );
  port (
    clk   : in    std_logic;
    rstn  : in    std_logic;
    value : out   std_logic_vector(data_width - 1 downto 0)
  );
end entity counter;

architecture behavioral of counter is

  signal counter : unsigned(data_width - 1 downto 0);

begin

  count_and_reset : process (clk, rstn) is
  begin

    if (rstn = '0') then
      counter <= (others => '0');
    else
      if (rising_edge(clk)) then
        counter <= counter + 1;
      end if;
    end if;

  end process count_and_reset;

  value <= std_logic_vector(counter);

end architecture behavioral;
