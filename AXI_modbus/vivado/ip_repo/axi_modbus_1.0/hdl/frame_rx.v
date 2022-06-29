`timescale 1ns / 1ns
`define UD #1

module frame_rx 
(
    input               clk             ,// system clock
    input               rst_n           ,// system reset, active low

    input   [7:0]       dev_addr        ,
    input               rx_drop_frame   ,// 1.5T interval
    input               rx_new_frame    ,// 3.5T interval
    input               rx_done         ,// 
    input   [7:0]       rx_data         ,//

    input	        	rx_crc_error    ,//校验出错
    input	        	rx_crc_done	    ,//校验无误

    output  reg         rx_crc_vld      ,
    output  reg         rx_message_done ,
    output  reg [7:0]   func_code       ,
    output  reg [15:0]  addr            ,
    output  reg [15:0]  data            ,
    output  reg [15:0]  crc_rx_code
);


reg      rx_message_sig;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rx_message_sig <= `UD 1'b1;
    end
    else if(rx_new_frame)
    begin
        rx_message_sig <= `UD 1'b1;//代表可以接收新帧
    end
    else if(rx_done)
    begin
        rx_message_sig <= `UD 1'b0;
    end
    else
    begin
        rx_message_sig <= `UD rx_message_sig;
    end
end


reg [6:0] state_cnt;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state_cnt <= `UD 7'd0;
        rx_message_done <= `UD 1'b0;
        func_code <= `UD 8'b0;
        addr <= `UD 16'b0;
        data <= `UD 16'b0;
        crc_rx_code <= `UD 16'b0;
        rx_crc_vld <= `UD 1'b0;
    end
    else
    begin
        case(state_cnt)
        7'd0 : 
        begin
            if( rx_message_sig & rx_done )
                state_cnt <= `UD 7'd1;
            else if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                rx_message_done <= `UD 1'b0;
                func_code <= `UD 8'b0;
                addr <= `UD 16'b0;
                data <= `UD 16'b0;
                crc_rx_code <= `UD 16'b0;
                rx_crc_vld <= `UD 1'b0;
            end
            else
                state_cnt <= `UD 7'd0;
        end 
        7'd1 :
        begin
            if( rx_drop_frame )//大于1.5T还没接收到数据
                state_cnt <= `UD 7'd0;
            else if( rx_data == dev_addr )//新帧第一个字节为设备地址
              state_cnt <= `UD 7'd2;
            else 
              state_cnt <= `UD 7'd0;
        end
        7'd2 :
        begin
            if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                func_code <= `UD 8'b0;
            end
            else if( rx_done )                
            begin
               func_code <= `UD rx_data;
               state_cnt <= `UD 7'd3;
            end 
            else 
                state_cnt <= `UD 7'd2; 
        end
        7'd3 :
        begin
            if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                addr[15:0] <= `UD 16'b0;
            end
            else if( rx_done )
            begin
                addr[15:8] <= `UD rx_data;
                state_cnt <= `UD 7'd4;
            end 
            else 
                state_cnt <= `UD 7'd3;
        end
        7'd4 :  
        begin
            if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                addr[15:0] <= `UD 16'b0;
            end
            else if( rx_done )
            begin
                addr[7:0] <= `UD rx_data;
                state_cnt <= `UD 7'd5;
            end 
            else 
                state_cnt <= `UD 7'd4;
        end
        7'd5 :
        begin
            if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                data[15:0] <= `UD 16'b0;
            end
            else if( rx_done )
            begin
                data[15:8] <= `UD rx_data;
                state_cnt <= `UD 7'd6;
            end 
            else
                state_cnt <= `UD 7'd5;
        end
        7'd6 :
        begin
            if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                data[15:0] <= `UD 16'b0;
            end
            else if( rx_done )
            begin
                data[7:0] <= `UD rx_data;
                state_cnt <= `UD 7'd7;
            end 
            else
                state_cnt <= `UD 7'd6;
        end
        7'd7 :
        begin
            if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                crc_rx_code[15:0] <= `UD 16'b0;
            end
            else if( rx_done )
            begin
                crc_rx_code[7:0] <= `UD rx_data;
                state_cnt <= `UD 7'd8;
            end 
            else 
                state_cnt <= `UD 7'd7;   
        end
        7'd8 :
        begin
            if( rx_drop_frame )
            begin
                state_cnt <= `UD 7'd0;
                crc_rx_code[15:0] <= `UD 16'b0;
            end
            else if( rx_done )
            begin
                crc_rx_code[15:8] <= `UD rx_data;
                state_cnt <= `UD 7'd9;
            end 
            else 
                state_cnt <= `UD 7'd8;
        end
        7'd9 :
        begin
            rx_crc_vld <= `UD 1'b1;//start crc check
            state_cnt <= `UD 7'd10;
        end
        7'd10 :
        begin
            if(rx_crc_error && !rx_crc_done)
            begin
                rx_message_done <= `UD 1'b0;
                state_cnt <= `UD 7'd0;
            end
            else if(!rx_crc_error && rx_crc_done)
            begin
                rx_message_done <= `UD 1'b1;
                state_cnt <= `UD 7'd11;
            end
            else 
            begin
                rx_message_done <= `UD 1'b0;
                rx_crc_vld <= `UD 1'b0;
                state_cnt <= `UD state_cnt;
            end

        end
        7'd11 :
        begin
            rx_message_done <= `UD 1'b0;
            state_cnt <= `UD 7'd0;
        end 

        default;
        endcase
    end
end

endmodule
