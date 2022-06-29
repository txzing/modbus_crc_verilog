`timescale 1ns / 1ns
`define UD #1

module ct_35t_gen #
(
    parameter           CLK_FREQ   = 'd50000000,// 50MHz
    parameter           BAUD_RATE  = 'd9600    //
)
(
    input    clk         ,// system clock
    input    rst_n       ,// system reset, active low

    input    rx_done     ,// pos-pulse for 1 tick indicates 1 byte transfer done
    input    rx_state    ,

    output   rx_new_frame // if intervel >3.5T == 1
);

localparam BPS_PARAM = (CLK_FREQ/BAUD_RATE);
parameter  DELAY_CNT = 35;

reg         cnt_en_flag;//计数器
reg [19:0]  bps_cnt    ;//每一帧数据发送完毕后延时一段时间
wire        add_bps_cnt;
wire        end_bps_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cnt_en_flag <= `UD 1'b0;
    end
    else
    begin
        if(rx_done)
        begin
            cnt_en_flag <= `UD 1'b1;
        end
        else if(rx_state||end_bps_cnt)
        begin
            cnt_en_flag <= `UD 1'b0;
        end
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
assign end_bps_cnt = bps_cnt && bps_cnt >= DELAY_CNT*(BPS_PARAM-1);
assign rx_new_frame = end_bps_cnt;

endmodule
