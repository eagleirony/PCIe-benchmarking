library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity axil_bus is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Width of S_AXI data bus
    c_s_axi_data_width : integer := 32;
    -- Width of S_AXI address bus
    c_s_axi_addr_width : integer := 8
  );
  port (
    -- Users to add ports here

    -- User ports ends

    -- Read only ports
    reg_6_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    reg_7_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    reg_8_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    reg_9_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    reg_10_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    --reg_11_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    --reg_12_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);

    -- Read Write ports
    --reg_32_r : in std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    --reg_32_w : out std_logic_vector(c_s_axi_addr_width - 1 downto 0);

    -- Do not modify the ports beyond this line

    -- Global Clock Signal
    s_axi_aclk : in    std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    s_axi_aresetn : in    std_logic;
    -- Write address (issued by master, acceped by Slave)
    s_axi_awaddr : in    std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    s_axi_awprot : in    std_logic_vector(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    s_axi_awvalid : in    std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    s_axi_awready : out   std_logic;
    -- Write data (issued by master, acceped by Slave)
    s_axi_wdata : in    std_logic_vector(c_s_axi_data_width - 1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.
    s_axi_wstrb : in    std_logic_vector((c_s_axi_data_width / 8) - 1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    s_axi_wvalid : in    std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    s_axi_wready : out   std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    s_axi_bresp : out   std_logic_vector(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    s_axi_bvalid : out   std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    s_axi_bready : in    std_logic;
    -- Read address (issued by master, acceped by Slave)
    s_axi_araddr : in    std_logic_vector(c_s_axi_addr_width - 1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    s_axi_arprot : in    std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    s_axi_arvalid : in    std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    s_axi_arready : out   std_logic;
    -- Read data (issued by slave)
    s_axi_rdata : out   std_logic_vector(c_s_axi_data_width - 1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    s_axi_rresp : out   std_logic_vector(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    s_axi_rvalid : out   std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    s_axi_rready : in    std_logic
  );
end entity axil_bus;

architecture arch_imp of axil_bus is

  -- AXI4LITE signals
  signal axi_awaddr  : std_logic_vector(c_s_axi_addr_width - 1 downto 0);
  signal axi_awready : std_logic;
  signal axi_wready  : std_logic;
  signal axi_bresp   : std_logic_vector(1 downto 0);
  signal axi_bvalid  : std_logic;
  signal axi_araddr  : std_logic_vector(c_s_axi_addr_width - 1 downto 0);
  signal axi_arready : std_logic;
  signal axi_rresp   : std_logic_vector(1 downto 0);
  signal axi_rvalid  : std_logic;

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant addr_lsb          : integer := (c_s_axi_data_width / 32) + 1;
  constant opt_mem_addr_bits : integer := 5;
  ------------------------------------------------
  ---- Signals for user logic register space example
  --------------------------------------------------
  ---- Number of Slave Registers 64
  signal slv_reg0   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg1   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg2   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg3   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg4   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg5   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg6   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg7   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg8   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg9   : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg10  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg11  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg12  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg13  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg14  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg15  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg16  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg17  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg18  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg19  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg20  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg21  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg22  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg23  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg24  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg25  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg26  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg27  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg28  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg29  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg30  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg31  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg32  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg33  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg34  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg35  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg36  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg37  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg38  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg39  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg40  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg41  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg42  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg43  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg44  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg45  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg46  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg47  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg48  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg49  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg50  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg51  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg52  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg53  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg54  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg55  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg56  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg57  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg58  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg59  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg60  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg61  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg62  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal slv_reg63  : std_logic_vector(c_s_axi_data_width - 1 downto 0);
  signal byte_index : integer;

  signal mem_logic : std_logic_vector(addr_lsb + opt_mem_addr_bits downto addr_lsb);

  -- State machine local parameters
  constant idle  : std_logic_vector(1 downto 0) := "00";
  constant raddr : std_logic_vector(1 downto 0) := "10";
  constant rdata : std_logic_vector(1 downto 0) := "11";
  constant waddr : std_logic_vector(1 downto 0) := "10";
  constant wdata : std_logic_vector(1 downto 0) := "11";
  -- State machine variables
  signal state_read  : std_logic_vector(1 downto 0);
  signal state_write : std_logic_vector(1 downto 0);

begin

  -- I/O Connections assignments

  s_axi_awready <= axi_awready;
  s_axi_wready  <= axi_wready;
  s_axi_bresp   <= axi_bresp;
  s_axi_bvalid  <= axi_bvalid;
  s_axi_arready <= axi_arready;
  s_axi_rresp   <= axi_rresp;
  s_axi_rvalid  <= axi_rvalid;
  mem_logic     <= s_axi_awaddr(addr_lsb + opt_mem_addr_bits downto addr_lsb)
                   when (s_axi_awvalid = '1') else
                   axi_awaddr(addr_lsb + opt_mem_addr_bits downto addr_lsb);

  -- Implement Write state machine
  -- Outstanding write transactions are not supported by the slave i.e.,
  -- master should assert bready to receive response on or before it starts
  -- sending the new transaction
  process (s_axi_aclk) is
  begin

    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        -- asserting initial values to all 0's during reset
        axi_awready <= '0';
        axi_wready  <= '0';
        axi_bvalid  <= '0';
        axi_bresp   <= (others => '0');
        state_write <= idle;
      else

        case (state_write) is

          when idle =>

            -- Initial state inidicating reset is done and ready to receive
            -- read/write transactions

            if (s_axi_aresetn = '1') then
              axi_awready <= '1';
              axi_wready  <= '1';
              state_write <= waddr;
            else
              state_write <= state_write;
            end if;

          when waddr =>

            -- At this state, slave is ready to receive address along with
            -- corresponding control signals and first data packet. Response
            -- valid is also handled at this state

            if (s_axi_awvalid = '1' and axi_awready = '1') then
              axi_awaddr <= s_axi_awaddr;
              if (s_axi_wvalid = '1') then
                axi_awready <= '1';
                state_write <= waddr;
                axi_bvalid  <= '1';
              else
                axi_awready <= '0';
                state_write <= wdata;
                if (s_axi_bready = '1' and axi_bvalid = '1') then
                  axi_bvalid <= '0';
                end if;
              end if;
            else
              state_write <= state_write;
              if (s_axi_bready = '1' and axi_bvalid = '1') then
                axi_bvalid <= '0';
              end if;
            end if;

          when wdata =>

            -- At this state, slave is ready to receive the data packets until
            -- the number of transfers is equal to burst length

            if (s_axi_wvalid = '1') then
              state_write <= waddr;
              axi_bvalid  <= '1';
              axi_awready <= '1';
            else
              state_write <= state_write;
              if (s_axi_bready = '1' and axi_bvalid = '1') then
                axi_bvalid <= '0';
              end if;
            end if;

          when others =>

            -- reserved

            axi_awready <= '0';
            axi_wready  <= '0';
            axi_bvalid  <= '0';

        end case;

      end if;
    end if;

  end process;

  -- Implement memory mapped register select and write logic generation
  -- The write data is accepted and written to memory mapped registers when
  -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  -- select byte enables of slave registers while writing.
  -- These registers are cleared when reset (active low) is applied.
  -- Slave register write enable is asserted when valid address and data are available
  -- and the slave is ready to accept the write address and write data.

  process (s_axi_aclk) is
  begin

    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        slv_reg0  <= x"55AA55AA";
        slv_reg1  <= x"AA55AA55";
        slv_reg2  <= x"00000000";
        slv_reg3  <= x"FFFFFFFF";
        slv_reg4  <= x"01234567";
        slv_reg5  <= x"89abcdef";
        slv_reg6  <= (others => '0');
        slv_reg7  <= (others => '0');
        slv_reg8  <= (others => '0');
        slv_reg9  <= (others => '0');
        slv_reg10 <= (others => '0');
        slv_reg11 <= (others => '0');
        slv_reg12 <= (others => '0');
        slv_reg13 <= (others => '0');
        slv_reg14 <= (others => '0');
        slv_reg15 <= (others => '0');
        slv_reg16 <= (others => '0');
        slv_reg17 <= (others => '0');
        slv_reg18 <= (others => '0');
        slv_reg19 <= (others => '0');
        slv_reg20 <= (others => '0');
        slv_reg21 <= (others => '0');
        slv_reg22 <= (others => '0');
        slv_reg23 <= (others => '0');
        slv_reg24 <= (others => '0');
        slv_reg25 <= (others => '0');
        slv_reg26 <= (others => '0');
        slv_reg27 <= (others => '0');
        slv_reg28 <= (others => '0');
        slv_reg29 <= (others => '0');
        slv_reg30 <= (others => '0');
        slv_reg31 <= (others => '0');
        slv_reg32 <= (others => '0');
        slv_reg33 <= (others => '0');
        slv_reg34 <= (others => '0');
        slv_reg35 <= (others => '0');
        slv_reg36 <= (others => '0');
        slv_reg37 <= (others => '0');
        slv_reg38 <= (others => '0');
        slv_reg39 <= (others => '0');
        slv_reg40 <= (others => '0');
        slv_reg41 <= (others => '0');
        slv_reg42 <= (others => '0');
        slv_reg43 <= (others => '0');
        slv_reg44 <= (others => '0');
        slv_reg45 <= (others => '0');
        slv_reg46 <= (others => '0');
        slv_reg47 <= (others => '0');
        slv_reg48 <= (others => '0');
        slv_reg49 <= (others => '0');
        slv_reg50 <= (others => '0');
        slv_reg51 <= (others => '0');
        slv_reg52 <= (others => '0');
        slv_reg53 <= (others => '0');
        slv_reg54 <= (others => '0');
        slv_reg55 <= (others => '0');
        slv_reg56 <= (others => '0');
        slv_reg57 <= (others => '0');
        slv_reg58 <= (others => '0');
        slv_reg59 <= (others => '0');
        slv_reg60 <= (others => '0');
        slv_reg61 <= (others => '0');
        slv_reg62 <= (others => '0');
        slv_reg63 <= (others => '0');
      else
        if (s_axi_wvalid = '1') then

          case (mem_logic) is

            when b"000000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 0
                  -- slv_reg0(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"000001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 1
                  -- slv_reg1(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"000010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 2
                  -- slv_reg2(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"000011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 3
                  -- slv_reg3(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"000100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 4
                  -- slv_reg4(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"000101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 5
                  -- slv_reg5(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"000110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 6
                  -- slv_reg6(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"000111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 7
                  -- slv_reg7(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"001000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 8
                  -- slv_reg8(byte_index * 8 + 7 downto byte_index * 8) <=
                  --  s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);

                  -- READ ONLY
                end if;

              end loop;

            when b"001001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 9
                  slv_reg9(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 10
                  slv_reg10(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 11
                  slv_reg11(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 12
                  slv_reg12(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 13
                  slv_reg13(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 14
                  slv_reg14(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"001111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 15
                  slv_reg15(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 16
                  slv_reg16(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 17
                  slv_reg17(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 18
                  slv_reg18(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 19
                  slv_reg19(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 20
                  slv_reg20(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 21
                  slv_reg21(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 22
                  slv_reg22(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"010111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 23
                  slv_reg23(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 24
                  slv_reg24(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 25
                  slv_reg25(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 26
                  slv_reg26(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 27
                  slv_reg27(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 28
                  slv_reg28(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 29
                  slv_reg29(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 30
                  slv_reg30(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"011111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 31
                  slv_reg31(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 32
                  slv_reg32(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 33
                  slv_reg33(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 34
                  slv_reg34(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 35
                  slv_reg35(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 36
                  slv_reg36(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 37
                  slv_reg37(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 38
                  slv_reg38(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"100111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 39
                  slv_reg39(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 40
                  slv_reg40(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 41
                  slv_reg41(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 42
                  slv_reg42(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 43
                  slv_reg43(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 44
                  slv_reg44(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 45
                  slv_reg45(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 46
                  slv_reg46(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"101111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 47
                  slv_reg47(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 48
                  slv_reg48(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 49
                  slv_reg49(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 50
                  slv_reg50(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 51
                  slv_reg51(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 52
                  slv_reg52(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 53
                  slv_reg53(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 54
                  slv_reg54(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"110111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 55
                  slv_reg55(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111000" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 56
                  slv_reg56(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111001" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 57
                  slv_reg57(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111010" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 58
                  slv_reg58(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111011" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 59
                  slv_reg59(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111100" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 60
                  slv_reg60(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111101" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 61
                  slv_reg61(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111110" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 62
                  slv_reg62(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when b"111111" =>

              for byte_index in 0 to (c_s_axi_data_width / 8 - 1) loop

                if (s_axi_wstrb(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes
                  -- slave registor 63
                  slv_reg63(byte_index * 8 + 7 downto byte_index * 8) <=
                    s_axi_wdata(byte_index * 8 + 7 downto byte_index * 8);
                end if;

              end loop;

            when others =>

              slv_reg0  <= slv_reg0;
              slv_reg1  <= slv_reg1;
              slv_reg2  <= slv_reg2;
              slv_reg3  <= slv_reg3;
              slv_reg4  <= slv_reg4;
              slv_reg5  <= slv_reg5;
              slv_reg6  <= slv_reg6;
              slv_reg7  <= slv_reg7;
              slv_reg8  <= slv_reg8;
              slv_reg9  <= slv_reg9;
              slv_reg10 <= slv_reg10;
              slv_reg11 <= slv_reg11;
              slv_reg12 <= slv_reg12;
              slv_reg13 <= slv_reg13;
              slv_reg14 <= slv_reg14;
              slv_reg15 <= slv_reg15;
              slv_reg16 <= slv_reg16;
              slv_reg17 <= slv_reg17;
              slv_reg18 <= slv_reg18;
              slv_reg19 <= slv_reg19;
              slv_reg20 <= slv_reg20;
              slv_reg21 <= slv_reg21;
              slv_reg22 <= slv_reg22;
              slv_reg23 <= slv_reg23;
              slv_reg24 <= slv_reg24;
              slv_reg25 <= slv_reg25;
              slv_reg26 <= slv_reg26;
              slv_reg27 <= slv_reg27;
              slv_reg28 <= slv_reg28;
              slv_reg29 <= slv_reg29;
              slv_reg30 <= slv_reg30;
              slv_reg31 <= slv_reg31;
              slv_reg32 <= slv_reg32;
              slv_reg33 <= slv_reg33;
              slv_reg34 <= slv_reg34;
              slv_reg35 <= slv_reg35;
              slv_reg36 <= slv_reg36;
              slv_reg37 <= slv_reg37;
              slv_reg38 <= slv_reg38;
              slv_reg39 <= slv_reg39;
              slv_reg40 <= slv_reg40;
              slv_reg41 <= slv_reg41;
              slv_reg42 <= slv_reg42;
              slv_reg43 <= slv_reg43;
              slv_reg44 <= slv_reg44;
              slv_reg45 <= slv_reg45;
              slv_reg46 <= slv_reg46;
              slv_reg47 <= slv_reg47;
              slv_reg48 <= slv_reg48;
              slv_reg49 <= slv_reg49;
              slv_reg50 <= slv_reg50;
              slv_reg51 <= slv_reg51;
              slv_reg52 <= slv_reg52;
              slv_reg53 <= slv_reg53;
              slv_reg54 <= slv_reg54;
              slv_reg55 <= slv_reg55;
              slv_reg56 <= slv_reg56;
              slv_reg57 <= slv_reg57;
              slv_reg58 <= slv_reg58;
              slv_reg59 <= slv_reg59;
              slv_reg60 <= slv_reg60;
              slv_reg61 <= slv_reg61;
              slv_reg62 <= slv_reg62;
              slv_reg63 <= slv_reg63;

          end case;

        end if;
      end if;
    end if;

  end process;

  -- Implement read state machine
  process (s_axi_aclk) is
  begin

    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        -- asserting initial values to all 0's during reset
        axi_arready <= '0';
        axi_rvalid  <= '0';
        axi_rresp   <= (others => '0');
        state_read  <= idle;
      else

        case (state_read) is

          when idle =>
            -- Initial state inidicating reset is done and ready to receive read/write transactions

            if (s_axi_aresetn = '1') then
              axi_arready <= '1';
              state_read  <= raddr;
            else
              state_read <= state_read;
            end if;

          when raddr =>
            -- At this state, slave is ready to receive address along with corresponding control signals

            if (s_axi_arvalid = '1' and axi_arready = '1') then
              state_read  <= rdata;
              axi_rvalid  <= '1';
              axi_arready <= '0';
              axi_araddr  <= s_axi_araddr;
            else
              state_read <= state_read;
            end if;

          when rdata =>
            -- At this state, slave is ready to send the data packets until the number of transfers is equal to burst length

            if (axi_rvalid = '1' and s_axi_rready = '1') then
              axi_rvalid  <= '0';
              axi_arready <= '1';
              state_read  <= raddr;
            else
              state_read <= state_read;
            end if;

          when others =>
            -- reserved

            axi_arready <= '0';
            axi_rvalid  <= '0';

        end case;

      end if;
    end if;

  end process;

  -- Implement memory mapped register select and read logic generation
  s_axi_rdata <= slv_reg0 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000000") else
                 slv_reg1 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000001") else
                 slv_reg2 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000010") else
                 slv_reg3 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000011") else
                 slv_reg4 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000100") else
                 slv_reg5 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000101") else
                 slv_reg6 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000110") else
                 slv_reg7 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "000111") else
                 slv_reg8 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001000") else
                 slv_reg9 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001001") else
                 slv_reg10 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001010") else
                 slv_reg11 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001011") else
                 slv_reg12 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001100") else
                 slv_reg13 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001101") else
                 slv_reg14 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001110") else
                 slv_reg15 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "001111") else
                 slv_reg16 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010000") else
                 slv_reg17 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010001") else
                 slv_reg18 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010010") else
                 slv_reg19 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010011") else
                 slv_reg20 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010100") else
                 slv_reg21 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010101") else
                 slv_reg22 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010110") else
                 slv_reg23 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "010111") else
                 slv_reg24 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011000") else
                 slv_reg25 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011001") else
                 slv_reg26 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011010") else
                 slv_reg27 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011011") else
                 slv_reg28 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011100") else
                 slv_reg29 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011101") else
                 slv_reg30 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011110") else
                 slv_reg31 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "011111") else
                 slv_reg32 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100000") else
                 slv_reg33 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100001") else
                 slv_reg34 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100010") else
                 slv_reg35 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100011") else
                 slv_reg36 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100100") else
                 slv_reg37 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100101") else
                 slv_reg38 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100110") else
                 slv_reg39 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "100111") else
                 slv_reg40 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101000") else
                 slv_reg41 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101001") else
                 slv_reg42 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101010") else
                 slv_reg43 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101011") else
                 slv_reg44 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101100") else
                 slv_reg45 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101101") else
                 slv_reg46 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101110") else
                 slv_reg47 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "101111") else
                 slv_reg48 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110000") else
                 slv_reg49 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110001") else
                 slv_reg50 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110010") else
                 slv_reg51 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110011") else
                 slv_reg52 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110100") else
                 slv_reg53 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110101") else
                 slv_reg54 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110110") else
                 slv_reg55 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "110111") else
                 slv_reg56 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111000") else
                 slv_reg57 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111001") else
                 slv_reg58 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111010") else
                 slv_reg59 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111011") else
                 slv_reg60 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111100") else
                 slv_reg61 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111101") else
                 slv_reg62 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111110") else
                 slv_reg63 when (axi_araddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) = "111111") else
                 (others => '0');

-- Add user logic here

-- User logic ends

end architecture arch_imp;
