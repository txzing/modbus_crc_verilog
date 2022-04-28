# modbus_crc_verilog
slave ID 通过 port 设置

# Modbus RTU Slave Pure RTL design for FPGA
design a ip implements Modbus RTU slave sub function 03 04 06 on FPGA.

Function code: 03 04 06

Exception code: 01 02 03 04

Function 03: ligal reg 0001, ligal quantiy 0001

Function 04: ligal reg 0001~0004, ligal quantiy + ligal reg < 0005

Function 06: ligal reg 0001, ligal data 0000~0017, coresponding to Function 03 reg 0001

## uart tx and uart rx
done

uart_byte_tx_tb.do

uart_byte_rx_tb.do

## rx 3.5T and 1.5T interval detect
done

ct_35t_gen_tb.do

ct_15t_gen_tb.do

## rx slave address and frame check
done

frame_rx_tb.do

## checksum if slave address check pass
done

modbus_crc_tb.do

## Exception handling (exclude 04)
### checksum mismatch then do nothing
### illegal fuction code retrun 01
### illegal address return 02
### illegal quantity return 03

done

exceptions_tb.do

# read / write func logic
done

func_handler_tb.do

# top wrapper
done

modbus_rtu_slave_top_tb.do

# simulation
经过仿真与上板测试，无误
程序中代码任有部分可优化