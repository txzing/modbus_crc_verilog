`timescale 1ns / 1ns
`define UD #1

module ct_15t_gen #
(
    parameter           CLK_FREQ   = 'd50000000,// 50MHz
    parameter           BAUD_RATE  = 'd9600    //
)
(
    input               clk_in,			// system clock
    input               rst_n_in,		// system reset, active low

    input               rx_done,        // pos-pulse for 1 tick indicates 1 byte transfer done
    input               rx_state,

    output  reg         rx_drop_frame       // if intervel >1.5T == 1
);

//1T


localparam BPS_PARAM = (CLK_FREQ/BAUD_RATE);
reg [4:0] bps_cnt;

reg cnt_en;
always@(posedge clk_in or negedge rst_n_in)
begin
    if(!rst_n_in)
    begin
        cnt_en <= `UD 1'b0;
    end
    else
    begin
        if(rx_done)
        begin
            cnt_en <= `UD 1'b1;
        end
        else if(rx_state||bps_cnt>=6'd15)
        begin
            cnt_en <= `UD 1'b0;
        end
    end
end

reg [15:0]  baud_rate_cnt;
always@(posedge clk_in or negedge rst_n_in)
begin
    if(!rst_n_in)
    begin
        baud_rate_cnt <= `UD 16'd0;
    end
    else
    begin
        if(cnt_en)
        begin
            if(baud_rate_cnt >= BPS_PARAM - 1)//波特率计数器
            begin
                baud_rate_cnt <= `UD 16'd0;
            end
            else
            begin
                baud_rate_cnt <= `UD baud_rate_cnt + 1'b1;
            end
        end
        else
        begin
            baud_rate_cnt <= `UD 16'd0;
        end
    end
end

// generate bps_clk signal
reg bps_clk;
always @ (posedge clk_in or negedge rst_n_in)
begin
	if(!rst_n_in) 
    begin
		bps_clk <= `UD 1'b0;
    end
	else
    begin
        if(baud_rate_cnt >= BPS_PARAM - 1 )
        begin
		    bps_clk <= `UD 1'b1;	//一个周期脉冲信号，拉高代表一个波特率计数结束，也即接收1bit时间结束
        end
	    else 
        begin
		    bps_clk <= `UD 1'b0;
        end
    end
end

//bps counter
always@(posedge clk_in or negedge rst_n_in)
begin
    if(!rst_n_in)	
    begin
	    bps_cnt <= `UD 6'd0;
    end
    else
    begin
        if(bps_cnt>=6'd15)//计满16bit
        begin
	        bps_cnt <= `UD 6'd0;
        end
        else
        begin
            if(cnt_en)
            begin
                if(bps_clk)//在接收过程中，对接收bit时间计算
                begin
	                bps_cnt <= `UD bps_cnt + 1'b1;
                end
                else
                begin
	                bps_cnt <= `UD bps_cnt;
                end
            end
            else
            begin
                bps_cnt <= `UD 6'd0;
            end
        end
    end
end

always@(posedge clk_in or negedge rst_n_in)
begin
    if(!rst_n_in)	
    begin
	    rx_drop_frame <= `UD 1'b0;
    end
    else
    begin
        if(bps_cnt>=6'd15)
        begin
	        rx_drop_frame <= `UD 1'b1;
        end
        else
        begin
	        rx_drop_frame <= `UD 1'b0;
        end
    end
end

endmodule
