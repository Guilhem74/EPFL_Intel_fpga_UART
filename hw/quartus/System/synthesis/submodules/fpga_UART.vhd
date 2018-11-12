library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
ENTITY fpga_UART IS
   PORT(
	--   Avalon interfaces signals
      Clk : IN std_logic;
      nReset: IN std_logic;
      avs_Address : IN std_logic_vector (2 DOWNTO 0);
      avs_ChipSelect  : IN std_logic;
      avs_Read: IN std_logic;
      avs_Write: IN std_logic;
      avs_ReadData : OUT std_logic_vector (31 DOWNTO 0);
      avs_WriteData   : IN std_logic_vector (31 DOWNTO 0);
		--   Parallel Port external interface
      TX_PORT: OUT std_logic;
		RX_PORT: IN std_logic;
		Debug_OUT: OUT std_logic_vector (12 DOWNTO 0)
   );
End fpga_UART;

ARCHITECTURE comp OF fpga_UART IS
	signal   iRegClockCounter :  std_logic_vector(31 DOWNTO 0);
   signal   iRegRead_Final :  std_logic_vector (7 DOWNTO 0);
	signal   iRegToTransmit:  std_logic_vector (7 DOWNTO 0);
   signal   iRegValueWriteAvailable :  std_logic;
	signal   iRegValueReadAvailable :  std_logic;
   
	signal   iHasBeenRead:  std_logic;
	signal   iHasBeenTransmit:  std_logic;

	signal   iReadPin:  std_logic;
	signal   iReadPin_Previous:  std_logic;
	signal iClearStatusError: std_logic;
	signal iClearStatusError_confirm: std_logic;
	signal   iRead_Current :  std_logic_vector (7 DOWNTO 0);
	
	signal   Counter_Read:  unsigned(31 downto 0);
	Type RX_Read IS (IDLE,Start_BIT, BIT0, BIT1, BIT2 , BIT3 , BIT4 , BIT5 , BIT6 , BIT7,STOP_BIT);
	signal   State_Read:  RX_Read;
	signal   ValueToReachRead:  unsigned(31 downto 0);
	signal   Error_Read: std_logic;

	signal   State_Write: integer range 0 to 10;
	signal   Counter_Write:  unsigned(31 downto 0);
	signal   ValueToReachWrite:  unsigned(31 downto 0);

BEGIN
 --   Parallel Port Input value
iReadPin <= RX_PORT;
--   Process Write to registers
Write_process: process(Clk, nReset) begin
			if nReset = '0' then
				iRegToTransmit <= (others => '0');
				iRegValueWriteAvailable <='0';
			elsif	rising_edge(Clk) then
				if avs_ChipSelect= '1' and avs_Write = '1' then --   Write cycl
					if iRegValueWriteAvailable='0' then
						case avs_Address(2 downto 0) is
							when "000" => iRegClockCounter <= avs_WriteData;
							when "001" => iRegToTransmit <= avs_WriteData(7 downto 0) ;
												iRegValueWriteAvailable <='1' ;
							when "101" => iClearStatusError <='1' ;
							when others => null;
						end case;
					end if;
				else
						if iHasBeenTransmit='1' then
							iRegValueWriteAvailable<='0';--Nothing to transfert anymore
						end if;
						if Error_Read='0' then
							iClearStatusError<='0';
						end if;
				end if;
				
			end if;
end process Write_process;
--   Process Read to registers
Read_Process:  process(clk,nReset)
		begin
		if nReset = '0' then
			iHasBeenRead<='0';
			
		elsif rising_edge(Clk) then
			avs_ReadData <= (others => '0');  --   default value
			if avs_ChipSelect= '1' and avs_Read = '1' then--   Read cycle
				case avs_Address(2 downto 0) is
					when "000" => avs_ReadData <= iRegClockCounter;
					when "010" => avs_ReadData(7 downto 0 )<= iRegRead_Final;avs_ReadData(31 downto 8) <= (others => '0'); iHasBeenRead<='1';--We read the information, we need to clear it now.
					when "011" => avs_ReadData(0) <= iRegValueWriteAvailable;avs_ReadData(31 downto 1) <= (others => '0') ; 
					when "100" => avs_ReadData(0) <= iRegValueReadAvailable;avs_ReadData(31 downto 1) <= (others => '0');
					when "101" => avs_ReadData(0)<= Error_Read;
					when "110" => avs_ReadData(7 downto 0 )<= "01111111";
					when others => null;
				end case;
			end if;
			if iRegValueReadAvailable='0' then-- If nothing to be read we can clear the information 
					iHasBeenRead<='0';
			end if;
		 end if;
end process Read_Process;
-- Process read RX
RX: process(clk, nReset)
		begin
		if nReset = '0' then
			iRead_Current <= (others => '0');
			iRegRead_Final <= (others => '0');
			ValueToReachRead<=to_unsigned(0,Counter_Read'length);
			Counter_Read<=to_unsigned(0,Counter_Read'length);
			State_Read<=IDLE;
			Error_Read<='0';
			iRegValueReadAvailable<='0';
			iReadPin_Previous<='0';
			Debug_OUT<=(others => '0');
		elsif rising_edge(Clk) then
				iReadPin_Previous<=iReadPin;--iReadPin_Previous is the previous value of ReadPin until the end of the process
				if Counter_Read=ValueToReachRead then -- Time to analyse the signal
						case State_Read is
							when IDLE => 
											if iReadPin='0' and iReadPin_Previous ='1'  then--start bit received
												iRead_Current<=(others => '0');
												State_Read<=START_BIT;
												ValueToReachRead<=unsigned(iRegClockCounter)/2;
												Counter_Read<=to_unsigned(0,Counter_Read'length);
												Debug_OUT<=(0 => '1', others => '0');
												end if;
							when START_BIT =>
											if iReadPin='0' and iReadPin_Previous ='0' then--Still in start bit
												State_Read<=BIT0;
												Counter_Read<=to_unsigned(0,Counter_Read'length);
												ValueToReachRead<=unsigned(iRegClockCounter);--Setup interval to trig the rest of the read
												Debug_OUT<=(1 => '1', others => '0');
											else-- Probably noise or miscommunication
												State_Read<=IDLE;
												Counter_Read<=to_unsigned(0,Counter_Read'length);
												ValueToReachRead<=to_unsigned(0,ValueToReachRead'length);
											end if;
							when BIT0 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(0)<=iReadPin;
											State_Read<=BIT1;
											Debug_OUT<=(2 => '1', others => '0');
							when BIT1 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(1)<=iReadPin;
											State_Read<=BIT2;
											Debug_OUT<=(3 => '1', others => '0');
							when BIT2 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(2)<=iReadPin;
											State_Read<=BIT3;
											Debug_OUT<=(4 => '1', others => '0');
							when BIT3 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(3)<=iReadPin;
											State_Read<=BIT4;
											Debug_OUT<=(5 => '1', others => '0');
							when BIT4 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(4)<=iReadPin;
											State_Read<=BIT5;
											Debug_OUT<=(6 => '1', others => '0');
							when BIT5 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(5)<=iReadPin;
											State_Read<=BIT6;
											Debug_OUT<=(7 => '1', others => '0');
							when BIT6 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(6)<=iReadPin;
											State_Read<=BIT7;
											Debug_OUT<=(8 => '1', others => '0');
							when BIT7 =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											iRead_Current(7)<=iReadPin;
											State_Read<=STOP_BIT;
											Debug_OUT<=(9 => '1', others => '0');
							when STOP_BIT =>
											Counter_Read<=to_unsigned(0,Counter_Read'length);
											if iReadPin/='1' or iReadPin_Previous/='1' then--if  stop bit then  valid,so save the value
												Error_Read<='1';
											else
												Error_Read<='0';

											end if;
											Debug_OUT<=(10 => '1', others => '0');
											iRegRead_Final<=iRead_Current;
											iRegValueReadAvailable<='1';
											ValueToReachRead<=to_unsigned(0,ValueToReachRead'length);
											State_Read<=IDLE;
											iRead_Current<=(others => '0');
											Counter_Read<=to_unsigned(0,Counter_Read'length);
							END CASE;
				else
						Counter_Read<=Counter_Read+1;
				end if;
				if (iHasBeenRead='1' and iRegValueReadAvailable ='1') then --Correct Information has been read
					iRegValueReadAvailable<='0';--Clear the information
				end if;
				if iClearStatusError='1' then
				end if;
		end if;
end process RX;

-- Process write TX
TX: process(clk, nReset)
		begin
		if nReset = '0' then
			State_Write<=0;
			Counter_Write<=to_unsigned(0,Counter_Write'length);
			ValueToReachWrite<=to_unsigned(0,ValueToReachWrite'length);
			TX_PORT<='1';
		elsif rising_edge(Clk) then
				if iRegValueWriteAvailable='0' then --Nothing to be transmit
					iHasBeenTransmit<='0';--Clear the potential previous information
				elsif	iRegValueWriteAvailable='1' and iHasBeenTransmit<='0' then --Something to transmit or currently transmitting
					if Counter_Write=ValueToReachWrite then
						if State_Write=0 then
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							ValueToReachWrite<=unsigned(iRegClockCounter);
							TX_PORT<='0'; --Begin Start bit by low
							State_Write<=1;
							elsif State_Write>=1 and State_Write<=8 then
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							State_Write<=State_Write+1;
							TX_PORT<=iRegToTransmit(State_Write-1);
							elsif State_Write=9 then -- STOP BIT
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							State_Write<=State_Write+1;
							TX_PORT<='1';
						else --
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							ValueToReachWrite<=to_unsigned(0,ValueToReachWrite'length);
							iHasBeenTransmit<='1';
							State_Write<=0;
						end if;
					else
						Counter_Write<=Counter_Write+1;
					end if;
				end if;
		end if;
end process TX;




end comp;
