`timescale 1ns / 1ns
`define clk_period 20

module modbus_rtu_slave_top_tb;

reg sys_clk;
reg reset_n;

wire rs485_rx;
wire rs485_tx;
wire rs485_oe;

reg tx_start;
reg [7:0] tx_data;
wire tx_state;
wire tx_done;

reg test;

uart_byte_tx #
(
    .CLK_FREQ       ('d50000000     ),  // 50MHz system clock
    .BAUD_RATE      ('d115200       )
)uart_byte_tx_inst0
(
    .clk            (sys_clk        ),  // system clock
    .rst_n          (reset_n        ),  // system reset, active low
    .tx_start       (tx_start       ),	// start with pos edge
    .tx_data        (tx_data        ),	// data need to transfer
    .tx_done        (tx_done        ),  // transfer done
    .tx_state       (tx_state       ),  // sending duration
    .rs232_tx       (rs485_rx       )	// uart transfer pin
);

wire    [15:0]  reg_03_01_o;
wire            reg_03_01_update;
wire            response_done;
reg     [7:0]   dev_addr;
modbus_rtu_slave_top #
(
    .CLK_FREQ       ('d50000000     ),  // 50MHz system clock
    .BAUD_RATE      ('d115200       )
)modbus_rtu_slave_top_inst0
(
    .clk                    (sys_clk            ),			// system clock
    .rst_n                  (reset_n            ),		// system reset, active low

    .dev_addr               (dev_addr           ),//改的有问题
    .read_04_01             (16'h5347           ),
    .read_04_02             (16'h7414           ),
    .read_04_03             (16'h2021           ),
    .read_04_04             (16'h0402           ),

    .reg_03_01_o            (reg_03_01_o        ),
    .reg_03_01_update       (reg_03_01_update   ),
    
    .rs485_rx               (rs485_rx           ),
    .rs485_tx               (rs485_tx           ),
    .rs485_oe               (rs485_oe           ),
    
    .response_done          (response_done      )
);

initial sys_clk = 1;
always #(`clk_period/2) sys_clk = ~sys_clk;

initial reset_n = 0;
always #(`clk_period*50) reset_n = 1'b1;

initial
begin
    tx_start = 0;
    tx_data = 8'h0;
    test = 0;
    #(`clk_period*50)
    dev_addr = 8'hf0;//变换设备地址
    send_frame(64'hf0_03_0001_0001_c0eb);
    @(posedge response_done)

    dev_addr = 8'h01;//变换设备地址
    #(`clk_period*20000)  
    send_frame(64'h01_03_0001_0001_d5ca);
    @(posedge response_done)

    #(`clk_period*20000)  
    send_frame(64'h01_06_0002_0005_e809);// illegal  
    @(posedge response_done)

    #(`clk_period*20000)             
    send_frame(64'h01_04_0001_0004_a009);     
    @(posedge response_done)

    #(`clk_period*20000)             
    send_frame(64'h01_04_0001_0003_e1cb);     
    @(posedge response_done)

    #(`clk_period*20000)
    send_frame(64'h01_04_0002_0001_900a);  
    @(posedge response_done)

    dev_addr = 8'hff;//变换设备地址
    #(`clk_period*20000)
    send_frame(64'hff_04_0002_0001_85d4);  
    @(posedge response_done)

    #(`clk_period*20000)             
    send_frame(64'hff_04_0002_0002_c5d5);     
    @(posedge response_done)

    dev_addr = 8'h01;//变换设备地址
    #(`clk_period*20000)             
    send_frame(64'h01_04_0002_0003_11cb);     
    @(posedge response_done)

    #(`clk_period*20000)             
    send_frame(64'h01_04_0003_0002_81cb);     
    @(posedge response_done)

    #(`clk_period*20000)             
    send_frame(64'h01_04_0003_0003_400b);// illegal      
    @(posedge response_done)
  
    #(`clk_period*20000)
    send_frame(64'h01_06_0001_0007_99c8);  
    @(posedge response_done)

    #(`clk_period*20000)
    send_frame(64'h01_03_0001_0001_d5ca);  
    @(posedge response_done)

    $display("simulation stop\n");

    $stop;	
end


integer   i;
parameter   BYTE_NUM = 8;
task send_frame(input [8*BYTE_NUM-1:0] frame_data);
	begin 
        #(`clk_period*5);
        for(i=BYTE_NUM;i>0;i=i-1)
        begin
            if(i!=BYTE_NUM)//发生第一个数据不需要检测tx_done
            begin
                @(negedge tx_done); 
            end
            #(`clk_period);
            tx_start <=1'b1;
            tx_data <= frame_data[(i*BYTE_NUM-1) -:8];//高8位
            #(`clk_period);
            tx_start <=1'b0;
        end
        #(`clk_period*50);
    end
endtask

endmodule



/*
checksum mismatch then do nothing//设备地址错误do nothing
illegal fuction code retrun 01 
illegal address return 02 //寄存器地址
illegal quantity return 03 //数据长度或数量

04功能码下共四个寄存器，如{DEV_ADDR,FUN_CODE,addr_data,CRC_L,CRC_H}
addr代表从哪个寄存器开始，data代表读几个寄存器数据    

读响应格式{DEV_ADDR，FUN_CODE，length,data,CRC_L,CRC_H}
length为1Byte,data为2Byte

写响应格式与发送写寄存器命令格式一致，相等

读命令异常和写异常响应格式为{SADDR, func_code|8'h80, exception, crc_out[7:0], crc_out[15:8]}
exception范围为01，02，03

写失败响应格式为{SADDR, func_code|8'h80, 04, crc_out[7:0], crc_out[15:8]}

*/