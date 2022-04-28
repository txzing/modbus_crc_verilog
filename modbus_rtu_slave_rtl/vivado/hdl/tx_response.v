`timescale 1ns / 1ns
`define UD #1

module tx_response #
(
    parameter           CLK_FREQ   = 'd50000000,// 50MHz
    parameter           BAUD_RATE  = 'd9600   //
)
(
    input               clk                ,// system clock
    input               rst_n              ,// system reset, active low

    input               tx_06_rp_start     ,	
    input               tx_exp_rp_start    ,	
    input               tx_03_04_rp_start  ,

    input   [7:0]       tx_quantity        ,
    input   [39:0]      exception_seq      ,
    input   [63:0]      code06_response    ,
    input   [103:0]     code03_04_response ,

    output  reg         response_done      ,
    output  wire        rs485_tx           ,
    output  reg         rs485_tx_en
);

localparam BPS_PARAM = (CLK_FREQ/BAUD_RATE);

reg         tx_start_pos;

reg         cnt_en;
reg         response_done_r;

reg  [7:0]  rs485_tx_data;
reg         rs485_tx_start;
wire        tx_done;
reg  [3:0]  byte_cnt;

reg  [3:0]  op_state;
reg         FF;

reg         cnt_en_flag;//计数器
reg [19:0]  bps_cnt    ;//每一帧数据发送完毕后延时一段时间
wire        add_bps_cnt;
wire        end_bps_cnt;


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n )
    begin
        op_state <= `UD 8'd0;
        FF <= `UD 1'b1;                     
        rs485_tx_data <= `UD 8'h0;
        rs485_tx_start <= `UD 1'b0;
        response_done_r <= `UD 1'b0;
        rs485_tx_en <= `UD 1'b0;
        response_done <= `UD 1'b0; 
        tx_start_pos <= `UD 1'b0;
        byte_cnt <= `UD 4'd0;
    end
    else
    begin
        case(op_state)
        8'd0:
        begin
            if(tx_exp_rp_start)
            begin
                rs485_tx_en <= `UD 1'b1;
                op_state <= `UD 8'd1;
            end
            else if(tx_06_rp_start)//06,normal
            begin
                rs485_tx_en <= `UD 1'b1;
                op_state <= `UD 8'd3;
            end
            else if(tx_03_04_rp_start)
            begin // func_code==8'h03||func_code==8'h04 ，and normal
                rs485_tx_en <= `UD 1'b1;
                op_state <= `UD 8'd5;
            end
            else
            begin
                op_state <= `UD 8'd0;
                FF <= `UD 1'b1;
                rs485_tx_data <= `UD 8'h0;
                rs485_tx_start <= `UD 1'b0;
                response_done_r <= `UD 1'b0;
                rs485_tx_en <= `UD 1'b0;
                response_done <= `UD 1'b0;
                tx_start_pos <= `UD 1'b0;
                byte_cnt <= `UD 4'd0;
            end
        end  

        8'd1:
        begin
            if(FF)
            begin
                tx_start_pos <= `UD 1'b1;
                FF <= `UD 1'b0;
            end
            else
            begin
                tx_start_pos <= `UD 1'b0;
                if(end_bps_cnt)
                begin
                    rs485_tx_data <= `UD exception_seq[39:32];
                    FF <= `UD 1'b1;
                    op_state <= `UD 8'd2;
                    rs485_tx_start <= `UD 1'b0;
                end
                else
                begin
                    FF <= `UD 1'b0;
                end
            end
        end    

        8'd2:
        begin
            if(FF)
            begin
                rs485_tx_start <= `UD 1'b1;
                FF <= `UD 1'b0;
            end
            else
            begin
                if(tx_done)
                begin
                    if(byte_cnt < 4'd4)  
                    begin
                        FF <= `UD 1'b1;
                        rs485_tx_data <= `UD exception_seq[(31-8*byte_cnt) -:8];
                        byte_cnt <= `UD byte_cnt + 1'b1;
                        rs485_tx_start <= `UD 1'b0; 
                    end        
                    if(byte_cnt == 4'd4)
                    begin
                        op_state <= `UD 8'd7;
                        byte_cnt <= `UD 4'd0;
                        response_done_r <= `UD 1'b1;
                        rs485_tx_data <= `UD 8'h0;
                        FF <= `UD 1'b1;
                    end 
                    else begin
                        op_state <= `UD 8'd2;
                        response_done_r <= `UD 1'b0;
                    end           
                end
                else
                begin
                    rs485_tx_start <= `UD 1'b0;
                    FF <= `UD 1'b0;
                end
            end
        end 

        8'd3:
        begin
            if(FF)
            begin
                tx_start_pos <= `UD 1'b1;
                FF <= `UD 1'b0;
            end
            else
            begin
                tx_start_pos <= `UD 1'b0;
                if(end_bps_cnt)
                begin
                    rs485_tx_data <= `UD code06_response[63:56];
                    FF <= `UD 1'b1;
                    op_state <= `UD 8'd4;
                    rs485_tx_start <= `UD 1'b0;
                end
                else
                begin
                    FF <= `UD 1'b0;
                end
            end
        end

        8'd4:                                                                                
        begin
            if(FF)
            begin
                rs485_tx_start <= `UD 1'b1;
                FF <= `UD 1'b0;
            end
            else
            begin
                if(tx_done)
                begin  
                    if(byte_cnt < 4'd7)  
                    begin
                        FF <= `UD 1'b1;
                        rs485_tx_data <= `UD code06_response[(55-8*byte_cnt) -:8];
                        byte_cnt <= `UD byte_cnt + 1'b1;
                        rs485_tx_start <= `UD 1'b0; 
                    end  
                    if(byte_cnt == 4'd7)
                    begin
                        op_state <= `UD 8'd7;
                        byte_cnt <= `UD 4'd0;
                        response_done_r <= `UD 1'b1;
                        rs485_tx_data <= `UD 8'h0;
                        FF <= `UD 1'b1;
                    end 
                    else begin
                        op_state <= `UD 8'd4;
                        response_done_r <= `UD 1'b0;
                    end                     
                end
                else                
                begin
                    rs485_tx_start <= `UD 1'b0;
                    FF <= `UD 1'b0;
                end
            end
        end

        8'd5:
        begin
            if(FF)
            begin
                tx_start_pos <= `UD 1'b1;
                FF <= `UD 1'b0;
            end
            else
            begin
                tx_start_pos <= `UD 1'b0;
                if(end_bps_cnt)
                begin
                    rs485_tx_data <= `UD code03_04_response[(((tx_quantity<<1)+5)<<3)-1 -:8];
                    FF <= `UD 1'b1;
                    op_state <= `UD 8'd6;
                    rs485_tx_start <= `UD 1'b0;
                end
                else
                begin
                    FF <= `UD 1'b0;
                end
            end
        end

        8'd6:                                                                                
        begin
            if(FF)
            begin
                rs485_tx_start <= `UD 1'b1;
                FF <= `UD 1'b0;
            end
            else
            begin
                if(tx_done)
                begin  
                    if(byte_cnt < ((tx_quantity<<1)+4))  
                    begin
                        FF <= `UD 1'b1;
                        rs485_tx_data <= `UD code03_04_response[(((tx_quantity<<1)- byte_cnt +4)<<3)-1 -:8];
                        byte_cnt <= `UD byte_cnt + 1'b1;
                        rs485_tx_start <= `UD 1'b0; 
                    end  
                    if(byte_cnt == ((tx_quantity<<1)+4))
                    begin
                        op_state <= `UD 8'd7;
                        byte_cnt <= `UD 4'd0;
                        response_done_r <= `UD 1'b1;
                        rs485_tx_data <= `UD 8'h0;
                        FF <= `UD 1'b1;
                    end 
                    else begin
                        op_state <= `UD 8'd6;
                        response_done_r <= `UD 1'b0;
                    end                     
                end
                else                
                begin
                    rs485_tx_start <= `UD 1'b0;
                    FF <= `UD 1'b0;
                end
            end
        end

        8'd7:
        begin
            if(FF)
            begin
                response_done_r <= `UD 1'b0;
                FF <= `UD 1'b0;
            end
            else if(end_bps_cnt)
            begin
                op_state <= `UD 8'd0;
                FF <= `UD 1'b1;
                rs485_tx_en <= `UD 1'b0;
                response_done <= `UD 1'b1;
            end
            else
            begin
                rs485_tx_data <= `UD 8'h0;
                rs485_tx_start <= `UD 1'b0;
                FF <= `UD 1'b0;
            end
        end
        default:;
        endcase
    end
end

//一帧数据中两字节发送间隔小于1.5T
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cnt_en <= `UD 1'b0;
    end
    else
    begin
        if(tx_start_pos||response_done_r)
        begin
            cnt_en <= `UD 1'b1;
        end
        else if(end_bps_cnt)
        begin
            cnt_en <= `UD 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin 
    if(!rst_n)begin
        cnt_en_flag <= `UD 1'b0;
    end 
    else if(tx_start_pos||response_done_r)
    begin 
        cnt_en_flag <= `UD 1'b1;       
    end 
    else if(end_bps_cnt)
    begin 
        cnt_en_flag <= `UD 1'b0;       
    end 
end

always @(posedge clk or negedge rst_n)begin 
   if(!rst_n)begin
        bps_cnt <= `UD 0;
    end 
    else if(add_bps_cnt)begin 
            if(end_bps_cnt)begin 
                bps_cnt <= `UD 0;
            end
            else begin 
                bps_cnt <= `UD bps_cnt + 1;
            end 
    end
   else  begin
       bps_cnt <= `UD 0;
    end
end 

assign add_bps_cnt = cnt_en_flag;
assign end_bps_cnt = bps_cnt && bps_cnt == 10*(BPS_PARAM-1);

uart_byte_tx #
(
    .CLK_FREQ       (CLK_FREQ       ),  // 50MHz system clock
    .BAUD_RATE      (BAUD_RATE      )
)uart_byte_tx_inst0
(
    .clk            (clk         ),  // system clock
    .rst_n          (rst_n       ),  // system reset, active low
    .tx_start       (rs485_tx_start ),	// start with pos edge
    .tx_data        (rs485_tx_data  ),	// data need to transfer
    .tx_done        (tx_done        ),  // transfer done
    .tx_state       (               ),  // sending duration
    .rs232_tx       (rs485_tx		)	// uart transfer pin
);

endmodule
