----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 22.08.2021 16:00
-- Design Name: UART_Basys
-- Module Name: UART_TOP - rtl
-- Target Devices: Basys3 Board
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TOP is
    Port ( 
    -- Main Clock (100 MHz)
    clk      : in std_logic;
    rst      : in std_logic;
    -- UART TX/RX Data
    UART_RX  : in std_logic;
    UART_TX  : out std_logic;
    -- INPUT DATA FROM SWITCHES AND BUTTON
    Switches : in std_logic_vector (7 downto 0);
    Button_T : in std_logic;
    -- HEX DISPLAY
    display  : out std_logic_vector (6 downto 0);
    enable   : out std_logic_vector (3 downto 0));
end UART_TOP;

architecture rtl of UART_TOP is
    signal UART_RX_VALID : std_logic;
    signal UART_RX_BYTE  : std_logic_vector(7 downto 0);
    signal button        : std_logic;
    signal button2       : std_logic := '0';
    signal re_button     : std_logic := '0';

    -- Signals for 7-SEG DISPLAY
    signal Seg_0, Seg_1, Seg_2, Seg_3   : std_logic_vector (6 downto 0);
	signal toggle		                : std_logic_vector(3 downto 0) := "1110";
    signal refresh_cnt  	            : integer := 0;
    constant refresh_max	            : integer := 200000; -- 500 Hz
    
begin
    enable  <= toggle;

    UART_Recieve_Mod : entity work.UART_Receive
    generic map (
        Clock_Frequency => 100000000,
        UART_Baud_Rate  => 115200)
    port map (
        clk             => clk,
        UART_RX         => UART_RX,
        UART_RX_VALID   => UART_RX_VALID,
        UART_RX_BYTE    => UART_RX_BYTE);

    UART_Transmit_Mod : entity work.UART_Transmit
    generic map (
        Clock_Frequency => 100000000,
        UART_Baud_Rate  => 115200)
    port map (
        clk             => clk,
        UART_TX_BYTE    => Switches,
        UART_TX_VALID   => re_button,
        UART_TX         => UART_TX);

    BUT_Debounce : entity work.Debounce
    port map(
        clk        => clk,
        button_in  => Button_T,
        button_out => button);


    Seg0 : entity work.Hex2seg
    port map(
        hex => UART_RX_BYTE(3 downto 0),
        seg => Seg_0);

    Seg1 : entity work.Hex2seg
    port map(
        hex => UART_RX_BYTE(7 downto 4),
        seg => Seg_1);

    Seg2 : entity work.Hex2seg
    port map(
        hex => Switches(3 downto 0),
        seg => Seg_2);

    Seg3 : entity work.Hex2seg
    port map(
        hex => Switches(7 downto 4),
        seg => Seg_3);

-- Process responsible for detecting rising edge on a T button
risinge_button : process (clk)
begin
    if(rising_edge(clk)) then
        button2 <= button;
        if (button = '1' and button2 = '0') then
            re_button <= '1';
        else
            re_button <= '0';
        end if;
    end if;
end process risinge_button;

-- HEX 7 - SEGMENT DISPLAY processes
refresh_counter: process(clk)
begin
    if(rising_edge(clk)) then
        if(refresh_cnt = refresh_max - 1) then
            refresh_cnt <= 0;
        else 
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end if;
end process refresh_counter;

toggle_count_proc: process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            toggle <= toggle;
        elsif(refresh_cnt = refresh_max - 1) then
            toggle <=  toggle(2 downto 0) & toggle(3);
        end if;
    end if;
end process toggle_count_proc;
    
    
toggle_proc: process(toggle,Seg_0,Seg_1,Seg_2,Seg_3)
begin
        if(toggle(0) = '0') then
            display <= Seg_0;
        elsif(toggle(1) = '0') then
            display <= Seg_1;
        elsif(toggle(2) = '0') then
            display <= Seg_2;
        elsif(toggle(3) = '0') then
            display <= Seg_3;
        else
            display <= (others => '0');
        end if;
end process toggle_proc;

end rtl;


