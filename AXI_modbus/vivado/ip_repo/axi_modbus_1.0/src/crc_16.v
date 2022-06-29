//-----------------------------------------------------------------------------
// Copyright (C) 2009 OutputLogic.com 
// This source file may be used and distributed without restriction 
// provided that this copyright statement is not removed from the file 
// and that any derivative work contains the original copyright notice 
// and the associated disclaimer. 
// 
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS 
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED 
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
//-----------------------------------------------------------------------------
// CRC module for data[7:0] ,   crc[15:0]=1+x^2+x^15+x^16;
//-----------------------------------------------------------------------------
`timescale 1ns / 1ns
`define UD #1
module crc_16(
    input               clk,
    input               rst_n,
    input               crc_en,
    input               crc_clr,  //crc数据复位信号 
    input      [7:0]    data_in,
    output     [15:0]   crc_out
);

    reg     [15:0]  lfsr_q;
    wire    [7:0 ]  data_in_c;
    wire    [15:0]  lfsr_c;
//输入待校验8位数据,需要先将高低位互换
    assign  data_in_c = {data_in[0],data_in[1],data_in[2],data_in[3],data_in[4],data_in[5],data_in[6],data_in[7]};

    assign  lfsr_c[0 ] = crc_en & (lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in_c[0] ^ data_in_c[1] ^ data_in_c[2] ^ data_in_c[3] ^ data_in_c[4] ^ data_in_c[5] ^ data_in_c[6] ^ data_in_c[7]);
    assign  lfsr_c[1 ] = crc_en & (lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in_c[1] ^ data_in_c[2] ^ data_in_c[3] ^ data_in_c[4] ^ data_in_c[5] ^ data_in_c[6] ^ data_in_c[7]);
    assign  lfsr_c[2 ] = crc_en & (lfsr_q[8] ^ lfsr_q[9] ^ data_in_c[0] ^ data_in_c[1]  );
    assign  lfsr_c[3 ] = crc_en & (lfsr_q[9] ^ lfsr_q[10] ^ data_in_c[1] ^ data_in_c[2] );
    assign  lfsr_c[4 ] = crc_en & (lfsr_q[10] ^ lfsr_q[11] ^ data_in_c[2] ^ data_in_c[3]);
    assign  lfsr_c[5 ] = crc_en & (lfsr_q[11] ^ lfsr_q[12] ^ data_in_c[3] ^ data_in_c[4]);
    assign  lfsr_c[6 ] = crc_en & (lfsr_q[12] ^ lfsr_q[13] ^ data_in_c[4] ^ data_in_c[5]);
    assign  lfsr_c[7 ] = crc_en & (lfsr_q[13] ^ lfsr_q[14] ^ data_in_c[5] ^ data_in_c[6]);
    assign  lfsr_c[8 ] = crc_en & (lfsr_q[0] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in_c[6] ^ data_in_c[7]);
    assign  lfsr_c[9 ] = crc_en & (lfsr_q[1] ^ lfsr_q[15] ^ data_in_c[7]);
    assign  lfsr_c[10] = lfsr_q[2];
    assign  lfsr_c[11] = lfsr_q[3];
    assign  lfsr_c[12] = lfsr_q[4];
    assign  lfsr_c[13] = lfsr_q[5];
    assign  lfsr_c[14] = lfsr_q[6];
    assign  lfsr_c[15] = crc_en & (lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in_c[0] ^ data_in_c[1] ^ data_in_c[2] ^ data_in_c[3] ^ data_in_c[4] ^ data_in_c[5] ^ data_in_c[6] ^ data_in_c[7]); 

    always @(posedge clk or negedge rst_n) 
    begin
        if(!rst_n)
            lfsr_q <= `UD 16'hff_ff;
        else if(crc_clr)                             //CRC校验值复位
            lfsr_q <= `UD 16'hff_ff;
        else begin
            lfsr_q <= `UD crc_en ? lfsr_c : lfsr_q;
        end
    end

//输出检验完的16位数据,同样需要先将高低位互换   
    assign crc_out = {lfsr_q[0],lfsr_q[1],lfsr_q[2],lfsr_q[3],lfsr_q[4],lfsr_q[5],lfsr_q[6],lfsr_q[7],lfsr_q[8],lfsr_q[9],lfsr_q[10],lfsr_q[11],lfsr_q[12],lfsr_q[13],lfsr_q[14],lfsr_q[15]};   

endmodule // crc




