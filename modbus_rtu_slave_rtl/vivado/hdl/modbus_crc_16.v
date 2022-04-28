/**************************************功能介绍***********************************
Copyright:			
Date     :			
Author   :			
Version  :			
Description:何时进行数据校验，何时进行数据发送		
*********************************************************************************/
`timescale 1ns / 1ns
`define UD #1
module modbus_crc_16 
( 
    input				            clk		,
    input				            rst_n	,

//frame_rx interface                
    input   [7:0]                   dev_addr ,
    input   [7:0]                   func_code,
    input   [15:0]                  addr,
    input   [15:0]                  data,
    input   [15:0]                  crc_rx_code,
    input                           rx_crc_vld,
    output  reg       	            rx_crc_error,
    output  reg       	            rx_crc_done	,

//
    input   [7:0]                   tx_quantity,
    input   [15:0]                  rd_dpram_data,
    output  reg [7:0]               rd_dpram_addr,


//          
    input                           handler_done,
    input   [7:0]                   exception,
//
    output  reg                     tx_06_rp_start,	
    output  reg                     tx_exp_rp_start,	
    output  reg                     tx_03_04_rp_start,	
    output  reg [39:0]              exception_seq ,//异常响应数据
    output  reg [63:0]              code06_response,//06正常响应
    output  reg [103:0]             code03_04_response//功能码03，04的响应,最长13个字节

);	

reg                     crc_en      ;
reg                     crc_clr     ;
reg                     rx_crc_flag ;
reg                     tx_crc_flag ;
reg  [7:0]              data_in     ;      
reg  [3:0]              byte_cnt    ;
reg  [87:0]             check_byte  ;//最长需校验11个字节

reg  [7:0]              exception_r;
wire [15:0]             crc_out;

reg [7:0]   dev_addr_r ;
reg [7:0]   func_code_r;
reg [15:0]  addr_r;
reg [15:0]  data_r;
reg [15:0]  crc_rx_code_r;
reg         rx_crc_vld_r;
reg         handler_done_r;

always@(posedge clk or negedge rst_n)
begin
    if( !rst_n )
    begin
        dev_addr_r <= `UD 8'h0;
        func_code_r <= `UD 8'h0;
        addr_r <= `UD 16'h0;
        data_r <= `UD 16'b0;
        crc_rx_code_r <= `UD 16'b0;
        rx_crc_vld_r <= `UD 1'b0;
    end
    else
    begin if(rx_crc_vld)
    begin
        dev_addr_r <= `UD dev_addr;
        func_code_r <= `UD func_code;
        addr_r <= `UD addr;
        data_r <= `UD data;
        crc_rx_code_r <= `UD crc_rx_code;
        rx_crc_vld_r <= rx_crc_vld; 
    end
    else 
    begin
         rx_crc_vld_r <= `UD 1'b0;
    end
    end
end

//将handler_done_r和exception_r寄存一拍进行同步
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        handler_done_r <= `UD 1'b0;
        exception_r <= `UD 8'h0;
    end 
    else if(handler_done)begin 
        handler_done_r <= `UD 1'b1;
        exception_r <= `UD exception; 
    end 
    else if(handler_done_r)
    begin 
        handler_done_r <= `UD 1'b0;
    end
    else
    begin
        handler_done_r <= handler_done_r;
        exception_r <= `UD exception_r;      
    end
end

reg crc_done;//打一拍，与校验结果同步
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        crc_done <= `UD 1'b0;
    end 
    else if(rx_crc_flag && byte_cnt == 6 && !tx_crc_flag)
    begin 
        crc_done <= `UD 1'b1;
    end
    else if(tx_crc_flag && byte_cnt == ((tx_quantity<<1)+3) && !exception_r)//03,04,normal read response crc check down
    begin 
        crc_done <= `UD 1'b1;
    end  
    else if(tx_crc_flag && byte_cnt == 3 && exception_r)//exception response crc check down
    begin 
        crc_done <= `UD 1'b1;
    end 
    else
    begin
        crc_done <= `UD 1'b0;
    end 
end


//接收数据时的校验判断
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        rx_crc_done = `UD 1'b0;
        rx_crc_error = `UD 1'b0;
        rx_crc_flag <= `UD 1'b0;
        tx_crc_flag <= `UD 1'b0; 
        check_byte <= `UD 88'd0;
        rd_dpram_addr <= `UD 8'd0;
    end 
    else if(rx_crc_vld_r && !rx_crc_flag)begin//开始一帧数据的校验
        rx_crc_flag <= `UD 1'b1;
        check_byte <= `UD {dev_addr_r,func_code_r,addr_r,data_r};//6字节数据
    end 
    else if(crc_done && rx_crc_flag)//一帧数据校验完毕
    begin 
        rx_crc_done = `UD (crc_out == crc_rx_code)?1'b1:1'b0;
        rx_crc_error = `UD (crc_out != crc_rx_code)?1'b1:1'b0;
        rx_crc_flag <= `UD 1'b0;
        check_byte <= `UD 88'd0;
    end
    else if(crc_done && tx_crc_flag)//异常代码校验完毕
    begin
        tx_crc_flag <= `UD 1'b0;
        rd_dpram_addr <= `UD 8'd0; 
        check_byte <= `UD 88'd0;
    end  
    else if(!exception_r && func_code_r!=8'h06 && !tx_crc_flag && rd_dpram_addr != 8'd0)//若tx_quantity不等于1
    begin
        if(rd_dpram_addr == tx_quantity)     
        begin
            rd_dpram_addr <= `UD 8'd0;
            check_byte <= `UD {check_byte[71:0],rd_dpram_data};//最后一次移位 
            tx_crc_flag <= `UD 1'b1;//数据已装载完  
        end 
        else if(rd_dpram_addr != 8'd1)//延迟一拍取数据
        begin
            rd_dpram_addr <= `UD rd_dpram_addr + 1'b1;  
            check_byte <= `UD {check_byte[71:0],rd_dpram_data};//左移16位
        end
        else
        begin
            rd_dpram_addr <= `UD rd_dpram_addr + 1'b1;    
        end
    end 
    else if(handler_done_r && !exception_r && func_code_r!=8'h06 && !tx_crc_flag && rd_dpram_addr <= tx_quantity )//03,04,normal read response
    begin
        tx_crc_flag <= `UD tx_quantity == 8'h01 ? 1'b1 :1'b0;//若tx_quantity等于1
        rd_dpram_addr <= `UD rd_dpram_addr + 1'b1;        
        check_byte <= `UD {dev_addr_r,func_code_r,data_r[7:0],rd_dpram_data};
    end
    else if(handler_done_r && exception_r && !tx_crc_flag)//exception code crc check
    begin
        tx_crc_flag <= `UD 1'b1;        
        check_byte <= `UD {dev_addr_r,func_code_r|8'h80,exception_r};//3字节数据 
    end
    else 
    begin 
        rd_dpram_addr <= `UD 8'd0;
        rx_crc_done = `UD 1'b0;
        rx_crc_error = `UD 1'b0;
    end 
end


//指示开始数据发送与数据拼接
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        tx_06_rp_start <= `UD 1'd0; 
        tx_exp_rp_start	<= `UD 1'd0; 
        tx_03_04_rp_start <= `UD 1'd0; 
        code06_response <= `UD 64'd0;
        exception_seq <= `UD 40'd0;
        code03_04_response <= `UD 103'd0;  
    end 
    else if(handler_done_r && !exception_r && func_code_r==8'h06)
    begin//06，normal respond
        code06_response <= `UD {dev_addr_r, func_code_r, addr_r, data_r, crc_rx_code_r[7:0], crc_rx_code_r[15:8]}; 
        tx_06_rp_start <= `UD 1'd1;   
    end 
    else if(crc_done && tx_crc_flag && !exception_r && func_code_r !=8'h06)
    begin//03,04,normal read response
        tx_03_04_rp_start <= `UD 1'd1; 
        code03_04_response <= `UD {check_byte, crc_out[7:0], crc_out[15:8]};  
    end 
    else if(crc_done && tx_crc_flag && exception_r)//异常代码校验完毕
    begin//exception response
        exception_seq <= `UD {dev_addr_r, func_code_r|8'h80, exception_r, crc_out[7:0], crc_out[15:8]};
        tx_exp_rp_start <= `UD 1'd1;   
    end 
    else begin 
        tx_06_rp_start <= `UD 1'd0; 
        tx_exp_rp_start	<= `UD 1'd0; 
        tx_03_04_rp_start <= `UD 1'd0; 
    end 
end


always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        crc_en <= `UD 1'b0;
        data_in <= `UD 8'd0;
        byte_cnt <= `UD 4'd0;
        crc_clr <= `UD 1'b0; 
    end   
    else if(byte_cnt <= 5 && rx_crc_flag) 
    begin 
        crc_en <= 1'b1;
        crc_clr <= `UD 1'b0; 
        byte_cnt <= `UD byte_cnt + 1;
        data_in <= `UD check_byte[(47 - byte_cnt*8) -:8];        
    end
    else if((byte_cnt <= (tx_quantity<<1)+2) && tx_crc_flag && !exception_r && !crc_done)//03_04
    begin 
        crc_en <= `UD 1'd1;//开始进行crc校验 
        crc_clr <= `UD 1'b0; 
        byte_cnt <= `UD byte_cnt + 1;
        data_in <= `UD check_byte[(((tx_quantity<<1)+3 - byte_cnt)*8)-1 -:8];
    end  
    else if(byte_cnt <= 2 && tx_crc_flag && exception_r && !crc_done)//exception response 
    begin 
        crc_en <= `UD 1'd1;//开始进行crc校验 
        crc_clr <= `UD 1'b0; 
        byte_cnt <= `UD byte_cnt + 1;
        data_in <= `UD check_byte[(23 - byte_cnt*8) -:8];
    end      
    else begin 
        crc_en <= 1'b0;
        crc_clr <= `UD 1'b1; 
        byte_cnt <= `UD 4'd0;
        data_in <= `UD 8'd0;  
    end 
end


crc_16  u_crc_16(
/*input              */.clk     (clk),
/*input              */.rst_n   (rst_n),
/*input              */.crc_en  (crc_en),
/*input              */.crc_clr (crc_clr),
/*input      [7:0]  */.data_in (data_in),
/*output reg [15:0]  */.crc_out (crc_out)
);    

                        
endmodule