onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_route_ctrl/clk
add wave -noupdate /tb_route_ctrl/rst_n
add wave -noupdate /tb_route_ctrl/last
add wave -noupdate /tb_route_ctrl/ready
add wave -noupdate -divider {input 0}
add wave -noupdate {/tb_route_ctrl/valid[0]}
add wave -noupdate {/tb_route_ctrl/dest[0]}
add wave -noupdate -divider {input 1}
add wave -noupdate {/tb_route_ctrl/valid[1]}
add wave -noupdate {/tb_route_ctrl/dest[1]}
add wave -noupdate -divider {input 2}
add wave -noupdate {/tb_route_ctrl/valid[2]}
add wave -noupdate {/tb_route_ctrl/dest[2]}
add wave -noupdate -divider {input 3}
add wave -noupdate {/tb_route_ctrl/valid[3]}
add wave -noupdate {/tb_route_ctrl/dest[3]}
add wave -noupdate -divider {output 0}
add wave -noupdate /tb_route_ctrl/grant_0
add wave -noupdate -divider {output 0}
add wave -noupdate /tb_route_ctrl/grant_1
add wave -noupdate -divider iteration
add wave -noupdate /tb_route_ctrl/i
add wave -noupdate /tb_route_ctrl/j
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {57 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 210
configure wave -valuecolwidth 53
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
WaveRestoreZoom {4 ps} {438 ps}
