quit -sim
vlib work
vlog ../../arbiter_rr.v ../../tb_arbiter_rr.v
vsim tb_arbiter_rr
delete wave *
do wave.do
run -all