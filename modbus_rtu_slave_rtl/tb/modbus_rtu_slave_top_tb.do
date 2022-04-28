transcript on
#compile
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work {../vivado/hdl/uart_byte_tx.v}
vlog -vlog01compat -work work {../vivado/hdl/uart_byte_rx.v}
vlog -vlog01compat -work work {../vivado/hdl/ct_35t_gen.v}
vlog -vlog01compat -work work {../vivado/hdl/ct_15t_gen.v}
vlog -vlog01compat -work work {../vivado/hdl/frame_rx.v}
vlog -vlog01compat -work work {../vivado/hdl/exceptions.v}
vlog -vlog01compat -work work {../vivado/hdl/DPRAM.v}
vlog -vlog01compat -work work {../vivado/hdl/func_handler.v}
vlog -vlog01compat -work work {../vivado/hdl/modbus_crc_16.v}
vlog -vlog01compat -work work {../vivado/hdl/crc_16.v}
vlog -vlog01compat -work work {../vivado/hdl/tx_response.v}
vlog -vlog01compat -work work {../vivado/hdl/modbus_rtu_slave_top.v}
vlog -vlog01compat -work work {./modbus_rtu_slave_top_tb.v}

#simulate
#vsim -novopt modbus_rtu_slave_top_tb
vsim -voptargs="+acc" modbus_rtu_slave_top_tb

add wave -radix unsigned *
add wave -radix hexadecimal /modbus_rtu_slave_top_tb/modbus_rtu_slave_top_inst0/*
add wave -position insertpoint sim:/modbus_rtu_slave_top_tb/modbus_rtu_slave_top_inst0/u_tx_response/rs485_tx_data
#add wave -radix hexadecimal -position insertpoint sim:/modbus_rtu_slave_top_tb/modbus_rtu_slave_top_inst0/u_modbus_crc_16/*
view structure
view signals

run -all


