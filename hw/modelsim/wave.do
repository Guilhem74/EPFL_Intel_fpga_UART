onerror {resume}
quietly virtual function -install /fpga_uart_vhd_tst -env /fpga_uart_vhd_tst { 0.8} virtual_000001
quietly virtual function -install /fpga_uart_vhd_tst -env /fpga_uart_vhd_tst { 0.8} virtual_000002
quietly virtual function -install /fpga_uart_vhd_tst -env /fpga_uart_vhd_tst { 0.8} virtual_000003
quietly virtual function -install /fpga_uart_vhd_tst -env /fpga_uart_vhd_tst { 0.8} virtual_000004
quietly WaveActivateNextPane {} 0
add wave -noupdate /fpga_uart_vhd_tst/i1/Clk
add wave -noupdate /fpga_uart_vhd_tst/i1/nReset
add wave -noupdate /fpga_uart_vhd_tst/i1/avs_Address
add wave -noupdate /fpga_uart_vhd_tst/i1/avs_ChipSelect
add wave -noupdate /fpga_uart_vhd_tst/i1/avs_Read
add wave -noupdate /fpga_uart_vhd_tst/i1/avs_Write
add wave -noupdate /fpga_uart_vhd_tst/i1/avs_ReadData
add wave -noupdate /fpga_uart_vhd_tst/i1/avs_WriteData
add wave -noupdate /fpga_uart_vhd_tst/i1/TX_PORT
add wave -noupdate /fpga_uart_vhd_tst/i1/RX_PORT
add wave -noupdate /fpga_uart_vhd_tst/i1/iRegClockCounter
add wave -noupdate /fpga_uart_vhd_tst/i1/iRegToTransmit
add wave -noupdate /fpga_uart_vhd_tst/i1/iRegValueWriteAvailable
add wave -noupdate /fpga_uart_vhd_tst/i1/iRegValueReadAvailable
add wave -noupdate /fpga_uart_vhd_tst/i1/iHasBeenTransmit
add wave -noupdate -radix decimal /fpga_uart_vhd_tst/i1/ValueToReachRead
add wave -noupdate /fpga_uart_vhd_tst/i1/State_Write
add wave -noupdate /fpga_uart_vhd_tst/i1/Counter_Write
add wave -noupdate /fpga_uart_vhd_tst/i1/ValueToReachWrite
add wave -noupdate -expand -group RX -radix decimal /fpga_uart_vhd_tst/i1/iRegRead_Final
add wave -noupdate -expand -group RX /fpga_uart_vhd_tst/i1/iHasBeenRead
add wave -noupdate -expand -group RX /fpga_uart_vhd_tst/i1/iReadPin
add wave -noupdate -expand -group RX /fpga_uart_vhd_tst/i1/iReadPin_Previous
add wave -noupdate -expand -group RX -radix decimal /fpga_uart_vhd_tst/i1/iRead_Current
add wave -noupdate -expand -group RX /fpga_uart_vhd_tst/i1/Counter_Read
add wave -noupdate -expand -group RX /fpga_uart_vhd_tst/i1/State_Read
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {885269 ns} 0} {{Cursor 2} {1063832 ns} 0} {{Cursor 3} {1156886 ns} 0} {{Cursor 4} {651377 ns} 0} {{Cursor 5} {500479 ns} 0} {{Cursor 6} {0 ns} 0}
quietly wave cursor active 5
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {269577 ns} {604751 ns}
