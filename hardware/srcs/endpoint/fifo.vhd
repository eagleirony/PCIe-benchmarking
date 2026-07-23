
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_signed.all;

entity fifo is
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
end entity fifo;

architecture arch of fifo is

  type fifo_t is array (0 to 2 ** FIFO_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal mem : fifo_t;

  signal rdp     : unsigned(fifo_depth downto 0) := (others => '0');
  signal wrp     : unsigned(fifo_depth downto 0) := (others => '0');
  signal int_rdp : unsigned(fifo_depth - 1 downto 0);
  signal int_wrp : unsigned(fifo_depth - 1 downto 0);

  signal sig_used   : unsigned(fifo_depth downto 0);
  signal sig_status : std_logic_vector(data_width - 1 downto 0);

  signal sig_full  : std_logic;
  signal sig_empty : std_logic;

  signal sig_din  : std_logic_vector(data_width - 1 downto 0);
  signal sig_dout : std_logic_vector(data_width - 1 downto 0) := x"DEADC0DE";

begin

  empty    <= sig_empty;
  full     <= sig_full;
  sig_din  <= din;
  dout     <= sig_dout;
  status   <= sig_status;
  int_rdp  <= rdp(fifo_depth - 1 downto 0);
  int_wrp  <= wrp(fifo_depth - 1 downto 0);
  sig_used <= wrp - rdp;

  sig_status(status_width - 1)                       <= sig_full;
  sig_status(status_width - 2)                       <= sig_empty;
  sig_status(status_width - 3 downto FIFO_DEPTH + 1) <= (others => '0');
  sig_status(FIFO_DEPTH downto 0)                  <= std_logic_vector(sig_used);

  process (rdp, wrp, int_rdp, int_wrp) is
  begin

    if (rdp = wrp) then
      sig_empty <= '1';
      sig_full  <= '0';
    else
      sig_empty <= '0';
      if (int_wrp = int_rdp) then
        sig_full <= '1';
      else
        sig_full <= '0';
      end if;
    end if;

  end process;

  process (clk) is
  begin

    if (rstn = '0') then
      rdp      <= (others => '0');
      wrp      <= (others => '0');
      sig_dout <= x"DEADC0DE";
    else
      if rising_edge(clk) then
        if (rd = '1' and sig_empty = '0') then
          sig_dout <= mem(to_integer(int_rdp));
          rdp      <= rdp + 1;
        end if;
        if (wr = '1' and sig_full = '0') then
          mem(to_integer(int_wrp)) <= sig_din;
          wrp                      <= wrp + 1;
        end if;
      end if;
    end if;

  end process;

end architecture arch;
