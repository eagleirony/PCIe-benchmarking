library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.shared_param.all;

entity axis_slave is
  generic (
    C_S_AXIS_TDATA_WIDTH : integer := 32;
    FIFO_STATUS_WIDTH    : integer := 32;
    FIFO_DEPTH           : integer := 14
  );
  port (
    fifo_status   : out   std_logic_vector(FIFO_STATUS_WIDTH - 1 downto 0);
    fifo_data_out : out   std_logic_vector(C_S_AXIS_TDATA_WIDTH - 1 downto 0);
    fifo_rd_ena   : in    std_logic;
    fifo_empty    : out   std_logic;

    s_axis_aclk    : in    std_logic;
    s_axis_aresetn : in    std_logic;
    s_axis_tready  : out   std_logic;
    s_axis_tdata   : in    std_logic_vector(C_S_AXIS_TDATA_WIDTH - 1 downto 0);
    s_axis_tstrb   : in    std_logic_vector((C_S_AXIS_TDATA_WIDTH / 8) - 1 downto 0);
    s_axis_tlast   : in    std_logic;
    s_axis_tvalid  : in    std_logic
  );
end entity axis_slave;

architecture arch_imp of axis_slave is

  -- function called clogb2 that returns an integer which has the
  -- value of the ceiling of the log base 2.

  function clogb2 (
    bit_depth : integer
  ) return integer is

    variable depth : integer := bit_depth;

  begin

    if (depth = 0) then
      return(0);
    else

      for clogb2 in 1 to bit_depth loop -- Works for up to 32 bit integers

        if (depth <= 1) then
          return(clogb2);
        else
          depth := depth / 2;
        end if;

      end loop;

    end if;

  end function clogb2;

  -- Total number of input data.
  constant number_of_input_words : integer := 8;
  -- bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
  constant bit_num : integer := clogb2(number_of_input_words - 1);
  -- Define the states of state machine
  -- The control state machine oversees the writing of input streaming data to the FIFO,
  -- and outputs the streaming data from the FIFO

  type state is (
    idle, -- This is the initial/idle state
    write_fifo
  );      -- In this state FIFO is written with the

  -- input stream data S_AXIS_TDATA
  signal axis_tready : std_logic;
  -- State variable
  signal mst_exec_state : state;
  -- FIFO implementation signals
  signal byte_index : integer;
  -- FIFO write enable
  signal fifo_wren : std_logic;
  -- FIFO full flag
  signal fifo_full_flag : std_logic;
  -- FIFO write pointer
  signal write_pointer : integer range 0 to bit_num - 1;
  -- sink has accepted all the streaming data and stored in FIFO
  signal writes_done : std_logic;

  type byte_fifo_type is array (0 to (number_of_input_words - 1)) of std_logic_vector(((C_S_AXIS_TDATA_WIDTH / 4) - 1)downto 0);

begin

  -- I/O Connections assignments

  s_axis_tready <= axis_tready;
  -- Control state machine implementation
  process (s_axis_aclk) is
  begin

    if (rising_edge (s_axis_aclk)) then
      if (s_axis_aresetn = '0') then
        -- Synchronous reset (active low)
        mst_exec_state <= idle;
      else

        case (mst_exec_state) is

          when idle =>

            -- The sink starts accepting tdata when
            -- there tvalid is asserted to mark the
            -- presence of valid streaming data
            if (s_axis_tvalid = '1') then
              mst_exec_state <= write_fifo;
            else
              mst_exec_state <= idle;
            end if;

          when write_fifo =>

            -- When the sink has accepted all the streaming input data,
            -- the interface swiches functionality to a streaming master
            if (writes_done = '1') then
              mst_exec_state <= idle;
            else
              -- The sink accepts and stores tdata
              -- into FIFO
              mst_exec_state <= write_fifo;
            end if;

          when others =>

            mst_exec_state <= idle;

        end case;

      end if;
    end if;

  end process;

  -- AXI Streaming Sink
  --
  -- The example design sink is always ready to accept the S_AXIS_TDATA  until
  -- the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
  axis_tready <= '1' when ((mst_exec_state = write_fifo) and (write_pointer <= number_of_input_words - 1) and (fifo_full_flag = '0')) else
                 '0';

  process (s_axis_aclk) is
  begin

    if (rising_edge (s_axis_aclk)) then
      if (s_axis_aresetn = '0') then
        write_pointer <= 0;
        writes_done   <= '0';
      else
        if (write_pointer <= number_of_input_words - 1) then
          if (fifo_wren = '1') then
            -- write pointer is incremented after every write to the FIFO
            -- when FIFO write signal is enabled.
            write_pointer <= write_pointer + 1;
            writes_done   <= '0';
          end if;
          if ((write_pointer = number_of_input_words - 1) or s_axis_tlast = '1') then
            -- reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data
            -- has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
            writes_done   <= '1';
            write_pointer <= 0;
          end if;
        end if;
      end if;
    end if;

  end process;

  -- FIFO write enable generation
  fifo_wren <= s_axis_tvalid and axis_tready;

  -- FIFO Implementation
  axis_fifo : component fifo
    generic map (
      data_width   => C_S_AXIS_TDATA_WIDTH,
      status_width => FIFO_STATUS_WIDTH,
      fifo_depth   => FIFO_DEPTH
    )
    port map (
      clk    => s_axis_aclk,
      rstn   => s_axis_aresetn,
      wr     => fifo_wren,
      rd     => fifo_rd_ena,
      din    => s_axis_tdata,
      empty  => fifo_empty,
      full   => fifo_full_flag,
      dout   => fifo_data_out,
      status => fifo_status
    );

end architecture arch_imp;
