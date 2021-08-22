----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 22.08.2021 16:00
-- Design Name: UART_Basys
-- Module Name: UART_Transmit - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity UART_Transmit is
    generic (
        Clock_Frequency : integer := 100000000; -- 100 MHz clock
        UART_Baud_Rate  : integer := 115200);
    port (
        clk             : in  std_logic;
        UART_TX_BYTE    : in std_logic_vector(7 downto 0);
        UART_TX_VALID   : in std_logic;
        UART_TX         : out std_logic);
end UART_Transmit;

architecture rtl of UART_Transmit is
        -- Declaring state machine
        type t_State is (Wait_Valid, TX_Start_Bit, TX_Data_Byte,TX_Stop_Bit, Clean);
        signal State        : t_State := Wait_Valid;
        -- Counter
        constant Cnt_max    : integer := Clock_Frequency/UART_Baud_Rate;  
        signal cnt          : integer range 0 to Cnt_max-1 := 0;
        signal Data_Index   : integer range 0 to 7 := 0;  -- 8 Bits Total
        signal TX_Byte      : std_logic_vector(7 downto 0) := (others => '0');
        signal TX_VALID     : std_logic := '0';

begin

UART_Transmit_Process : process (clk)
begin
  if rising_edge(clk) then
      
    case State is
    -- State Wait_Valid - waiting for the flag informing that the data is ready to be sent (TX_VALID)
      when Wait_Valid =>
        UART_TX    <= '1';
        cnt        <= 0;
        Data_Index <= 0;
        if TX_VALID = '1' then -- Data is ready to be sent
          State <= TX_Start_Bit;
        else
          State <= Wait_Valid;
        end if;
      -- State TX_Start_Bit - Sending a start bit (0)
      when TX_Start_Bit =>
            UART_TX <= '0';
            if cnt = Cnt_max - 1 then
                cnt     <= 0;
                State   <= TX_Data_Byte;
                TX_Byte <= UART_TX_BYTE;
            else
                cnt   <= cnt + 1;
                State <= TX_Start_Bit;
            end if;
      -- State TX_Data_Byte - Sending 1 BYTE 
      when TX_Data_Byte =>
        UART_TX <= TX_Byte(Data_Index);
        if cnt < Cnt_max - 1 then
            cnt   <= cnt + 1;
            State <= TX_Data_Byte;
        else
            cnt   <= 0;
            if Data_Index < 7 then
                Data_Index <= Data_Index + 1;
                State      <= TX_Data_Byte;
            else
                Data_Index <= 0;
                State      <= TX_Stop_Bit;
            end if;
        end if;
    -- State TX_Stop_Bit - sending a stop bit (1)
      when TX_Stop_Bit =>
        UART_TX <= '1';
        if cnt < Cnt_max-1 then
          cnt <= cnt + 1;
          State   <= TX_Stop_Bit;
        else
          cnt <= 0;
          State   <= Clean;
        end if;
      -- State Clean - waiting for 1 clock cycle to get back to the Wait_Valid state
      when Clean =>
        State <= Wait_Valid;
      when others =>
        State <= Wait_Valid;
    end case;
  end if;
end process UART_Transmit_Process;

TX_VALID <= UART_TX_VALID;
end rtl;
