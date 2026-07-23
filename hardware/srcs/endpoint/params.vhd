library ieee;
  use ieee.math_real.all;
  use ieee.std_logic_1164.all;

-- Package declartion
package utils_param is

  component fifo is
    generic (
      data_width : positive := 32;
      fifo_depth : positive := 5
    );
    port (
      clk    : in    std_logic;
      rstn   : in    std_logic;
      wr     : in    std_logic;
      rd     : in    std_logic;
      din    : in    std_logic_vector(DATA_WIDTH - 1 downto 0);
      empty  : out   std_logic;
      full   : out   std_logic;
      dout   : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
      status : out   std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component fifo;

  component pn23 is
    generic (
      data_width   : positive := 32;
      bits_per_clk : positive := 16
    );
    port (
      clk   : in    std_logic;
      rstn  : in    std_logic;
      value : out   std_logic_vector(DATA_WIDTH - 1 downto 0);
      ready : out   std_logic
    );
  end component pn23;

  component axis_master is
    generic (
      -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
      c_m_axis_tdata_width : integer  := 32;
      -- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
      c_m_start_count : integer  := 32;
      -- FIFO depth
      fifo_depth : integer := 14
    );
    port (
      -- FIFO ports
      fifo_status  : out   std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
      fifo_data_in : in    std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
      fifo_wr_ena  : in    std_logic;

      -- Global ports
      m_axis_aclk : in    std_logic;
      --
      m_axis_aresetn : in    std_logic;
      -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted.
      m_axis_tvalid : out   std_logic;
      -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
      m_axis_tdata : out   std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
      -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
      m_axis_tstrb : out   std_logic_vector((C_M_AXIS_TDATA_WIDTH / 8) - 1 downto 0);
      -- TLAST indicates the boundary of a packet.
      m_axis_tlast : out   std_logic;
      -- TREADY indicates that the slave can accept a transfer in the current cycle.
      m_axis_tready : in    std_logic
    );
  end component axis_master;

end package utils_param;

-- Body section

package body utils_param is

end package body utils_param;
