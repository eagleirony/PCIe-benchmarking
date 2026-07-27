
library ieee;
  use ieee.std_logic_1164.all;

entity pn23_64bit is
  port (
    clk   : in    std_logic;
    rstn  : in    std_logic;
    value : out   std_logic_vector(63 downto 0);
    ready : out   std_logic
  );
end entity pn23_64bit;

architecture behavioral of pn23_64bit is

  signal sreg  : std_logic_vector(31 downto 0);
  signal oreg  : std_logic_vector(63 downto 0);
  signal count : integer range 0 to 64;

begin

  process (clk) is
  begin

    if (rstn = '0') then
      sreg(31 downto 0)  <= x"FF5C0029";
      oreg(63 downto 0) <= (others => '0');
      count                         <= 0;
      ready                         <= '0';
      value                         <= (others => '0');
      oreg                          <= (others => '0');
    else
      if (rising_edge(clk) or falling_edge(clk)) then
        oreg(63 downto 32) <= oreg(31 downto 0);
        oreg(31 downto 0) <= sreg;


        for i in 14 to 31 loop

          sreg(i) <= sreg(i - 14) xor sreg(i - 9);

        end loop;
        
        for i in 9 to 13 loop
        
          sreg(i) <= (sreg(i + 4) xor sreg(i + 9)) xor sreg(i - 9);
        
        end loop;
        
        for i in 0 to 12 loop
        
          sreg(i) <= (sreg(i + 4) xor sreg(i + 9)) xor (sreg(i + 9) xor sreg(i + 14));
        
        end loop;

      end if;
      if rising_edge(clk) then
        if (count = 1) then
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
