onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_arbiter_rr/clk
add wave -noupdate /tb_arbiter_rr/rst_n
add wave -noupdate /tb_arbiter_rr/req
add wave -noupdate /tb_arbiter_rr/tlast
add wave -noupdate /tb_arbiter_rr/tready
add wave -noupdate /tb_arbiter_rr/grant
add wave -noupdate /tb_arbiter_rr/u0/curr_grant
add wave -noupdate /tb_arbiter_rr/u0/last_grant
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {70 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 265
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {198 ps}
