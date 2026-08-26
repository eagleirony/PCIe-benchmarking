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

  signal value_a : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal value_b : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal ready_a : std_logic;
  signal ready_b : std_logic;

  signal errors : std_logic_vector(REGISTER_WIDTH - 1 downto 0);
  signal correct : std_logic_vector(REGISTER_WIDTH - 1 downto 0);

begin

    clk <= not clk after 10 ns;

    process is
    begin
      rstn <= '0';
      wait for 40 ns;
      rstn <= '1';
      wait for 20us;
    end process;

    test_a: pn23 port map (
        clk => clk,
        rstn => rstn,
        hold => '0',
        value => value_a,
        valid => ready_a
    );

    test_b: pn23 port map (
        clk => clk,
        rstn => rstn,
        hold => '0',
        value => value_b,
        valid => ready_b
    );

    validate_inst: validate port map (
        clk => clk,
        rstn => rstn,
        rd_fifo => rd_fifo,
        empty_a => '0',
        empty_b => '0',
        data_a => value_a,
        data_b => value_b,
        errors => errors,
        correct => correct
    );

end Behavioral;
