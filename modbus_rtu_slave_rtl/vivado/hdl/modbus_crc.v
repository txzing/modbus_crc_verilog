`timescale 1ns / 1ns
`define UD #1
//CRC-16/modbus   x(16) + x(15) + x(2) + 1
module modbus_crc #
(
    parameter           BYTES   = 'd6
)
(
    input               clk_in,			// system clock
    input               rst_n_in,		// system reset, active low
    
    input [8*BYTES-1:0] data_in,
    input               rx_message_done,
    
    output  reg         crc_done,
    output  reg [15:0]  crc_out
);

reg [8*BYTES-1:0] data_buf;
reg [7:0] ct_frame;
reg [3:0] ct_8bit;
reg [7:0] i;
reg [15:0] crc_reg;
always@(posedge clk_in or negedge rst_n_in)
begin
    if( !rst_n_in )
    begin
        i <= `UD 7'd0;                     
        crc_done <= `UD 1'b0;           //校验完成，输出一个周期高电平
        ct_frame <= `UD 8'd0;
        ct_8bit <= `UD 4'd0;
        crc_reg <= `UD 16'b0;
        crc_done <= `UD 1'b0;
        crc_out <= `UD 16'b0;
        data_buf <= `UD {(8*BYTES) {1'b0}} ;
    end
    else
    begin
        case ( i )
        7'd0 :
        begin
            ct_frame <= `UD 8'd0;
            ct_8bit <= `UD 4'd0;
            if( rx_message_done )
                i <= `UD 7'd1;
            else
                i <= `UD 7'd0; 
        end 
        7'd1 :
        begin
            data_buf <= `UD data_in;
            crc_reg <= `UD 16'hffff;
            i <= `UD 7'd2;
        end
        7'd2 :
        begin
            if( ct_frame < 8'd6 )
            begin
                ct_8bit <= `UD 4'd0;
                ct_frame <= `UD ct_frame + 8'd1;
                crc_reg[7:0] <= `UD data_buf[7:0] ^ crc_reg[7:0];
                i <= `UD 7'd3; 
            end 
            else
                i <= `UD 7'd5;
        end 
        7'd3 :  
        begin
            if( ct_8bit < 4'd8 )
            begin
                ct_8bit <= `UD ct_8bit + 4'd1;
                if( crc_reg[0] )
                begin
                    crc_reg <= `UD crc_reg >> 1;
                    i <= `UD 7'd4;
                end
                else
                begin
                    crc_reg <= `UD crc_reg >> 1;
                    i <= `UD 7'd3;
                end
            end 
            else 
            begin
                data_buf <= `UD data_buf >> 8;
                i <= `UD 7'd2;
            end 
        end 
        7'd4 :
        begin
            i <= `UD 7'd3;
            crc_reg <= `UD crc_reg ^ 16'hA001;
        end 
        7'd5 :
        begin
            //crc_out <= `UD { crc_reg[7:0],crc_reg[15:8] };
            crc_out <= `UD crc_reg;
            crc_done <= `UD 1'b1;
            i <= `UD 7'd6;
        end
        7'd6 :
        begin
            crc_done <= `UD 1'b0;
            i <= `UD 7'd0;
        end 
        default;
        endcase
    end
end

endmodule
