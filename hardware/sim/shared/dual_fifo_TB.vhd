library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_signed.all;

entity dual_fifo_tb is
  generic (
    data_width : positive := 64;
    register_width : positive := 32
  );
end entity dual_fifo_tb;

architecture behavioral of dual_fifo_tb is

  component pn23 is
    generic (
      data_width : positive := 64
    );
    port (
      clk   : in    std_logic;
      rstn  : in    std_logic;
      hold  : in    std_logic;
      valid : out   std_logic;
      value : out   std_logic_vector(63 downto 0)
    );
  end component pn23;

  component dual_fifo is
    generic (
      data_width     : positive := 32;
      register_width : positive := 32;
      fifo_depth     : positive := 5
    );
    port (
      clk      : in    std_logic;
      rstn     : in    std_logic;
      wr       : in    std_logic;
      din      : in    std_logic_vector(data_width - 1 downto 0);
      rd       : in    std_logic;
      dout     : out   std_logic_vector(data_width - 1 downto 0);
      empty    : out   std_logic;
      full     : out   std_logic;
      timeout  : in    std_logic_vector(register_width - 1 downto 0);
      status   : out   std_logic_vector(register_width - 1 downto 0);
      timeouts : out   std_logic_vector(register_width - 1 downto 0);
      total    : out   std_logic_vector(register_width - 1 downto 0)
    );
  end component dual_fifo;

  signal clk  : std_logic := '1';
  signal rstn : std_logic;

  signal counter       : unsigned(data_width - 1 downto 0);
  signal counter_valid : std_logic;
  signal counter_hold  : std_logic;

  signal pn23_data  : std_logic_vector(data_width - 1 downto 0);
  signal pn23_valid : std_logic;
  signal pn23_hold  : std_logic;

  signal dfifo_rd      : std_logic;
  signal dfifo_out     : std_logic_vector(data_width - 1 downto 0);
  signal dfifo_empty   : std_logic;
  signal dfifo_full    : std_logic;
  signal dfifo_timout  : std_logic_vector(register_width - 1 downto 0);
  signal dfifo_status  : std_logic_vector(register_width - 1 downto 0);
  signal dfifo_timouts : std_logic_vector(register_width - 1 downto 0);
  signal dfifo_total   : std_logic_vector(register_width - 1 downto 0);

  signal fifo_status : std_logic_vector(register_width - 1 downto 0);

begin

  clk <= not clk after 10 ns;

  dfifo_timout <= x"00000010";

  run : process is
  begin

    rstn <= '0';
    pn23_hold <= '0';
    counter_hold <= '0';
    dfifo_rd <= '0';
    wait for 20 ns;
    rstn <= '1';
    wait for 40 ns;
    dfifo_rd <= '1';
    wait for 60 ns;
    counter_hold <= '1';
    pn23_hold <= '1';
    wait for 400 ns;
    dfifo_rd <= '0';
    counter_hold <= '0';
    pn23_hold <= '0';
    wait for 800 ns;
    dfifo_rd <= '1';
    wait for 800 ns;
    counter_hold <= '1';
    wait for 200 us;


  end process run;

  test : component pn23
    port map (
      clk   => clk,
      rstn  => rstn,
      hold  => pn23_hold,
      value => pn23_data,
      valid => pn23_valid
    );

  data_gen : process (clk) is
  begin

    if (rising_edge (clk)) then
      counter_valid <= '0';
      if (rstn = '0') then
        counter      <= (others => '0');
      else
        if (counter_hold = '0') then
          if (dfifo_full = '0') then
            counter <= counter + 1;
            counter_valid <= '1';
          else
            counter_valid <= '1';
          end if;
        end if;
      end if;
    end if;

  end process data_gen;

  dual_fifo_inst : component dual_fifo
    generic map (
      data_width     => data_width,
      register_width => register_width,
      fifo_depth     => 5
    )
    port map (
      clk      => clk,
      rstn     => rstn,
      wr       => counter_valid,
      din      => std_logic_vector(counter),
      rd       => dfifo_rd,
      dout     => dfifo_out,
      empty    => dfifo_empty,
      full     => dfifo_full,
      timeout  => dfifo_timout,
      status   => dfifo_status,
      timeouts => dfifo_timouts,
      total    => dfifo_total
    );

end architecture behavioral;
