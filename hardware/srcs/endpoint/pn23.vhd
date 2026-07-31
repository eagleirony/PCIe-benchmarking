
library ieee;
  use ieee.std_logic_1164.all;

entity pn23 is
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
end entity pn23;

architecture behavioral of pn23 is

  signal sreg  : std_logic_vector(23 downto 1);
  signal oreg  : std_logic_vector(data_width - 1 downto 0);

begin

  process (clk, rstn) is
    variable pn23_var : std_logic_vector(23 downto 1);
    variable next_bit : std_logic;
  begin

    if (rstn = '0') then
      sreg(23 downto 1) <= 23x"7FAE00";
      oreg(data_width - 1 downto 0) <= (others => '0');
      value                         <= (others => '0');
      oreg                          <= (others => '0');
      valid <= '0';
    else
      if (rising_edge(clk)) then

        if (hold = '0') then
          pn23_var := sreg;

          for i in 0 to data_width - 1 loop
            next_bit := pn23_var(23) xor pn23_var(18);

            oreg(data_width - 1 - i) <= pn23_var(23);

            pn23_var := pn23_var(22 downto 1) & next_bit;
          end loop;

          sreg <= pn23_var;

          value <= oreg;
          valid <= '1';
        else
          valid <= '0';
        end if;
      end if;
    end if;

  end process;

end architecture behavioral;
