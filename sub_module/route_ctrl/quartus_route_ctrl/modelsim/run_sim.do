quit -sim
vlib work
vlog ../../route_ctrl.v ../../tb_route_ctrl.v
vsim tb_route_ctrl
delete wave *
do wave.do
run -all