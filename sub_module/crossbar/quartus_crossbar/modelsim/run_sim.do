quit -sim
vlib work
vlog ../../crossbar.v ../../tb_crossbar.v
vsim tb_crossbar
delete wave *
do wave.do
run -all