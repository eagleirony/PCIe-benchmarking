library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pulse is
  port (
    clk      : in    std_logic;
    async_in : in    std_logic;
    sync_out : out   std_logic
  );
end entity pulse;

architecture behavioral of pulse is

  signal latch : std_logic;
  signal pulse : std_logic;

begin

  sync_out <= pulse;

  logic : process (clk) is
  begin

    if (rising_edge(clk)) then
      if async_in = '1' then
        if latch = '0' then
          pulse <= '1';
          latch <= '1';
        else
          pulse <= '0';
          latch <= '1';
        end if;
      else
        pulse <= '0';
        latch <= '0';
      end if;
    end if;

  end process logic;

end architecture behavioral;
