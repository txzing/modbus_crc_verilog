`timescale 1ns / 1ns
`define UD #1

module tx_handler
(
    input               clk_in,			// system clock
    input               rst_n_in,		// system reset, active low
    
    input   [7:0]       dev_addr ,
    input               handler_done,
    input   [7:0]       exception,
    
    input   [7:0]       func_code,
    input   [15:0]      addr,
    input   [15:0]      data,
    input   [15:0]      crc_code,
    
    output  reg         tx_start,
    output  reg [39:0]  exception_seq,
    output  reg [63:0]  code06_response
);

reg             calc_start;
wire            crc_done;
wire    [15:0]  crc_out;
modbus_crc #
(
    .BYTES          ('d3            )
)modbus_crc_inst0
(
    .clk_in         (clk_in         ), // system clock
    .rst_n_in       (rst_n_in       ), // system reset, active low
    .data_in        ({exception,func_code|8'h80,dev_addr}),
    .rx_message_done(calc_start     ),
    .crc_done       (crc_done       ),
    .crc_out        (crc_out        )
);

reg [7:0]   op_state;
reg FF;
always@(posedge clk_in or negedge rst_n_in)
begin
    if( !rst_n_in )
    begin
        op_state <= `UD 8'd0;
        FF <= `UD 1'b1;
        calc_start <= `UD 1'b0;
        code06_response <= `UD 64'b0;
        exception_seq <= `UD 40'b0;
        tx_start <= `UD 1'd0;
    end
    else
    begin
        case(op_state)
        8'd0:
        begin
            if(handler_done)
            begin
                op_state <= `UD 8'd1;
                FF <= `UD 1'b1;
            end
            else
            begin
                op_state <= `UD 8'd0;
                FF <= `UD 1'b1;
            end
        end
        8'd1:
        begin
            if(exception==8'h00)
            begin
                if(func_code==8'h06)
                begin
                    op_state <= `UD 8'd2;
                    exception_seq <= `UD 40'b0;
                end
                else
                begin
                    op_state <= `UD 8'd3;
                    exception_seq <= `UD 40'b0;
                    code06_response <= `UD 64'b0;
                end
            end
            else
            begin
                op_state <= `UD 8'd4;
            end
        end
        
        8'd2: // normal write response
        begin
            code06_response <= `UD {dev_addr, func_code, addr, data, crc_code[7:0], crc_code[15:8]};
            tx_start <= `UD 1'd1;
            op_state <= `UD 8'd5;
        end
        8'd3: // normal read response
        begin
            tx_start <= `UD 1'd1;
            op_state <= `UD 8'd5;
        end
        8'd4: // exception response
        begin
            if(FF)
            begin
                calc_start <= `UD 1'd1;
                FF <= `UD 1'b0;
            end
            else
            begin
                if(crc_done)
                begin
                    exception_seq <= `UD {dev_addr, func_code|8'h80, exception, crc_out[7:0], crc_out[15:8]};
                    FF <= `UD 1'b1;
                    op_state <= `UD 8'd5;
                    tx_start <= `UD 1'd1;
                end
                else
                begin
                    calc_start <= `UD 1'd0;
                end
            end
        end
        8'd5: // handle over
        begin
            op_state <= `UD 8'd0;
            FF <= `UD 1'b1;
            tx_start <= `UD 1'd0;
        end
        
        default:
        begin
            op_state <= `UD 8'd0;
            FF <= `UD 1'b1;
            tx_start <= `UD 1'd0;
        end
        endcase
    end
end

/*
always@(posedge clk_in or negedge rst_n_in)
begin
    if( !rst_n_in )
    begin
        
    end
    else
    begin
        
    end
end
*/
endmodule