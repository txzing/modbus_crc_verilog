`timescale 1ns / 1ns
`define UD #1

module exceptions
(
    input               clk             ,// system clock
    input               rst_n           ,// system reset, active low
    
    input               rx_message_done ,//一帧消息正确接收完毕
    input   [7:0]       func_code       ,
    input   [15:0]      addr            ,
    input   [15:0]      data            ,
    
    output  reg         exception_done  ,
    output  reg [7:0]   exception
);

reg [7:0]   func_code_r;
reg [15:0]  addr_r;
reg [15:0]  data_r;
reg         rx_message_done_r;


always@(posedge clk or negedge rst_n)
begin
    if( !rst_n )
    begin
        func_code_r     <= `UD 8'b0;
        addr_r          <= `UD 16'b0;
        data_r          <= `UD 16'b0;
        rx_message_done_r <= `UD 1'b0;
    end
    else
    begin
        if(rx_message_done)
        begin
            func_code_r     <= `UD func_code;
            addr_r          <= `UD addr;
            data_r          <= `UD data;
            rx_message_done_r <= `UD 1'b1;
        end
        else if(exception_done)
        begin
            func_code_r     <= `UD 8'b0;
            addr_r          <= `UD 16'b0;
            data_r          <= `UD 16'b0;
            rx_message_done_r <= `UD 1'b0;
        end
    end
end


always@(posedge clk or negedge rst_n)
begin
    if( !rst_n )
    begin
        exception_done <= `UD 1'b0;
        exception <= `UD 8'h00;
    end
    else if(exception_done)
    begin
        exception_done <= `UD 1'b0;
        exception <= `UD 8'h00;
    end
    else
    begin
        if(rx_message_done_r)
        begin
            if((func_code_r!=8'h03)&&(func_code_r!=8'h04)&&(func_code_r!=8'h06))
            begin
                exception_done <= `UD 1'b1;
                exception <= `UD 8'h01;//illegal fuction code retrun 01
            end
            else
            begin
                if(func_code_r==8'h03)
                begin
                    if(addr==16'h0001)
                    begin
                        if(data>16'h0001)
                        begin
                            exception_done <= `UD 1'b1;
                            exception <= `UD 8'h03;//illegal quantity return 03
                        end
                        else
                        begin
                            exception_done <= `UD 1'b1;
                            exception <= `UD 8'h0;
                        end
                    end
                    else
                    begin
                        exception_done <= `UD 1'b1;
                        exception <= `UD 8'h02;//illegal reg address return 02
                    end
                end
                else if(func_code_r==8'h04)
                begin
                    if(addr+data<=16'h0005)
                    begin
                        exception_done <= `UD 1'b1;
                        exception <= `UD 8'h0;
                    end
                    else if(addr>16'h0004)
                    begin
                        exception_done <= `UD 1'b1;
                        exception <= `UD 8'h02;
                    end
                    else
                    begin
                        exception_done <= `UD 1'b1;
                        exception <= `UD 8'h03;
                    end
                end
                else if(func_code_r==8'h06)
                begin
                    if(addr==16'h0001)
                    begin
                        if(data>16'h18)
                        begin
                            exception_done <= `UD 1'b1;
                            exception <= `UD 8'h03;
                        end
                        else
                        begin
                            exception_done <= `UD 1'b1;
                            exception <= `UD 8'h0;
                        end
                    end
                    else
                    begin
                        exception_done <= `UD 1'b1;
                        exception <= `UD 8'h02;
                    end
                end
            end
        end
    end
end

endmodule
