/*
 *
 *
 * alt_printf Only supports %s, %x, and %c ( < 1 Kbyte)
 */
#include "sys/alt_stdio.h"
#include "system.h"
#include "HAL/inc/io.h"
#include <string.h>
#include <math.h>
#include <stdlib.h>
//Read Register
#define iRegClockCounter 0
#define iRegToTransmit 4
#define iRegRead_Final 8
#define iRegValueWriteAvailable 12
#define iRegValueReadAvailable 16
#define iRegError_Read 20
#define iRegTest 24
//Write Register
//#define iRegClockCounter 0
//#define Debug


#define CLOCK_INIT 50000000 //Hz
#define BaudRate 115200 //Hz


#include <stdio.h>

int main()
{
	int k=0;
  printf("Hello from Nios II!\n");
  alt_printf("iRegTest=%x\n\n",IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegTest));
  IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegClockCounter,CLOCK_INIT/BaudRate);//50Mhz/ bps
	int State=0;
	long NumberA=0;
	long NumberB=0;
  while(1){
	  if(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegError_Read)==1)
		{
		  alt_printf("Error=\n");
		  IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegError_Read,111);
		}
		  	  if(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueReadAvailable)==1)
		  	  {


		  		int Read=IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegRead_Final);
		  		while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
		  				  			IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,Read);
		  						  printf("%d\n",Read);
		  				  			/*
		  		if (Read=='+')// +
		  		{
		  			while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
		  			IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,Read);
		  			printf("+");
					State=1;//USe to swap variable where to store the information received
		  		}
		  		else if (Read=='\r')
				{
		  			State=0;
					char T[32]={};
					itoa((long) NumberA+NumberB,T,10);//Convert the sum into array of char
					printf("= %ld \n",NumberA+NumberB);//Display the sum on the NIOS console

					while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
					IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,'=');//Display =
					for(k=0;k<strlen(T);k++)
					{// Send every character of the array
						while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
									IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,T[k]);
					}
					while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
					IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,'\r');
					while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
					IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,'\n');
					NumberA=0;
					NumberB=0;
				}
		  		else if(Read=='\n')
		  		{}//Just do nothing
		  		else
		  		{
		  			while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
		  			IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,Read);//Display what we receive
		  			if (State==0)
		  			{//We haven't receive +, store the number
						NumberA=NumberA*10+ Read-0x30;

		  			}
		  			else
		  			{// We have received + but not \r yet, store the number
		  				NumberB=NumberB*10+ Read-0x30;
		  			}
		  			printf("%d",Read-0x30);//Display on the NIOS console
		  		}

*/
		  	  }



  }
  return 0;
}
