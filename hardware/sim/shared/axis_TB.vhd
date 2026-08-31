library ieee;
  use ieee.std_logic_1164.all;

entity axis_tb is
  generic (
    data_width : positive := 64
  );
end entity axis_tb;

architecture behavioral of axis_tb is

  component pn23 is
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
  end component pn23;

  component axis_master is
    generic (
      c_m_axis_tdata_width : integer  := 64;
      c_m_start_count      : integer  := 32;
      register_width       : integer := 32;
      fifo_depth           : integer := 14
    );
    port (
      fifo_status   : out   std_logic_vector(register_width - 1 downto 0);
      fifo_data_in  : in    std_logic_vector(c_m_axis_tdata_width - 1 downto 0);
      fifo_wr_ena   : in    std_logic;
      fifo_full     : out   std_logic;
      packet_length : in    std_logic_vector(register_width - 1 downto 0);

      m_axis_aclk    : in    std_logic;
      m_axis_aresetn : in    std_logic;
      m_axis_tvalid  : out   std_logic;
      m_axis_tdata   : out   std_logic_vector(c_m_axis_tdata_width - 1 downto 0);
      m_axis_tstrb   : out   std_logic_vector((c_m_axis_tdata_width / 8) - 1 downto 0);
      m_axis_tlast   : out   std_logic;
      m_axis_tready  : in    std_logic
    );
  end component axis_master;

  component axis_slave is
    generic (
      c_s_axis_tdata_width : integer  := 32;
      fifo_status_width    : integer := 32;
      fifo_depth           : integer := 14
    );
    port (
      fifo_status   : out   std_logic_vector(fifo_status_width - 1 downto 0);
      fifo_data_out : out   std_logic_vector(c_s_axis_tdata_width - 1 downto 0);
      fifo_rd_ena   : in    std_logic;
      fifo_empty    : out   std_logic;

      s_axis_aclk    : in    std_logic;
      s_axis_aresetn : in    std_logic;
      s_axis_tready  : out   std_logic;
      s_axis_tdata   : in    std_logic_vector(c_s_axis_tdata_width - 1 downto 0);
      s_axis_tstrb   : in    std_logic_vector((c_s_axis_tdata_width / 8) - 1 downto 0);
      s_axis_tlast   : in    std_logic;
      s_axis_tvalid  : in    std_logic
    );
  end component axis_slave;

  signal clk   : std_logic;
  signal rstn  : std_logic;
  signal value : std_logic_vector(data_width - 1 downto 0);
  signal ready : std_logic;

  signal fifo_status : std_logic_vector(32 - 1 downto 0);

  signal axis_tdata  : std_logic_vector(data_width - 1 downto 0);
  signal axis_tvalid : std_logic;
  signal axis_tstrb  : std_logic_vector((data_width / 8) - 1 downto 0);
  signal axis_tlast  : std_logic;
  signal axis_tready : std_logic;

  signal sig_fifo_empty    : std_logic;
  signal sig_fifo_status   : std_logic_vector(32 - 1 downto 0);
  signal sig_fifo_data_out : std_logic_vector(data_width - 1 downto 0);

  signal pn23_hold : std_logic;

begin

  clk <= not clk after 10 ns;

  run : process is
  begin

    rstn <= '0';
    wait for 40 ns;
    rstn <= '1';
    wait for 20us;

  end process run;

  test : component pn23
    port map (
      clk   => clk,
      rstn  => rstn,
      hold  => pn23_hold,
      value => value,
      valid => ready
    );

  axis_c2h : component axis_master
    generic map (
      c_m_axis_tdata_width => data_width,
      c_m_start_count      => 8,
      register_width       => 32,
      fifo_depth           => 5
    )
    port map (
      fifo_status    => fifo_status,
      fifo_data_in   => value,
      fifo_wr_ena    => ready,
      fifo_full      => pn23_hold,
      packet_length  => x"00000009",
      m_axis_aclk    => clk,
      m_axis_aresetn => rstn,
      m_axis_tvalid  => axis_tvalid,
      m_axis_tdata   => axis_tdata,
      m_axis_tstrb   => axis_tstrb,
      m_axis_tlast   => axis_tlast,
      m_axis_tready  => axis_tready
    );

  axis_slave_inst : component axis_slave
    generic map (
      c_s_axis_tdata_width => data_width,
      fifo_status_width    => 32,
      fifo_depth           => 5
    )
    port map (
      fifo_status    => sig_fifo_status,
      fifo_data_out  => sig_fifo_data_out,
      fifo_rd_ena    => '1',
      fifo_empty     => sig_fifo_empty,
      s_axis_aclk    => clk,
      s_axis_aresetn => rstn,
      s_axis_tvalid  => axis_tvalid,
      s_axis_tdata   => axis_tdata,
      s_axis_tstrb   => axis_tstrb,
      s_axis_tlast   => axis_tlast,
      s_axis_tready  => axis_tready
    );

end architecture behavioral;
