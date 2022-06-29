`timescale 1ns / 1ns
`define UD      #1

module clk_div #(
    parameter   N = 32'd5
)
(
    reset_n,      // Reset Input
    clk_in,     //Input Clock
    clk_out     // Output Clock
);

//-----------Input Ports---------------
input   clk_in;
input   reset_n;
//-----------Output Ports---------------
output  clk_out;
//-------------Code Start-----------------
	
// Posedge counter
reg     [31:0]   pos_cnt;
always @ (posedge clk_in or negedge reset_n)
begin
    if (!reset_n)
    begin
      pos_cnt <= `UD 0;
    end
    else
    begin
      pos_cnt <= `UD (pos_cnt == N-1) ? 0 : pos_cnt + 1;
    end
end
	
// Neg edge counter
reg     [31:0]   neg_cnt;
always @ (negedge clk_in or negedge reset_n)
begin
    if (!reset_n)
    begin
      neg_cnt <= `UD 0;
    end
    else
    begin
      neg_cnt <= `UD (neg_cnt == N-1) ? 0 : neg_cnt + 1;
    end
end

reg clk_out;
always @ (*)
begin
    if (N[0])//N[0],可根据此来判断，就不用进行取余，耗费资源，偶数最低位为0，奇数最低位为1
    begin
        clk_out = ((pos_cnt < (N+1)>>1) && (neg_cnt < (N+1)>>1));//奇数倍分频
    end
    else
    begin
        clk_out = (pos_cnt < N/2);//偶数倍分频
    end
end
// assign  clk_out = ((pos_cnt != 2) && (neg_cnt != 2));
// assign  clk_out = ((pos_cnt < (N+1)/2) && (neg_cnt < (N+1)/2));

endmodule

