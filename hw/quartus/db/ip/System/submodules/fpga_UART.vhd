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
		--   UART external interface
      TX_PORT: OUT std_logic;
		RX_PORT: IN std_logic
   );
End fpga_UART;

ARCHITECTURE comp OF fpga_UART IS
	signal   iRegClockCounter :  std_logic_vector(31 DOWNTO 0);
   signal   iRegRead_Final :  std_logic_vector (7 DOWNTO 0);
	signal   iRegToTransmit:  std_logic_vector (7 DOWNTO 0);
   signal   iRegValueWriteAvailable :  std_logic;
	signal   iRegValueReadAvailable :  std_logic;
   
	signal   iHasBeenRead:  std_logic;--Internal signal to carry information between process
	signal   iHasBeenTransmit:  std_logic;--Internal signal to carry information between process
	signal 	iClearStatusError: std_logic;--Internal signal to carry information between process
	
		Type RX_Read IS (IDLE,Start_BIT, BIT0, BIT1, BIT2 , BIT3 , BIT4 , BIT5 , BIT6 , BIT7,STOP_BIT);
	signal   State_Read:  RX_Read;
	signal   Counter_Read:  unsigned(31 downto 0);
	signal   iRead_Current :  std_logic_vector (7 DOWNTO 0);--Store temporal information
	signal   Error_Read: std_logic;-- If stop bit isn't correct will be set
	signal   iReadPin:  std_logic;--Actual value of RX_PORT
	signal   iReadPin_Previous:  std_logic;-- Previous value of RX_PORT, reference is CLK

	signal   State_Write: integer range 0 to 10;
	signal   Counter_Write:  unsigned(31 downto 0);
	signal   ValueToReachWrite:  unsigned(31 downto 0);

BEGIN
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
			if iRegValueReadAvailable='0' and avs_Address /="010" then-- If nothing to be read we can clear the information 
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
			Counter_Read<=to_unsigned(0,Counter_Read'length);
			State_Read<=IDLE;
			Error_Read<='0';
			iRegValueReadAvailable<='0';
			iReadPin_Previous<='0';
		elsif rising_edge(Clk) then
			iReadPin_Previous<=iReadPin;
				case State_Read is 
					when IDLE=> 
						if iReadPin='0' and iReadPin_Previous='1' then
							State_Read<=Start_BIT;
						else
							State_Read<=IDLE;
						end if;
							Counter_Read<=to_unsigned(0,Counter_Read'length);
							iRead_Current <= (others => '0');
					when START_BIT=>
						if Counter_Read=unsigned(iRegClockCounter)/2-1 then
							if iReadPin='0' and iReadPin_Previous='0' then --Still in start bit
								State_Read<=BIT0;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
							else--Noise or misyncronized
								State_Read<=IDLE;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
							end if;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT0=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=BIT1;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(0)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT1=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=BIT2;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(1)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT2=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=BIT3;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(2)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT3=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=BIT4;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(3)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT4=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=BIT5;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(4)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT5=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=BIT6;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(5)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT6=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=BIT7;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(6)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when BIT7=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
								State_Read<=STOP_BIT;
								Counter_Read<=to_unsigned(0,Counter_Read'length);
								iRead_Current(7)<=iReadPin;
						else
							Counter_Read<=Counter_Read+1;
						end if;
					when STOP_BIT=>
						if Counter_Read=unsigned(iRegClockCounter)-1 then
							if iReadPin/='1' or iReadPin_Previous/='1' then --Still in start bit
								Error_Read<='1';
							end if;
							State_Read<=IDLE;
							Counter_Read<=to_unsigned(0,Counter_Read'length);
							iRegRead_Final<=iRead_Current;
							iRegValueReadAvailable<='1';
						else
							Counter_Read<=Counter_Read+1;
						end if;
					end case;
					if (iHasBeenRead='1' and iRegValueReadAvailable ='1') and State_Read/=STOP_BIT  then --Correct Information has been read
						iRegValueReadAvailable<='0';--Clear the information
					end if;
					if iClearStatusError='1' and State_Read/=STOP_BIT then
						Error_Read<='0';-- User has read the error, clear it
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
					if Counter_Write=ValueToReachWrite then--Time to do something
						if State_Write=0 then--Start bit State
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							ValueToReachWrite<=unsigned(iRegClockCounter);
							TX_PORT<='0'; --Begin with Start bit at low
							State_Write<=1;
						elsif State_Write>=1 and State_Write<=8 then-- State for communication of our 8 bits
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							State_Write<=State_Write+1;
							TX_PORT<=iRegToTransmit(State_Write-1);
						elsif State_Write=9 then -- STOP BIT state 
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							State_Write<=State_Write+1;
							TX_PORT<='1';-- Output at  high
						else -- End of transmission State 10 or unknow
							Counter_Write<=to_unsigned(0,Counter_Write'length);
							ValueToReachWrite<=to_unsigned(0,ValueToReachWrite'length);
							iHasBeenTransmit<='1';--Intern signal to carry the information for reset iRegValueWriteAvailable
							State_Write<=0;--Read to start again
						end if;
					else
						Counter_Write<=Counter_Write+1;
					end if;
				end if;
		end if;
end process TX;




end comp;
