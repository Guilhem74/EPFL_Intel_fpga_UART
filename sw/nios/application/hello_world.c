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
#define Test 24
//Write Register
//#define iRegClockCounter 0
#define Debug


#define CLOCK_INIT 50000000 //Hz
#define BaudRate 19200 //Hz


#include <stdio.h>

int main()
{
	int k=0;
	for(k=0;k<5000;k++);
  printf("Hello from Nios II!\n");
  alt_printf("iRegPolarity=%x\n\n",IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,Test));
  IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegClockCounter,CLOCK_INIT/BaudRate);//50Mhz/ bps
  	  int ReadA[32]={};
  	  int ReadB[32]={};
	  int State=0;
	  int iA=0;
	  int iB=0;
	  int NumberA=0;
	  int NumberB=0;
  while(1){
	  if(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegError_Read)==1)
		{
		  alt_printf("Error=\n");
		  IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegError_Read,111);//50Mhz/ bps
		}

		  	  if(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueReadAvailable)==1)
		  	  {
		  		//for(k=0;k<5000;k++);

		  		int Read=IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegRead_Final);
		  		while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
#ifdef Debug
		  		IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,Read);
		  		alt_printf("Read=%x\n",Read);
#else
		  		if (Read==0x2B)// +
		  		{
		  			while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
		  			IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,Read);
					State=1;
					for(k=0;k<iA;k++)
						{
							NumberA+=pow(10,k)*ReadA[iA-k-1];
						}
					 printf("+");

		  		}
		  		else if (Read==0xd)
				{
		  			State=0;
					for(k=0;k<iB;k++)
					{
						NumberB+=pow(10,k)*ReadB[iB-k-1];
					}
					char T[32]={};
					itoa(NumberA+NumberB,T,10);
					printf("= %d \n",NumberA+NumberB);
					for(k=0;k<32;k++)
					{
						ReadA[k]=0;
						ReadB[k]=0;
						iA=0;
						iB=0;
						NumberA=0;
						NumberB=0;
					}
					while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
					IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,'=');
					for(k=0;k<strlen(T);k++)
					{
						while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
									IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,T[k]);
					}
					while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
					IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,'\r');
					while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
					IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,'\n');
				}
		  		else
		  		{
		  			while(IORD_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegValueWriteAvailable)!=0);
		  				IOWR_32DIRECT(FPGA_UART_CUSTOM_0_BASE,iRegToTransmit,Read);
		  			if (State==0)
		  			{
		  				ReadA[iA]=Read-0x30;
		  				iA++;

		  			}
		  			else
		  			{
		  				ReadB[iB]=Read-0x30;
		  				iB++;
		  			}
		  			printf("%d",Read-0x30);
		  		}

#endif

		  	  }



  }
  return 0;
}
