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

  signal fifo_full_flag : std_logic;
  signal fifo_wren : std_logic;
  signal axis_tready : std_logic;

begin

  axis_tready <= s_axis_aresetn and not(fifo_full_flag);
  s_axis_tready <= axis_tready;

  fifo_wren <= s_axis_tvalid and axis_tready;

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
