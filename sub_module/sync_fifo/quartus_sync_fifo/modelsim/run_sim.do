quit -sim
vlib work
vlog ../../sync_fifo.v ../../tb_sync_fifo.v
vsim tb_sync_fifo
delete wave *
do wave.do
run -all