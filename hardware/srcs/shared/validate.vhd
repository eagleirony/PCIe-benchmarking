library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity validate is
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
end entity validate;

architecture behavioral of validate is

  signal errs : unsigned(REGISTER_WIDTH - 1 downto 0);
  signal corr : unsigned(REGISTER_WIDTH - 1 downto 0);
  signal validate : std_logic;
  signal rd : std_logic;

begin
    
  rd_fifo <= rd;
  errors <= std_logic_vector(errs);
  correct <= std_logic_vector(corr);

  rd <= (not empty_a) and (not empty_b);

  process (clk, rstn) is
  begin
    if (rstn = '0') then
      errs <= (others => '0');
      corr <= (others => '0');
    else
      if (rising_edge(clk)) then
        if rd = '1' then
          if data_a = data_b then
            corr <= corr + 1;
          else
            errs <= errs + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture behavioral;
