library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity blink is
  generic (
    CLK_FREQ_HZ : integer := 100000000; -- 100 MHz
    BLINK_FREQ_HZ : integer := 1
  );
  port (
    clk   : in    std_logic;
    rstn  : in    std_logic;
    led   : out   std_logic
  );
end entity blink;

architecture behavioral of blink is

  constant TOGGLE_VALUE : integer := CLK_FREQ_HZ / (2 * BLINK_FREQ_HZ);
  signal counter : integer range 0 to TOGGLE_VALUE;
  signal blink : std_logic;

begin

  count_and_reset : process (clk, rstn) is
  begin
    if (rstn = '0') then
      counter <= 0;
    else
      if (rising_edge(clk)) then
        if counter >= (TOGGLE_VALUE - 1) then
          counter <= 0;
          blink <= not blink;
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process count_and_reset;

  led <= blink;

end architecture behavioral;
