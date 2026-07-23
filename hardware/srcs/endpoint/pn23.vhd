
library ieee;
  use ieee.std_logic_1164.all;

entity pn23 is
  generic (
    data_width   : positive := 32;
    bits_per_clk : positive := 16
  );
  port (
    clk   : in    std_logic;
    rstn  : in    std_logic;
    value : out   std_logic_vector(data_width - 1 downto 0);
    ready : out   std_logic
  );
end entity pn23;

architecture behavioral of pn23 is

  signal sreg  : std_logic_vector(23 downto 0);
  signal oreg  : std_logic_vector(data_width - 1 downto 0);
  signal count : integer range 0 to data_width;

begin

  process (clk) is
  begin

    if (rstn = '0') then
      sreg(23 downto 0)             <= x"FF5C00";
      oreg(data_width - 1 downto 0) <= (others => '0');
      count                         <= 0;
      ready                         <= '0';
      value                         <= (others => '0');
      oreg                          <= (others => '0');
    else
      if (rising_edge(clk) or falling_edge(clk)) then
        oreg(data_width - 1 downto bits_per_clk) <= oreg(data_width - bits_per_clk - 1 downto 0);
        sreg(23 downto bits_per_clk)             <= sreg(23 - bits_per_clk downto 0);

        for i in 0 to bits_per_clk - 1 loop

          sreg(i) <= sreg(23 - bits_per_clk + i) xor sreg(18 - bits_per_clk + i);
          oreg(i) <= sreg(24 - bits_per_clk + i);

        end loop;

      end if;
      if rising_edge(clk) then
        if (count = data_width / bits_per_clk / 2) then
          value <= oreg;
          ready <= '1';
          count <= 1;
        else
          count <= count + 1;
          ready <= '0';
        end if;
      end if;
    end if;

  end process;

end architecture behavioral;
