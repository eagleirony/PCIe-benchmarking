library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_signed.all;

entity pulse_tb is
end entity pulse_tb;

architecture behavioral of pulse_tb is

  component pulse is
    port (
      clk      : in    std_logic;
      async_in : in    std_logic;
      sync_out : out   std_logic
    );
  end component pulse;

  signal clk  : std_logic := '1';

  signal sync : std_logic;
  signal async : std_logic;

begin

  clk <= not clk after 10 ns;

  run : process is
  begin

    async <= '0';
    wait for 50 ns;
    async <= '1';
    wait for 20 ns;
    async <= '0';
    wait for 40 ns;
    async <= '1';
    wait for 40 ns;
    async <= '0';
    wait for 200 us;


  end process run;

  test : component pulse
    port map (
      clk   => clk,
      async_in => async,
      sync_out => sync
    );

end architecture behavioral;
