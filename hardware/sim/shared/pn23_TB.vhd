library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pn23_tb is
  generic (
    DATA_WIDTH : positive := 64;
    REGISTER_WIDTH : positive := 32
  );
end entity pn23_tb;

architecture behavioral of pn23_tb is

  component pn23 is
    generic (
      DATA_WIDTH     : positive := 64
    );
    port (
      clk   : in    std_logic := '0';
      rstn  : in    std_logic;
      ena   : in    std_logic;
      valid : out   std_logic;
      value : out   std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component pn23;

  component phase_accum is
    generic (
      REGISTER_WIDTH : positive := 32
    );
    port (
      clk  : in  std_logic;
      rstn : in  std_logic;
      inc  : in  std_logic_vector(REGISTER_WIDTH - 1 downto 0);
      ena  : out std_logic
    );
  end component;

  signal clk   : std_logic := '0';
  signal rstn  : std_logic := '0';
  signal value : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal pn23_ena  : std_logic;
  signal valid : std_logic;
  signal pa_inc : std_logic_vector(REGISTER_WIDTH - 1 downto 0);

begin


  clk <= not clk after 10 ns;

  process is
  begin

    rstn <= '0';
    pa_inc <= x"00000000";
    wait for 40 ns;
    rstn <= '1';
    pa_inc <= x"33333333";
    wait for 500 ns;
    pa_inc <= x"66666666";
    wait for 500 ns;
    pa_inc <= x"C0000000";
    wait for 500 ns;
    pa_inc <= x"F3333333";
    wait for 400us;

  end process;

  phase_accum_test : component phase_accum
    generic map (
      REGISTER_WIDTH => REGISTER_WIDTH
    )
    port map (
      clk => clk,
      rstn => rstn,
      inc => pa_inc,
      ena => pn23_ena
    );

  pn23_test : component pn23
    generic map (
      DATA_WIDTH => DATA_WIDTH
    )
    port map (
      clk   => clk,
      rstn  => rstn,
      ena   => pn23_ena,
      valid => valid,
      value => value
    );

end architecture behavioral;
