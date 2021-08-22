----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 22.08.2021 16:00
-- Design Name: UART_Basys
-- Module Name: UART_Receive - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity UART_Receive is
  generic (
    Clock_Frequency   : integer := 100000000; -- 100 MHz clock
    UART_Baud_Rate    : integer := 115200);
  port (  
    clk               : in  std_logic;
    UART_RX           : in  std_logic;
    UART_RX_VALID     : out std_logic;
    UART_RX_BYTE      : out std_logic_vector(7 downto 0));
end UART_Receive;

architecture rtl of UART_Receive is
    -- Declaring state machine
    type t_State is (Wait_SB, RX_Start_Bit, RX_Data_Byte,RX_Stop, Clean);
    signal State      : t_State := Wait_SB;
    -- Counter
    constant Cnt_max  : integer := Clock_Frequency/UART_Baud_Rate;  
    signal cnt        : integer range 0 to Cnt_max-1 := 0;
    signal Data_Index : integer range 0 to 7 := 0; 
    signal RX_Byte    : std_logic_vector(7 downto 0) := (others => '0');
    signal RX_VALID   : std_logic := '0';

begin

UART_Receive_Process : process (clk)
begin
  if rising_edge(clk) then
      
    case State is
      -- State Wait_SB - waiting for the data (start bit)
      when Wait_SB =>
        RX_VALID   <= '0';
        cnt        <= 0;
        Data_Index <= 0;
        if UART_RX = '0' then       -- Start bit detected
          State <= RX_Start_Bit;
        else
          State <= Wait_SB;
        end if;
      -- State RX_Start_Bit - Start bit received -> Waiting half of the counter time to sample the bit
      when RX_Start_Bit =>
        if cnt = (Cnt_max-1)/2 then
          if UART_RX = '0' then
            cnt   <= 0;
            State <= RX_Data_Byte;
          else
            State <= Wait_SB;
          end if;
        else
          cnt   <= cnt + 1;
          State <= RX_Start_Bit;
        end if;
      -- State RX_Data_Byte - Receiving 8 bites of data
      when RX_Data_Byte =>
        if cnt < Cnt_max-1 then
          cnt   <= cnt + 1;
          State <= RX_Data_Byte;
        else
          cnt <= 0;
          RX_Byte(Data_Index) <= UART_RX;
          if Data_Index < 7 then
            Data_Index <= Data_Index + 1;
            State      <= RX_Data_Byte;
          else
            Data_Index <= 0;
            State      <= RX_Stop;
          end if;
        end if;
      -- State RX_Stop - waiting for a stop bit (1)
      when RX_Stop =>
        if cnt < Cnt_max-1 then
          cnt   <= cnt + 1;
          State <= RX_Stop;
        else
          RX_VALID <= '1';
          cnt      <= 0;
          State    <= Clean;
        end if;
      -- State Clean - waiting for 1 clock cycle to get back to the Wait_SB state
      when Clean =>
        State <= Wait_SB;
        RX_VALID   <= '0';
      when others =>
        State <= Wait_SB;
    end case;
  end if;
end process UART_Receive_Process;

UART_RX_VALID  <= RX_VALID;
UART_RX_BYTE   <= RX_Byte;

end rtl;
