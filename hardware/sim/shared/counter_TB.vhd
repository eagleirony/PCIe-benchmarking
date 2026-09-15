library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_signed.all;

entity counter_tb is
  generic (
    data_width : positive := 32
          );
end entity counter_tb;

architecture behavioral of counter_tb is

  component counter is
    generic (
      data_width : positive := 32
    );
    port (
      clk   : in    std_logic;
      rstn  : in    std_logic;
      stop  : in    std_logic;
      value : out   std_logic_vector(data_width - 1 downto 0)
    );
  end component counter;

  signal clk  : std_logic := '1';

  signal rstn : std_logic;
  signal stop : std_logic;
  signal value : std_logic_vector(data_width - 1 downto 0);

begin

  clk <= not clk after 10 ns;

  run : process is
  begin

    rstn <= '0';
    stop <= '0';
    wait for 40 ns;
    rstn <= '1';
    wait for 60 ns;
    stop <= '1';
    wait for 40 ns;
    stop <= '0';
    wait for 40 ns;
    rstn <= '0';
    wait for 40 ns;
    rstn <= '1';
    wait for 200 us;


  end process run;

  test : component counter
    port map (
      clk   => clk,
      rstn  => rstn,
      stop  => stop,
      value => value
    );

end architecture behavioral;
