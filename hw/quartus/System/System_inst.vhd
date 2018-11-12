	component System is
		port (
			clk_clk                      : in  std_logic                     := 'X'; -- clk
			fpga_uart_custom_0_rx_rx_in  : in  std_logic                     := 'X'; -- rx_in
			fpga_uart_custom_0_tx_tx_out : out std_logic;                            -- tx_out
			reset_reset_n                : in  std_logic                     := 'X'; -- reset_n
			fpga_uart_debug_readdata     : out std_logic_vector(12 downto 0)         -- readdata
		);
	end component System;

	u0 : component System
		port map (
			clk_clk                      => CONNECTED_TO_clk_clk,                      --                   clk.clk
			fpga_uart_custom_0_rx_rx_in  => CONNECTED_TO_fpga_uart_custom_0_rx_rx_in,  -- fpga_uart_custom_0_rx.rx_in
			fpga_uart_custom_0_tx_tx_out => CONNECTED_TO_fpga_uart_custom_0_tx_tx_out, -- fpga_uart_custom_0_tx.tx_out
			reset_reset_n                => CONNECTED_TO_reset_reset_n,                --                 reset.reset_n
			fpga_uart_debug_readdata     => CONNECTED_TO_fpga_uart_debug_readdata      --       fpga_uart_debug.readdata
		);

