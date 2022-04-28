`timescale 1ns / 1ns
`define UD #1

module uart_byte_rx #
(
    parameter           CLK_FREQ   = 'd50000000,// 50MHz
    parameter           BAUD_RATE  = 'd9600    //
)
(
    input               clk     ,			// system clock
    input               rst_n   ,		// system reset, active low

    output  reg [7:0]   rx_data ,		// data need to transfer
    output  reg         rx_state,       // recieving duration
    output	reg         rx_done ,        // pos-pulse for 1 tick indicates 1 byte transfer done
    input		        rs232_rx		// uart transfer pin
);

localparam BPS_PARAM = (CLK_FREQ/BAUD_RATE)>>4; // oversample by x16

// sample sum registers, sum of 6 samples
reg [2:0] rx_data_r [0:7];
reg [2:0] START_BIT;
reg [2:0] STOP_BIT;

reg [7:0] bps_cnt;

reg	rs232_rx0,rs232_rx1,rs232_rx2;	
//Detect negedge of rs232_rx
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rs232_rx0 <= `UD 1'b0;
		rs232_rx1 <= `UD 1'b0;
		rs232_rx2 <= `UD 1'b0;
	end else begin
		rs232_rx0 <= `UD rs232_rx;
		rs232_rx1 <= `UD rs232_rx0;
		rs232_rx2 <= `UD rs232_rx1;
	end
end
wire	neg_rs232_rx;
assign  neg_rs232_rx = rs232_rx2 & ~rs232_rx1;	

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
    begin
		rx_state <= `UD 1'b0;
    end
	else
    begin
        if(neg_rs232_rx)
        begin
            rx_state <= `UD 1'b1;
        end
	    else if(rx_done || (bps_cnt == 8'd12 && (START_BIT > 2))) // at least 3 of 6 samples are 1, START_BIT not ok
        begin
		    rx_state <= `UD 1'b0;
        end
	    else
        begin
		    rx_state <= `UD rx_state;
        end
    end
end

reg [15:0]  baud_rate_cnt;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        baud_rate_cnt <= `UD 16'd0;
    end
    else
    begin
        if(rx_state)
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
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) 
    begin
		bps_clk <= `UD 1'b0;
    end
	else
    begin 
        if(baud_rate_cnt == BPS_PARAM>>1 )//sample in cnt center
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

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)	
    begin
	    bps_cnt <= `UD 8'd0;
    end
    else
    begin
        if(bps_cnt == 8'd159 || (bps_cnt == 8'd12 && (START_BIT > 2))) 
        begin
	        bps_cnt <= `UD 8'd0;
        end
        else if(baud_rate_cnt >= BPS_PARAM - 1'b1 )
        begin
	        bps_cnt <= `UD bps_cnt + 1'b1;
        end
        else
        begin
	        bps_cnt <= `UD bps_cnt;
        end
    end
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
    begin
		rx_done <= `UD 1'b0;
    end
	else
    begin
        if(bps_cnt == 8'd159)
        begin
		    rx_done <= `UD 1'b1;
        end
	    else
        begin
		    rx_done <= `UD 1'b0;
        end
    end
end


		
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
    begin
		START_BIT <= `UD 3'd0;
		rx_data_r[0] <= `UD 3'd0;
		rx_data_r[1] <= `UD 3'd0;
		rx_data_r[2] <= `UD 3'd0;
		rx_data_r[3] <= `UD 3'd0;
		rx_data_r[4] <= `UD 3'd0;
		rx_data_r[5] <= `UD 3'd0;
		rx_data_r[6] <= `UD 3'd0;
		rx_data_r[7] <= `UD 3'd0;
		STOP_BIT <= `UD 3'd0;
	end
	else
    begin
        if(bps_clk)
        begin
		    case(bps_cnt)
			0:
            begin
				START_BIT <= `UD 3'd0;
				rx_data_r[0] <= `UD 3'd0;
				rx_data_r[1] <= `UD 3'd0;
				rx_data_r[2] <= `UD 3'd0;
				rx_data_r[3] <= `UD 3'd0;
				rx_data_r[4] <= `UD 3'd0;
				rx_data_r[5] <= `UD 3'd0;
				rx_data_r[6] <= `UD 3'd0;
				rx_data_r[7] <= `UD 3'd0;
				STOP_BIT <= `UD 3'd0;			
            end
            // 160 bps_cnt from 0 to 159 in a byte, each bit has 16 bps_clk (0~15), 
            // sample form 6 to 11 is the middle 6 of 16 bps_clk
			6,7,8,9,10,11:
            begin
                START_BIT <= `UD START_BIT + rs232_rx2;
            end
			22,23,24,25,26,27:
            begin
                rx_data_r[0] <= `UD rx_data_r[0] + rs232_rx2;
            end
			38,39,40,41,42,43:
            begin
                rx_data_r[1] <= `UD rx_data_r[1] + rs232_rx2;
            end
			54,55,56,57,58,59:
            begin
                rx_data_r[2] <= `UD rx_data_r[2] + rs232_rx2;
            end
			70,71,72,73,74,75:
            begin
                rx_data_r[3] <= `UD rx_data_r[3] + rs232_rx2;
            end
			86,87,88,89,90,91:
            begin
                rx_data_r[4] <= `UD rx_data_r[4] + rs232_rx2;
            end
			102,103,104,105,106,107:
            begin
                rx_data_r[5] <= `UD rx_data_r[5] + rs232_rx2;
            end
			118,119,120,121,122,123:
            begin
                rx_data_r[6] <= `UD rx_data_r[6] + rs232_rx2;
            end
			134,135,136,137,138,139:
            begin
                rx_data_r[7] <= `UD rx_data_r[7] + rs232_rx2;
            end
			150,151,152,153,154,155:
            begin
                STOP_BIT <= `UD STOP_BIT + rs232_rx2;
            end
			default:
			begin
				START_BIT <= `UD START_BIT;
				rx_data_r[0] <= `UD rx_data_r[0];
				rx_data_r[1] <= `UD rx_data_r[1];
				rx_data_r[2] <= `UD rx_data_r[2];
				rx_data_r[3] <= `UD rx_data_r[3];
				rx_data_r[4] <= `UD rx_data_r[4];
				rx_data_r[5] <= `UD rx_data_r[5];
				rx_data_r[6] <= `UD rx_data_r[6];
				rx_data_r[7] <= `UD rx_data_r[7];
				STOP_BIT <= `UD STOP_BIT;						
			end
		    endcase
        end
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
    begin
		rx_data <= `UD 8'd0;
    end
	else
    begin
        if(bps_cnt == 8'd159)
        begin
            // rx_data_r[x] has 3 width, actual sample sum range 0~6, rx_data_r[x][2] means sum/4
            // if sum >=4 sample value == 1, else sum < 4 sample value == 0
		    rx_data[0] <= `UD rx_data_r[0][2];
		    rx_data[1] <= `UD rx_data_r[1][2];
		    rx_data[2] <= `UD rx_data_r[2][2];
		    rx_data[3] <= `UD rx_data_r[3][2];
		    rx_data[4] <= `UD rx_data_r[4][2];
		    rx_data[5] <= `UD rx_data_r[5][2];
		    rx_data[6] <= `UD rx_data_r[6][2];
		    rx_data[7] <= `UD rx_data_r[7][2];
	    end
    end
end


endmodule
