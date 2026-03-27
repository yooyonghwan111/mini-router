onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sync_fifo/clk
add wave -noupdate /tb_sync_fifo/rst_n
add wave -noupdate /tb_sync_fifo/wr_en
add wave -noupdate -radix unsigned /tb_sync_fifo/tdata_in
add wave -noupdate /tb_sync_fifo/rd_en
add wave -noupdate -radix unsigned /tb_sync_fifo/tdata_out
add wave -noupdate /tb_sync_fifo/full
add wave -noupdate /tb_sync_fifo/empty
add wave -noupdate /tb_sync_fifo/u0/wptr
add wave -noupdate /tb_sync_fifo/wptr_before
add wave -noupdate /tb_sync_fifo/u0/rptr
add wave -noupdate /tb_sync_fifo/rptr_before
add wave -noupdate /tb_sync_fifo/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {345 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {160 ps} {524 ps}
