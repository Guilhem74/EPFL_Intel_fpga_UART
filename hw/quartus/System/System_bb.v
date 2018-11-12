
module System (
	clk_clk,
	fpga_uart_custom_0_rx_rx_in,
	fpga_uart_custom_0_tx_tx_out,
	reset_reset_n,
	fpga_uart_debug_readdata);	

	input		clk_clk;
	input		fpga_uart_custom_0_rx_rx_in;
	output		fpga_uart_custom_0_tx_tx_out;
	input		reset_reset_n;
	output	[12:0]	fpga_uart_debug_readdata;
endmodule
