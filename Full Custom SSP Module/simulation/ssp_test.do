onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ssp_test/clock
add wave -noupdate /ssp_test/clear_b
add wave -noupdate /ssp_test/pwrite
add wave -noupdate /ssp_test/psel
add wave -noupdate /ssp_test/sspclkin
add wave -noupdate /ssp_test/sspfssin
add wave -noupdate /ssp_test/ssprxd
add wave -noupdate /ssp_test/data_in
add wave -noupdate /ssp_test/sspoe_b
add wave -noupdate /ssp_test/sspclkout
add wave -noupdate /ssp_test/sspfssout
add wave -noupdate /ssp_test/ssptxd
add wave -noupdate /ssp_test/ssptxintr
add wave -noupdate /ssp_test/ssprxintr
add wave -noupdate /ssp_test/data_out
add wave -noupdate -divider SSP
add wave -noupdate /ssp_test/ssp1/PCLK
add wave -noupdate /ssp_test/ssp1/PSEL
add wave -noupdate /ssp_test/ssp1/PWRITE
add wave -noupdate /ssp_test/ssp1/CLEAR_B
add wave -noupdate /ssp_test/ssp1/PWDATA
add wave -noupdate /ssp_test/ssp1/PRDATA
add wave -noupdate /ssp_test/ssp1/SSPTXINTR
add wave -noupdate /ssp_test/ssp1/SSPRXINTR
add wave -noupdate /ssp_test/ssp1/SSPOE_B
add wave -noupdate /ssp_test/ssp1/SSPTXD
add wave -noupdate /ssp_test/ssp1/SSPFSSOUT
add wave -noupdate /ssp_test/ssp1/SSPCLKOUT
add wave -noupdate /ssp_test/ssp1/SSPCLKIN
add wave -noupdate /ssp_test/ssp1/SSPFSSIN
add wave -noupdate /ssp_test/ssp1/SSPRXD
add wave -noupdate /ssp_test/ssp1/do_write
add wave -noupdate /ssp_test/ssp1/do_read
add wave -noupdate -divider {SSP TX}
add wave -noupdate /ssp_test/ssp1/tx_module/clk_i
add wave -noupdate /ssp_test/ssp1/tx_module/rst_i
add wave -noupdate /ssp_test/ssp1/tx_module/do_write
add wave -noupdate /ssp_test/ssp1/tx_module/tx_d
add wave -noupdate /ssp_test/ssp1/tx_module/tx_full
add wave -noupdate /ssp_test/ssp1/tx_module/sspclkout
add wave -noupdate /ssp_test/ssp1/tx_module/sspfssout
add wave -noupdate /ssp_test/ssp1/tx_module/ssptxd
add wave -noupdate /ssp_test/ssp1/tx_module/transmit_ready
add wave -noupdate /ssp_test/ssp1/tx_module/write
add wave -noupdate /ssp_test/ssp1/tx_module/read
add wave -noupdate /ssp_test/ssp1/tx_module/write_d
add wave -noupdate /ssp_test/ssp1/tx_module/read_d
add wave -noupdate /ssp_test/ssp1/tx_module/empty
add wave -noupdate /ssp_test/ssp1/tx_module/full
add wave -noupdate /ssp_test/ssp1/tx_module/data_valid
add wave -noupdate /ssp_test/ssp1/tx_module/tx_busy
add wave -noupdate /ssp_test/ssp1/tx_module/sr_in
add wave -noupdate -divider TRANSMITTER
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/sspclkout
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/sspfssout
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/ssptxd
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/rst_i
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/data_valid
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/busy
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/ssptxout
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/ld
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/shift
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/t_count
add wave -noupdate -divider {SHIFT REG}
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/tx_sr/clk_i
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/tx_sr/rst_i
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/tx_sr/d_in
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/tx_sr/ld
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/tx_sr/shift
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/tx_sr/q
add wave -noupdate /ssp_test/ssp1/tx_module/ser_tx/tx_sr/d
add wave -noupdate -divider FIFO
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/clk_i
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/rst_i
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/write
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/read
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/write_d
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/read_d
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/empty
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/full
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/d
add wave -noupdate /ssp_test/ssp1/tx_module/tx_fifo/size
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {438143 ps} 0}
quietly wave cursor active 1
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2100 ns}
