library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.utils_param.all;

entity axis_master is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
    c_m_axis_tdata_width : integer := 32;
    -- Width of FIFO status register.
    fifo_status_width : integer := 32;
    -- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
    c_m_start_count : integer := 32;
    -- FIFO depth
    fifo_depth : integer := 14
  );
  port (
    -- Users to add ports here

    fifo_status  : out   std_logic_vector(fifo_status_width - 1 downto 0);
    fifo_data_in : in    std_logic_vector(c_m_axis_tdata_width - 1 downto 0);
    fifo_wr_ena  : in    std_logic;

    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Global ports
    m_axis_aclk : in    std_logic;
    --
    m_axis_aresetn : in    std_logic;
    -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted.
    m_axis_tvalid : out   std_logic;
    -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
    m_axis_tdata : out   std_logic_vector(c_m_axis_tdata_width - 1 downto 0);
    -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
    m_axis_tstrb : out   std_logic_vector((c_m_axis_tdata_width / 8) - 1 downto 0);
    -- TLAST indicates the boundary of a packet.
    m_axis_tlast : out   std_logic;
    -- TREADY indicates that the slave can accept a transfer in the current cycle.
    m_axis_tready : in    std_logic
  );
end entity axis_master;

architecture implementation of axis_master is

  -- Total number of output data
  constant number_of_output_words : integer := 8;

  -- function called clogb2 that returns an integer which has the
  -- value of the ceiling of the log base 2.

  function clogb2 (
    bit_depth : integer
  ) return integer is

    variable depth : integer := bit_depth;
    variable count : integer := 1;

  begin

    for clogb2 in 1 to bit_depth loop -- Works for up to 32 bit integers

      if (bit_depth <= 2) then
        count := 1;
      else
        if (depth <= 1) then
          count := count;
        else
          depth := depth / 2;
          count := count + 1;
        end if;
      end if;

    end loop;

    return(count);

  end function clogb2;

  -- WAIT_COUNT_BITS is the width of the wait counter.
  constant wait_count_bits : integer := clogb2(c_m_start_count - 1);

  -- In this example, Depth of FIFO is determined by the greater of
  -- the number of input words and output words.
  constant depth : integer := number_of_output_words;

  -- bit_num gives the minimum number of bits needed to address 'depth' size of FIFO
  constant bit_num : integer := clogb2(depth);

  -- Define the states of state machine
  -- The control state machine oversees the writing of input streaming data to the FIFO,
  -- and outputs the streaming data from the FIFO

  type state is (
    idle,         -- This is the initial/idle state
    init_counter, -- This state initializes the counter, once
    -- the counter reaches C_M_START_COUNT count,
    -- the state machine changes state to SEND_STREAM
    send_stream
  ); -- In this state the

  -- stream data is output through M_AXIS_TDATA
  -- State variable
  signal mst_exec_state : state;
  -- Example design FIFO read pointer
  signal read_pointer : integer range 0 to depth - 1;

  -- AXI Stream internal signals
  -- wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
  signal count : std_logic_vector(wait_count_bits - 1 downto 0);
  -- streaming data valid
  signal axis_tvalid : std_logic;
  -- streaming data valid delayed by one clock cycle
  signal axis_tvalid_delay : std_logic;
  -- Last of the streaming data
  signal axis_tlast : std_logic;
  -- Last of the streaming data delayed by one clock cycle
  signal axis_tlast_delay : std_logic;
  -- FIFO implementation signals
  signal stream_data_out : std_logic_vector(c_m_axis_tdata_width - 1 downto 0);
  signal tx_en           : std_logic;
  signal fifo_empty      : std_logic;
  signal fifo_full       : std_logic;
  -- The master has issued all the streaming data stored in FIFO
  signal tx_done : std_logic;

begin

  -- I/O Connections assignments

  m_axis_tvalid <= axis_tvalid_delay;
  m_axis_tdata  <= stream_data_out;
  m_axis_tlast  <= axis_tlast_delay;
  m_axis_tstrb  <= (others => '1');

  -- Control state machine implementation
  process (m_axis_aclk) is
  begin

    if (rising_edge (m_axis_aclk)) then
      if (m_axis_aresetn = '0') then
        -- Synchronous reset (active low)
        mst_exec_state <= idle;
        count          <= (others => '0');
      else

        case (mst_exec_state) is

          when idle =>

            -- The slave starts accepting tdata when
            -- there tvalid is asserted to mark the
            -- presence of valid streaming data
            if (count = "0000") then
              mst_exec_state <= init_counter;
            else
              mst_exec_state <= send_stream;
            end if;

          when init_counter =>

            -- This state is responsible to wait for user defined C_M_START_COUNT
            -- number of clock cycles.
            if (count = std_logic_vector(to_unsigned((c_m_start_count - 1), wait_count_bits))) then
              mst_exec_state <= idle;
            else
              count          <= std_logic_vector(unsigned(count) + 1);
              mst_exec_state <= init_counter;
            end if;

          when send_stream =>

            -- The example design streaming master functionality starts
            -- when the master drives output tdata from the FIFO and the slave
            -- has finished storing the S_AXIS_TDATA
            if (tx_done = '1') then
              mst_exec_state <= idle;
            else
              mst_exec_state <= send_stream;
            end if;

          when others =>

            mst_exec_state <= idle;

        end case;

      end if;
    end if;

  end process;

  -- tvalid generation
  -- axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
  -- number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
  axis_tvalid <= '1' when ((mst_exec_state = send_stream) and (read_pointer < number_of_output_words) and (fifo_empty = '0')) else
                 '0';

  -- AXI tlast generation
  -- axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1
  -- (0 to NUMBER_OF_OUTPUT_WORDS-1)
  axis_tlast <= '1' when (read_pointer = number_of_output_words - 1) else
                '0';

  -- Delay the axis_tvalid and axis_tlast signal by one clock cycle
  -- to match the latency of M_AXIS_TDATA
  process (m_axis_aclk) is
  begin

    if (rising_edge (m_axis_aclk)) then
      if (m_axis_aresetn = '0') then
        axis_tvalid_delay <= '0';
        axis_tlast_delay  <= '0';
      else
        axis_tvalid_delay <= axis_tvalid;
        axis_tlast_delay  <= axis_tlast;
      end if;
    end if;

  end process;

  -- read_pointer pointer

  process (m_axis_aclk) is
  begin

    if (rising_edge (m_axis_aclk)) then
      if (m_axis_aresetn = '0') then
        read_pointer <= 0;
        tx_done      <= '0';
      else
        if (read_pointer <= number_of_output_words - 1) then
          if (tx_en = '1') then
            -- read pointer is incremented after every read from the FIFO
            -- when FIFO read signal is enabled.
            read_pointer <= read_pointer + 1;
            tx_done      <= '0';
          end if;
        elsif (read_pointer = number_of_output_words) then
          -- tx_done is asserted when NUMBER_OF_OUTPUT_WORDS numbers of streaming data
          -- has been out.
          if (mst_exec_state = send_stream) then
            tx_done <= '1';
          elsif (mst_exec_state = idle) then
            -- reset read pointer
            read_pointer <= 0;
            tx_done      <= '0';
          end if;
        end if;
      end if;
    end if;

  end process;

  -- FIFO read enable generation

  tx_en <= m_axis_tready and axis_tvalid;

  -- FIFO Implementation

  -- Streaming output data is read from FIFO
  axis_fifo : component fifo
    generic map (
      data_width => c_m_axis_tdata_width,
      fifo_depth => fifo_depth
    )
    port map (
      clk    => m_axis_aclk,
      rstn   => m_axis_aresetn,
      wr     => fifo_wr_ena,
      rd     => tx_en,
      din    => fifo_data_in,
      empty  => fifo_empty,
      full   => fifo_full,
      dout   => stream_data_out,
      status => fifo_status
    );

-- Add user logic here

-- User logic ends

end architecture implementation;
