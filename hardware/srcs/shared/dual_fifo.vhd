library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_signed.all;

library work;
  use work.shared_param.all;

entity dual_fifo is
  generic (
    data_width     : positive := 32;
    register_width : positive := 32;
    fifo_depth     : positive := 5
  );
  port (
    clk      : in    std_logic;
    rstn     : in    std_logic;
    wr       : in    std_logic;
    din      : in    std_logic_vector(data_width - 1 downto 0);
    rd       : in    std_logic;
    dout     : out   std_logic_vector(data_width - 1 downto 0);
    empty    : out   std_logic;
    full     : out   std_logic;
    timeout  : in    std_logic_vector(register_width - 1 downto 0);
    status   : out   std_logic_vector(register_width - 1 downto 0);
    timeouts : out   std_logic_vector(register_width - 1 downto 0);
    total    : out   std_logic_vector(register_width - 1 downto 0)
  );
end entity dual_fifo;

architecture arch of dual_fifo is

  type state is (
    a_out,          -- Outputting fifo A and filling fifo B
    a_out_wait,     -- Outputting fifo A and fifo B timed out
    b_out,          -- Outputting fifo B and filling fifo A
    b_out_wait      -- Outputting fifo B and fifo \A timed out
  );

  signal curr_state : state;
  signal next_state : state;

  signal a_size : unsigned(fifo_depth - 1 downto 0);
  signal b_size : unsigned(fifo_depth - 1 downto 0);
  signal fifo_limit : unsigned(register_width - 1 downto 0);

  signal timeouts_sig  : unsigned(register_width - 1 downto 0);
  signal total_sig     : unsigned(register_width - 1 downto 0);
  signal timed_out     : std_logic;
  signal counter       : unsigned(register_width - 1 downto 0);
  signal timeout_value : unsigned(register_width - 1 downto 0);

  signal a_full   : std_logic;
  signal a_empty  : std_logic;
  signal a_read   : std_logic;
  signal a_write  : std_logic;
  signal a_dout   : std_logic_vector(data_width - 1 downto 0);
  signal a_din    : std_logic_vector(data_width - 1 downto 0);
  signal a_status : std_logic_vector(register_width - 1 downto 0);

  signal b_full   : std_logic;
  signal b_empty  : std_logic;
  signal b_read   : std_logic;
  signal b_write  : std_logic;
  signal b_dout   : std_logic_vector(data_width - 1 downto 0);
  signal b_din    : std_logic_vector(data_width - 1 downto 0);
  signal b_status : std_logic_vector(register_width - 1 downto 0);

begin

  timeouts <= std_logic_vector(timeouts_sig);
  total    <= std_logic_vector(total_sig);

  timeout_value <= unsigned(timeout);

  fifo_limit <= x"00000010";

  curr_state_control : process (clk) is
  begin
    if (rising_edge (clk)) then
      if (rstn = '0') then
        curr_state <= a_out;
      else
        curr_state <= next_state;
      end if;
    end if;
  end process curr_state_control;

  next_state_control : process (timed_out, a_full, b_full, a_empty, b_empty) is
  begin
    next_state <= curr_state;

    case (curr_state) is

      when a_out =>

        if (timed_out = '1' or b_full = '1') then
          if (a_empty = '1') then
            next_state <= b_out;
          else
            next_state <= a_out_wait;
          end if;
        end if;

      when a_out_wait =>

        if (a_empty = '1') then
          next_state <= b_out;
        end if;

      when b_out =>

        if (timed_out = '1' or a_full = '1') then
          if (b_empty = '1') then
            next_state <= a_out;
          else
            next_state <= b_out_wait;
          end if;
        end if;

      when b_out_wait =>

        if (b_empty = '1') then
          next_state <= a_out;
        end if;

      when others =>

        next_state <= curr_state;

    end case;

  end process next_state_control;

  a_din <= din;
  b_din <= din;

  with next_state select a_write <=
    wr when b_out,
    '0' when a_out,
    '0' when others;

  with next_state select b_write <=
    wr when a_out,
    '0' when b_out,
    '0' when others;

  with next_state select a_read <=
    rd when a_out,
    rd when a_out_wait,
    '0' when b_out,
    '0' when b_out_wait,
    '0' when others;

  with next_state select b_read <=
    rd when b_out,
    rd when b_out_wait,
    '0' when a_out,
    '0' when a_out_wait,
    '0' when others;

  with curr_state select dout <=
    a_dout when a_out,
    a_dout when a_out_wait,
    b_dout when b_out,
    b_dout when b_out_wait,
    (others => '0') when others;

  with next_state select empty <=
    a_empty when a_out,
    a_empty when a_out_wait,
    b_empty when b_out,
    b_empty when b_out_wait,
    '0' when others;

  with next_state select full <=
    a_full when b_out,
    a_full when b_out_wait,
    b_full when a_out,
    b_full when a_out_wait,
    '0' when others;

  total_counter : process (clk) is
  begin

    if (rising_edge (clk)) then
      if (rstn = '0') then
        total_sig  <= (others => '0');
      else
        if (curr_state /= next_state) then
          if (curr_state = a_out or curr_state = b_out) then
            total_sig <= total_sig + 1;
          end if;
        end if;
      end if;
    end if;

  end process total_counter;

  size_counts : process (clk) is
  begin

    if (rising_edge (clk)) then
      if (rstn = '0') then
        a_size <= (others => '0');
        b_size <= (others => '0');
      else
        if (a_write = '1' and a_size /= (2**a_size'length - 1)) then
          a_size <= a_size + 1;
        end if;
        if (a_read = '1' and a_size /= 0) then
          a_size <= a_size - 1;
        end if;
        if (b_write = '1' and b_size /= (2**a_size'length - 1)) then
          b_size <= b_size + 1;
        end if;
        if (b_read = '1' and b_size /= 0) then
          b_size <= b_size - 1;
        end if;
      end if;
    end if;

  end process size_counts;

  timeout_generation : process (clk) is
  begin

    if (rising_edge (clk)) then
      timed_out <= '0';
      if (rstn = '0') then
        counter      <= (others => '0');
        timeouts_sig <= (others => '0');
      else
        if (curr_state = a_out or curr_state = b_out) then
          if (wr = '0') then
            if (counter >= timeout_value) then
              counter      <= (others => '0');
              timed_out    <= '1';
              timeouts_sig <= timeouts_sig + 1;
            else
              counter <= counter + 1;
            end if;
          else
            counter <= (others => '0');
          end if;
        end if;
      end if;
    end if;

  end process timeout_generation;

  fifo_a : component fifo
    generic map (
      data_width   => data_width,
      status_width => register_width,
      fifo_depth   => fifo_depth
    )
    port map (
      clk    => clk,
      rstn   => rstn,
      wr     => a_write,
      rd     => a_read,
      din    => a_din,
      empty  => a_empty,
      full   => a_full,
      dout   => a_dout,
      status => a_status
    );

  fifo_b : component fifo
    generic map (
      data_width   => data_width,
      status_width => register_width,
      fifo_depth   => fifo_depth
    )
    port map (
      clk    => clk,
      rstn   => rstn,
      wr     => b_write,
      rd     => b_read,
      din    => b_din,
      empty  => b_empty,
      full   => b_full,
      dout   => b_dout,
      status => b_status
    );

end architecture arch;
