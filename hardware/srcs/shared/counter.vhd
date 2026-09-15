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
    stop  : in    std_logic;
    value : out   std_logic_vector(data_width - 1 downto 0)
  );
end entity counter;

architecture behavioral of counter is

  signal counter : unsigned(data_width - 1 downto 0);
  signal stopped : std_logic;

begin

  count_and_reset : process (clk) is
  begin

    if (rising_edge(clk)) then
      if (rstn = '0') then
        counter <= (others => '0');
        stopped <= '0';
      else
        if (stop = '1' or stopped = '1') then
          stopped <= '1';
          counter <= counter;
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;

  end process count_and_reset;

  value <= std_logic_vector(counter);

end architecture behavioral;
