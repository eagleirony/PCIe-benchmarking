
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pn23 is
    generic (
        DATA_WIDTH : positive := 32;
        BITS_PER_CLK : positive := 16
    );
    Port ( clk : in STD_LOGIC;
           rstn : in STD_LOGIC;
           value : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
           ready : out STD_LOGIC
    );
end pn23;

architecture Behavioral of pn23 is

    signal sreg : std_logic_vector(23 downto 0);
    signal oreg : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal count : integer range 0 to DATA_WIDTH;

begin

    process (clk)
    begin
        if (rstn = '0') then
            sreg(23 downto 0) <= x"FF5C00";
            oreg(DATA_WIDTH - 1 downto 0) <= (others => '0');
            count <= 0;
            ready <= '0';
            value <= (others => '0');
            oreg <= (others => '0');
        else
          if rising_edge(clk) or falling_edge(clk) then
                oreg(DATA_WIDTH - 1 downto BITS_PER_CLK) <= oreg(DATA_WIDTH - BITS_PER_CLK - 1 downto 0);
                sreg(23 downto BITS_PER_CLK) <= sreg(23 - BITS_PER_CLK downto 0);
                
                for i in 0 to BITS_PER_CLK - 1 loop
                    sreg(i) <= sreg(23 - BITS_PER_CLK + i) xor sreg(18 - BITS_PER_CLK + i);
                    oreg(i) <= sreg(24 - BITS_PER_CLK + i);
                end loop;
            end if;
            if rising_edge(clk) then
                if (count = DATA_WIDTH/BITS_PER_CLK/2) then
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

end Behavioral;
