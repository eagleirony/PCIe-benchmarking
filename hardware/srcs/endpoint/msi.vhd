library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity msi_handler is
  port (
    clk     : in    std_logic;
    rstn    : in    std_logic;
    ack     : in    std_logic;
    req_in  : in    std_logic;
    req_out : out    std_logic
  );
end entity msi_handler;

architecture behavioral of msi_handler is

  signal requested : std_logic;

begin

  req_out <= requested;

  handler : process (clk) is
  begin

    if (rising_edge(clk)) then
      if (rstn = '0') then
        requested <= '0';
      else
        if ack = '1' then
          requested <= '0';
        else
          if req_in = '1' then
            requested <= '1';
          else
            requested <= requested;
          end if;
        end if;
      end if;
    end if;

  end process handler;

end architecture behavioral;
