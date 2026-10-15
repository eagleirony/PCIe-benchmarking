library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pn23 is
  generic (
    DATA_WIDTH : positive := 64
  );
  port (
    clk   : in    std_logic;
    rstn  : in    std_logic;
    ena   : in    std_logic;
    valid : out   std_logic;
    value : out   std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end entity pn23;

architecture behavioral of pn23 is

  signal sreg      : std_logic_vector(23 downto 1);
  signal valid_out : std_logic;

begin

  valid <= valid_out;

  process (clk) is

    variable pn23_var : std_logic_vector(23 downto 1);
    variable next_bit : std_logic;

  begin

    if (rising_edge(clk)) then
      if (rstn = '0') then
        sreg(23 downto 1) <= "11111111010111000000000"; -- 0x7FAE00
        value             <= (others => '0');
        valid_out         <= '0';
      else
        if (ena = '1') then
          pn23_var := sreg;

          for i in 0 to DATA_WIDTH - 1 loop

            next_bit                  := pn23_var(23) xor pn23_var(18);
            value(DATA_WIDTH - 1 - i) <= pn23_var(23);
            pn23_var                  := pn23_var(22 downto 1) & next_bit;

          end loop;

          sreg      <= pn23_var;
          valid_out <= '1';
        else
          valid_out <= '0';
        end if;
      end if;
    end if;

  end process;

end architecture behavioral;
