----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 22.08.2021 16:00
-- Design Name: UART_Basys
-- Module Name: UART_TOP_TB - sim
-- Target Devices: Basys3 Board
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TOP_TB is
end UART_TOP_TB;

architecture sim of UART_TOP_TB is
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal UART_RX   : std_logic;
    signal UART_TX   : std_logic;
    signal Switches  : std_logic_vector (7 downto 0);
    signal Button_T    : std_logic := '0';
    signal display     : std_logic_vector (6 downto 0);
    signal enable      : std_logic_vector (3 downto 0);

    constant ClockFrequencyHz : integer := 100000000; -- 100 MHz
    constant ClockPeriod      : time := 1000 ms / ClockFrequencyHz;
begin

    UUT: entity work.UART_TOP(rtl)
    port map(
    clk         => clk,
    rst         => rst,
    UART_RX     => UART_RX,
    UART_TX     => UART_TX,
    Switches    => Switches,
    Button_T    => Button_T,
    display     => display,
    enable      => enable);
    
    clk <= not clk after ClockPeriod / 2;

	process is
	begin
        wait until rising_edge(clk);
       	wait until rising_edge(clk);
        Switches <= x"33";
		wait until rising_edge(clk);
        Button_T <= '1';
		wait for 15 ms;
		Button_T <= '0';
        wait;
    end process;

end sim;
