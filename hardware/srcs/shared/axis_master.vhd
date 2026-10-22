library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.shared_param.all;

entity axis_master is
  generic (
    DATA_WIDTH     : integer := 64;
    REGISTER_WIDTH : integer := 32;
    FIFO_DEPTH     : integer := 14
  );
  port (
    fifo_status    : out   std_logic_vector(REGISTER_WIDTH - 1 downto 0);
    fifo_data_in   : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
    fifo_wr_ena    : in    std_logic;
    fifo_full      : out   std_logic;
    packet_length  : in    std_logic_vector(REGISTER_WIDTH - 1 downto 0);
    m_axis_aclk    : in    std_logic;
    m_axis_aresetn : in    std_logic;
    m_axis_tvalid  : out   std_logic;
    m_axis_tdata   : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
    m_axis_tstrb   : out   std_logic_vector((DATA_WIDTH / 8) - 1 downto 0);
    m_axis_tlast   : out   std_logic;
    m_axis_tready  : in    std_logic
  );
end entity axis_master;

architecture implementation of axis_master is

  signal fifo_read  : std_logic;
  signal fifo_empty : std_logic;

  signal tvalid : std_logic;
  signal tlast  : std_logic;

  signal transfer_counter : unsigned(REGISTER_WIDTH - 1 downto 0);
  signal packet_size      : unsigned(REGISTER_WIDTH - 1 downto 0);

begin

  m_axis_tstrb  <= (others => '1');
  m_axis_tlast  <= tlast;
  m_axis_tvalid <= tvalid;

  packet_size <= unsigned(packet_length);

  fifo_read <= '1' when (fifo_empty = '0' and (tvalid = '0' or m_axis_tready = '1')) else
               '0';

  tvalid_control : process (m_axis_aclk) is
  begin

    if (rising_edge(m_axis_aclk)) then
      if (m_axis_aresetn = '0') then
        tvalid <= '0';
      else
        if (fifo_read = '1') then
          tvalid <= '1';
        elsif (m_axis_tready = '1') then
          tvalid <= '0';
        end if;
      end if;
    end if;

  end process tvalid_control;

  tlast <= '1' when (tvalid = '1' and packet_size /= 0 and
                     transfer_counter >= packet_size) else
           '0';

  tlast_control : process (m_axis_aclk) is
  begin

    if (rising_edge(m_axis_aclk)) then
      if (m_axis_aresetn = '0') then
        transfer_counter <= (others => '0');
      elsif (tvalid = '1' and m_axis_tready = '1') then
        if (packet_size = 0 or tlast = '1') then
          transfer_counter <= (others => '0');
        else
          transfer_counter <= transfer_counter + 1;
        end if;
      end if;
    end if;

  end process tlast_control;

  axis_fifo : component fifo
    generic map (
      data_width   => DATA_WIDTH,
      status_width => REGISTER_WIDTH,
      fifo_depth   => FIFO_DEPTH
    )
    port map (
      clk    => m_axis_aclk,
      rstn   => m_axis_aresetn,
      wr     => fifo_wr_ena,
      rd     => fifo_read,
      din    => fifo_data_in,
      empty  => fifo_empty,
      full   => fifo_full,
      dout   => m_axis_tdata,
      status => fifo_status
    );

end architecture implementation;
