onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_crossbar/tvalid
add wave -noupdate /tb_crossbar/tlast
add wave -noupdate -radix hexadecimal -childformat {{{/tb_crossbar/tdata_in[31]} -radix hexadecimal} {{/tb_crossbar/tdata_in[30]} -radix hexadecimal} {{/tb_crossbar/tdata_in[29]} -radix hexadecimal} {{/tb_crossbar/tdata_in[28]} -radix hexadecimal} {{/tb_crossbar/tdata_in[27]} -radix hexadecimal} {{/tb_crossbar/tdata_in[26]} -radix hexadecimal} {{/tb_crossbar/tdata_in[25]} -radix hexadecimal} {{/tb_crossbar/tdata_in[24]} -radix hexadecimal} {{/tb_crossbar/tdata_in[23]} -radix hexadecimal} {{/tb_crossbar/tdata_in[22]} -radix hexadecimal} {{/tb_crossbar/tdata_in[21]} -radix hexadecimal} {{/tb_crossbar/tdata_in[20]} -radix hexadecimal} {{/tb_crossbar/tdata_in[19]} -radix hexadecimal} {{/tb_crossbar/tdata_in[18]} -radix hexadecimal} {{/tb_crossbar/tdata_in[17]} -radix hexadecimal} {{/tb_crossbar/tdata_in[16]} -radix hexadecimal} {{/tb_crossbar/tdata_in[15]} -radix hexadecimal} {{/tb_crossbar/tdata_in[14]} -radix hexadecimal} {{/tb_crossbar/tdata_in[13]} -radix hexadecimal} {{/tb_crossbar/tdata_in[12]} -radix hexadecimal} {{/tb_crossbar/tdata_in[11]} -radix hexadecimal} {{/tb_crossbar/tdata_in[10]} -radix hexadecimal} {{/tb_crossbar/tdata_in[9]} -radix hexadecimal} {{/tb_crossbar/tdata_in[8]} -radix hexadecimal} {{/tb_crossbar/tdata_in[7]} -radix hexadecimal} {{/tb_crossbar/tdata_in[6]} -radix hexadecimal} {{/tb_crossbar/tdata_in[5]} -radix hexadecimal} {{/tb_crossbar/tdata_in[4]} -radix hexadecimal} {{/tb_crossbar/tdata_in[3]} -radix hexadecimal} {{/tb_crossbar/tdata_in[2]} -radix hexadecimal} {{/tb_crossbar/tdata_in[1]} -radix hexadecimal} {{/tb_crossbar/tdata_in[0]} -radix hexadecimal}} -subitemconfig {{/tb_crossbar/tdata_in[31]} {-radix hexadecimal} {/tb_crossbar/tdata_in[30]} {-radix hexadecimal} {/tb_crossbar/tdata_in[29]} {-radix hexadecimal} {/tb_crossbar/tdata_in[28]} {-radix hexadecimal} {/tb_crossbar/tdata_in[27]} {-radix hexadecimal} {/tb_crossbar/tdata_in[26]} {-radix hexadecimal} {/tb_crossbar/tdata_in[25]} {-radix hexadecimal} {/tb_crossbar/tdata_in[24]} {-radix hexadecimal} {/tb_crossbar/tdata_in[23]} {-radix hexadecimal} {/tb_crossbar/tdata_in[22]} {-radix hexadecimal} {/tb_crossbar/tdata_in[21]} {-radix hexadecimal} {/tb_crossbar/tdata_in[20]} {-radix hexadecimal} {/tb_crossbar/tdata_in[19]} {-radix hexadecimal} {/tb_crossbar/tdata_in[18]} {-radix hexadecimal} {/tb_crossbar/tdata_in[17]} {-radix hexadecimal} {/tb_crossbar/tdata_in[16]} {-radix hexadecimal} {/tb_crossbar/tdata_in[15]} {-radix hexadecimal} {/tb_crossbar/tdata_in[14]} {-radix hexadecimal} {/tb_crossbar/tdata_in[13]} {-radix hexadecimal} {/tb_crossbar/tdata_in[12]} {-radix hexadecimal} {/tb_crossbar/tdata_in[11]} {-radix hexadecimal} {/tb_crossbar/tdata_in[10]} {-radix hexadecimal} {/tb_crossbar/tdata_in[9]} {-radix hexadecimal} {/tb_crossbar/tdata_in[8]} {-radix hexadecimal} {/tb_crossbar/tdata_in[7]} {-radix hexadecimal} {/tb_crossbar/tdata_in[6]} {-radix hexadecimal} {/tb_crossbar/tdata_in[5]} {-radix hexadecimal} {/tb_crossbar/tdata_in[4]} {-radix hexadecimal} {/tb_crossbar/tdata_in[3]} {-radix hexadecimal} {/tb_crossbar/tdata_in[2]} {-radix hexadecimal} {/tb_crossbar/tdata_in[1]} {-radix hexadecimal} {/tb_crossbar/tdata_in[0]} {-radix hexadecimal}} /tb_crossbar/tdata_in
add wave -noupdate -radix hexadecimal {/tb_crossbar/tdata_in[7:0]}
add wave -noupdate -radix hexadecimal {/tb_crossbar/tdata_in[15:8]}
add wave -noupdate -radix hexadecimal {/tb_crossbar/tdata_in[23:16]}
add wave -noupdate -radix hexadecimal {/tb_crossbar/tdata_in[31:24]}
add wave -noupdate /tb_crossbar/tvalid0
add wave -noupdate /tb_crossbar/tlast0
add wave -noupdate /tb_crossbar/grant0
add wave -noupdate -radix hexadecimal /tb_crossbar/tdata0
add wave -noupdate /tb_crossbar/tvalid1
add wave -noupdate /tb_crossbar/tlast1
add wave -noupdate /tb_crossbar/grant1
add wave -noupdate /tb_crossbar/tdata1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {53 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 282
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
WaveRestoreZoom {0 ps} {161 ps}
