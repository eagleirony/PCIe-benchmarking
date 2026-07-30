----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.05.2026 20:52:53
-- Design Name: 
-- Module Name: pn23_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pn23_TB is
        generic (
            DATA_WIDTH : positive := 64
        );
end pn23_TB;

architecture Behavioral of pn23_TB is

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

    signal clk : std_logic := '0';
    signal rstn : std_logic := '0';
    signal value : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal hold : std_logic;
    signal valid : std_logic;

begin

    clk <= not clk after 10 ns;

    process is
    begin
      rstn <= '0';
      hold <= '0';
      wait for 40 ns;
      rstn <= '1';
      wait for 80 ns;
      hold <= '1';
      wait for 40 ns;
      hold <= '0';
      wait for 10us;
    end process;

    test: pn23 port map (
        clk => clk,
        rstn => rstn,
        hold => hold,
        valid => valid,
        value => value
    );

end Behavioral;
