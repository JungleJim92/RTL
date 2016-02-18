onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Top
add wave -noupdate /ssp_tx_tb/clk_i
add wave -noupdate /ssp_tx_tb/rst_i
add wave -noupdate /ssp_tx_tb/do_write
add wave -noupdate /ssp_tx_tb/tx_d
add wave -noupdate /ssp_tx_tb/tx_full
add wave -noupdate /ssp_tx_tb/sspclkout
add wave -noupdate /ssp_tx_tb/sspfssout
add wave -noupdate /ssp_tx_tb/ssptxd
add wave -noupdate -divider Instantiation
add wave -noupdate /ssp_tx_tb/the_instantiation/clk_i
add wave -noupdate /ssp_tx_tb/the_instantiation/rst_i
add wave -noupdate /ssp_tx_tb/the_instantiation/do_write
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_d
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_full
add wave -noupdate /ssp_tx_tb/the_instantiation/sspclkout
add wave -noupdate /ssp_tx_tb/the_instantiation/sspfssout
add wave -noupdate /ssp_tx_tb/the_instantiation/ssptxd
add wave -noupdate /ssp_tx_tb/the_instantiation/fifo_empty
add wave -noupdate /ssp_tx_tb/the_instantiation/do_read
add wave -noupdate /ssp_tx_tb/the_instantiation/do_write_i
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_busy
add wave -noupdate /ssp_tx_tb/the_instantiation/data_valid
add wave -noupdate /ssp_tx_tb/the_instantiation/sr_in
add wave -noupdate /ssp_tx_tb/the_instantiation/data_valid_d
add wave -noupdate -divider FIFO
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/clk_i
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/rst_i
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/write
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/read
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/write_d
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/read_d
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/empty
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/full
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/d
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/size
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/full_i
add wave -noupdate /ssp_tx_tb/the_instantiation/tx_fifo/empty_i
add wave -noupdate -divider {Serial Transmitter}
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/sspclkout
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/sspfssin
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/ssptxd
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/rst_i
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/data_valid
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/busy
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/ssptxout
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/t_count
add wave -noupdate -divider {Shift Register}
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/tx_sr/clk_i
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/tx_sr/rst_i
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/tx_sr/d_in
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/tx_sr/ld
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/tx_sr/shift
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/tx_sr/q
add wave -noupdate /ssp_tx_tb/the_instantiation/ser_tx/tx_sr/d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 121
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {26750 ps}
