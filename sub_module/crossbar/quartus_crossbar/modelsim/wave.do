onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_crossbar/s_valid_0
add wave -noupdate /tb_crossbar/s_valid_1
add wave -noupdate /tb_crossbar/s_valid_2
add wave -noupdate /tb_crossbar/s_valid_3
add wave -noupdate -divider ==============================
add wave -noupdate -divider {input 0}
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_0
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_0_tdata
add wave -noupdate -radix binary /tb_crossbar/data_in_0_tid
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_0_tdest
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_0_tlast
add wave -noupdate -divider {input 1}
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_1
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_1_tdata
add wave -noupdate -radix binary /tb_crossbar/data_in_1_tid
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_1_tdest
add wave -noupdate /tb_crossbar/data_in_1_tlast
add wave -noupdate -divider {input 2}
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_2
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_2_tdata
add wave -noupdate -radix binary /tb_crossbar/data_in_2_tid
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_2_tdest
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_2_tlast
add wave -noupdate -divider {input 3}
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_3
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_3_tdata
add wave -noupdate -radix binary /tb_crossbar/data_in_3_tid
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_3_tdest
add wave -noupdate -radix hexadecimal /tb_crossbar/data_in_3_tlast
add wave -noupdate -divider {output 0}
add wave -noupdate -radix binary /tb_crossbar/grant_0
add wave -noupdate -radix hexadecimal /tb_crossbar/m_tdata_0
add wave -noupdate -radix binary /tb_crossbar/m_tid_0
add wave -noupdate -radix hexadecimal /tb_crossbar/m_dest_0
add wave -noupdate -radix hexadecimal /tb_crossbar/m_last_0
add wave -noupdate -radix hexadecimal /tb_crossbar/m_valid_0
add wave -noupdate -divider {output 1}
add wave -noupdate -radix binary /tb_crossbar/grant_1
add wave -noupdate -radix hexadecimal /tb_crossbar/m_tdata_1
add wave -noupdate -radix binary /tb_crossbar/m_tid_1
add wave -noupdate -radix hexadecimal /tb_crossbar/m_dest_1
add wave -noupdate -radix hexadecimal /tb_crossbar/m_last_1
add wave -noupdate -radix hexadecimal /tb_crossbar/m_valid_1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {180 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 259
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {241 ps}
