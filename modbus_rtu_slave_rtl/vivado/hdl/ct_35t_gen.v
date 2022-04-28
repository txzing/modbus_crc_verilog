`timescale 1ns / 1ns
`define UD #1

module ct_35t_gen #
(
    parameter           CLK_FREQ   = 'd50000000,// 50MHz
    parameter           BAUD_RATE  = 'd9600    //
)
(
    input               clk_in,			// system clock
    input               rst_n_in,		// system reset, active low

    input               rx_done,        // pos-pulse for 1 tick indicates 1 byte transfer done
    input               rx_state,

    output  reg         rx_new_frame       // if intervel >3.5T == 1
);

localparam BPS_PARAM = (CLK_FREQ/BAUD_RATE);
reg [5:0] bps_cnt;

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
        else if(rx_state||bps_cnt>=6'd35)
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
            if(baud_rate_cnt >= BPS_PARAM - 1)
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
		    bps_clk <= `UD 1'b1;	
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
        if(bps_cnt>=6'd35)
        begin
	        bps_cnt <= `UD 6'd0;
        end
        else
        begin
            if(cnt_en)
            begin
                if(bps_clk)
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
	    rx_new_frame <= `UD 1'b0;
    end
    else
    begin
        if(bps_cnt>=6'd35)
        begin
	        rx_new_frame <= `UD 1'b1;
        end
        else
        begin
	        rx_new_frame <= `UD 1'b0;
        end
    end
end

endmodule
