-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "11/07/2018 23:49:42"
                                                            
-- Vhdl Test Bench template for design  :  fpga_UART
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
USE ieee.numeric_std.all;    
ENTITY fpga_UART_vhd_tst IS
END fpga_UART_vhd_tst;
ARCHITECTURE fpga_UART_arch OF fpga_UART_vhd_tst IS
-- constants   
constant  CLK_PERIOD : time := 20ns ;   
constant  Baud_Period : time := 51.92us ;                                                                                         
-- signals                                                   
SIGNAL avs_Address : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL avs_ChipSelect : STD_LOGIC;
SIGNAL avs_Read : STD_LOGIC;
SIGNAL avs_ReadData : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL avs_Write : STD_LOGIC;
SIGNAL avs_WriteData : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Clk : STD_LOGIC;
SIGNAL nReset : STD_LOGIC;
SIGNAL RX_PORT : STD_LOGIC;
SIGNAL TX_PORT : STD_LOGIC;
SIGNAL Temp: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL Temp2: STD_LOGIC_VECTOR(31 downto 0);

SIGNAL Error: STD_LOGIC;
COMPONENT fpga_UART
	PORT (
	avs_Address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	avs_ChipSelect : IN STD_LOGIC;
	avs_Read : IN STD_LOGIC;
	avs_ReadData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	avs_Write : IN STD_LOGIC;
	avs_WriteData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	Clk : IN STD_LOGIC;
	nReset : IN STD_LOGIC;
	RX_PORT : IN STD_LOGIC;
	TX_PORT : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : fpga_UART
	PORT MAP (
-- list connections between master ports and signals
	avs_Address => avs_Address,
	avs_ChipSelect => avs_ChipSelect,
	avs_Read => avs_Read,
	avs_ReadData => avs_ReadData,
	avs_Write => avs_Write,
	avs_WriteData => avs_WriteData,
	Clk => Clk,
	nReset => nReset,
	RX_PORT => RX_PORT,
	TX_PORT => TX_PORT
	);
                                                                                    
clk_generation : process
	begin
		
			Clk <= '1'; wait for CLK_PERIOD / 2;
			Clk <= '0'; wait for CLK_PERIOD / 2;
		
 end process clk_generation;    
                                                                                    
Access_Register : process
	begin
		
	avs_Write<='0';
	avs_WriteData<=std_logic_vector(to_unsigned(0,32));  
	avs_Address<="000";
	nReset<='0';
	avs_ChipSelect<='0';
	wait for 20ns;
	nReset<='1';                                                   
	wait for 20ns;
	avs_Write<='1';
	avs_WriteData<= std_logic_vector(to_unsigned(2604,32));  --Baudrate
	avs_Address<="000";
	avs_ChipSelect<='1';
	wait for 40ns;
	avs_Write<='1';
	avs_WriteData<= std_logic_vector(to_unsigned(104,32));  --Value to TX
	avs_Address<="001";
	avs_ChipSelect<='1';
	wait for CLK_PERIOD;
	avs_Address<="000";
	avs_Write<='0';
	avs_ChipSelect<='0';
	WHILE 1=1 LOOP
		wait for CLK_PERIOD;
		avs_Address<="100";
		avs_Read<='1';
		avs_ChipSelect<='1';
		wait for CLK_PERIOD;
		Temp2<=avs_ReadData;
		avs_Address<="000";
		avs_Read<='0';
		avs_ChipSelect<='0';
		wait for CLK_PERIOD;
		if Temp2(0)='1' then
			avs_Address<="010";
			avs_Read<='1';
			avs_ChipSelect<='1';
		end if;
		wait for CLK_PERIOD;
		avs_Address<="000";
		avs_Read<='0';
		avs_Write<='0';
		avs_ChipSelect<='0';
		wait for 105ns;
	end loop;
 end process Access_Register; 
                                    
always : PROCESS 
procedure Read_RX(Data: unsigned) is
    begin
       Temp<=std_logic_vector(Data);
       RX_PORT<='0';--Start Bit
       wait for Baud_Period;
	for I in 0 to 7 loop
		 RX_PORT<=Temp(I);
		wait for Baud_Period;
	end loop;
	RX_PORT<='0';--STOP Bit
       wait for Baud_Period;
	RX_PORT<='1';
	wait for 2.023us;
 end procedure Read_RX;                                                                                   
BEGIN
	RX_PORT<='1';
	wait for 300ns;
	WHILE 1=1 LOOP
		Read_RX(x"61");
	end loop;
	

WAIT;                                                        
END PROCESS always;                                          
END fpga_UART_arch;
