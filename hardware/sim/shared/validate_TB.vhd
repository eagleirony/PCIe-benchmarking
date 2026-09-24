library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity validate_TB is
        generic (
            DATA_WIDTH : positive := 64;
            REGISTER_WIDTH : positive := 32
        );
end validate_TB;

architecture Behavioral of validate_TB is

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

  component fifo is
  generic (
    data_width : positive := 32;
    status_width : positive := 32;
    fifo_depth : positive := 5
  );
  port (
    clk    : in    std_logic;
    rstn   : in    std_logic;
    wr     : in    std_logic;
    rd     : in    std_logic;
    din    : in    std_logic_vector(data_width - 1 downto 0);
    empty  : out   std_logic;
    full   : out   std_logic;
    dout   : out   std_logic_vector(data_width - 1 downto 0);
    status : out   std_logic_vector(status_width - 1 downto 0)
  );
  end component fifo;

  component validate is
    generic (
      DATA_WIDTH : positive := 64;
      REGISTER_WIDTH : positive := 32
    );
    port (
      clk   : in    std_logic;
      rstn  : in    std_logic;
      rd_fifo   : out   std_logic;
      empty_a   : in    std_logic;
      empty_b   : in    std_logic;
      data_a    : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      data_b    : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      errors    : out   std_logic_vector(REGISTER_WIDTH - 1 downto 0);
      correct   : out   std_logic_vector(REGISTER_WIDTH - 1 downto 0)
    );
  end component validate;

  signal clk : std_logic := '0';
  signal rstn : std_logic := '0';

  signal rd_fifo : std_logic;
  signal pn23_hold_a : std_logic;
  signal pn23_hold_b : std_logic;

  signal value_a : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal value_b : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal ready_a : std_logic;
  signal ready_b : std_logic;

  signal pn23_a : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal pn23_b : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal empty_a : std_logic;
  signal full_a : std_logic;

  signal errors : std_logic_vector(REGISTER_WIDTH - 1 downto 0);
  signal correct : std_logic_vector(REGISTER_WIDTH - 1 downto 0);

  signal fifo_status : std_logic_vector(REGISTER_WIDTH - 1 downto 0);

begin

    clk <= not clk after 10 ns;

    process is
    begin
      rstn <= '0';
      wait for 40 ns;
      rstn <= '1';
      pn23_hold_a <= '0';
      wait for 40 ns;
      pn23_hold_a <= '1';
      wait for 40 ns;
      pn23_hold_a <= '0';
      wait for 100us;
    end process;

    pn23_hold_b <= not (rd_fifo);

    test_a: pn23 port map (
        clk => clk,
        rstn => rstn,
        hold => pn23_hold_a,
        value => pn23_a,
        valid => ready_a
    );

    test_b: pn23 port map (
        clk => clk,
        rstn => rstn,
        hold => pn23_hold_b,
        value => value_b,
        valid => ready_b
    );

    fifo_a: fifo generic map (
        data_width => DATA_WIDTH,
        status_width => REGISTER_WIDTH,
        fifo_depth => 5
      )
      port map (
        clk   => clk,
        rstn  => rstn,
        wr    => ready_a,
        rd    => rd_fifo,
        din   => pn23_a,
        empty => empty_a,
        full  => full_a,
        dout  => value_a,
        status => fifo_status
      );

    validate_inst: validate port map (
        clk => clk,
        rstn => rstn,
        rd_fifo => rd_fifo,
        empty_a => empty_a,
        empty_b => '0',
        data_a => value_a,
        data_b => value_b,
        errors => errors,
        correct => correct
    );

end Behavioral;
