`timescale 1ns / 1ns
`define UD #1

module func_hander 
(
    input               clk             ,// system clock
    input               rst_n           ,// system reset, active low
    
    input   [7:0]       dev_addr        ,
    input               rx_message_done ,
    input   [7:0]       func_code       ,
    input   [15:0]      addr            ,
    input   [15:0]      data            ,
    input   [15:0]      crc_rx_code     ,
    
    input               exception_done  ,
    input   [7:0]       exception_in    ,
    
    input   [15:0]      read_03_01      ,
    input   [15:0]      read_04_01      ,
    input   [15:0]      read_04_02      ,
    input   [15:0]      read_04_03      ,
    input   [15:0]      read_04_04      ,
    
    output  reg [7:0]   tx_quantity     ,
    output  reg [7:0]   exception_out   ,
    
    output  reg [7:0]   func_code_r     ,
    output  reg [15:0]  addr_r          ,
    output  reg [15:0]  data_r          ,
    output  reg [15:0]  crc_rx_code_r   ,
    
    output  reg         dpram_wen       ,
    output  reg [7:0]   dpram_addr      ,
    output  reg [15:0]  dpram_wdata     ,   
    output  reg         reg_wen         ,
    output  reg [15:0]  reg_wdat        ,
    input               reg_w_done      ,
    input               reg_w_status    ,
    
    output  reg         handler_done
   
    
);

always@(posedge clk or negedge rst_n)
begin
    if( !rst_n )
    begin
        func_code_r <= `UD 8'h0;
        addr_r <= `UD 16'h0;
        data_r <= `UD 16'b0;
        crc_rx_code_r <= `UD 16'b0;
    end
    else
    begin
        if(rx_message_done)
        begin
            func_code_r <= `UD func_code;
            addr_r <= `UD addr;
            data_r <= `UD data;
            crc_rx_code_r <= `UD crc_rx_code; 
        end
    end
end

reg [7:0]   exception_in_r;
always@(posedge clk or negedge rst_n)
begin
    if( !rst_n )
    begin
        exception_in_r <= `UD 8'h0;
    end
    else
    begin
        if(exception_done)
        begin
            exception_in_r <= `UD exception_in;
        end
//        else if(handler_done)
//        begin
//            exception_in_r <= `UD 8'h0;
//        end
    end
end

reg [7:0]   op_state;
reg [7:0]   sub_state_03;
reg [7:0]   sub_state_04;
reg [7:0]   sub_state_06;
reg         FF;
reg [15:0]  raddr_index;
always@(posedge clk or negedge rst_n)
begin
    if( !rst_n )
    begin
        op_state <= `UD 8'h0;
        FF <= `UD 1'b1;
        sub_state_03 <= `UD 8'h0;
        sub_state_04 <= `UD 8'h0;
        sub_state_06 <= `UD 8'h0;
        handler_done <= `UD 1'b0;
        tx_quantity <= `UD 8'h0;
        exception_out <= `UD 8'h0;
        dpram_wen  <= `UD 1'b0;
        dpram_addr <= `UD 8'h0;
        dpram_wdata <= `UD 16'h0;
        raddr_index <= `UD 16'h0;
        reg_wen     <= `UD 1'b0;
        reg_wdat    <= `UD 16'h0;
    end
    else
    begin
        case(op_state)
        8'd0: // IDEL
        begin
            if(exception_done)
            begin
                if(exception_in==8'd1)
                begin
                    op_state <= `UD 8'd5;
                    exception_out <= `UD exception_in;
                    tx_quantity <= `UD 16'd0;
                end
                else if(exception_in==8'd2)
                begin
                    op_state <= `UD 8'd5;
                    exception_out <= `UD exception_in;
                    tx_quantity <= `UD 16'd0;
                end
                else if(exception_in==8'd3)
                begin
                    op_state <= `UD 8'd5;
                    exception_out <= `UD exception_in;
                    tx_quantity <= `UD 16'd0;
                end
                else if(exception_in==8'd0)
                begin
                    op_state <= `UD 8'd1;
                end
            end
            else
            begin
                op_state <= `UD 8'h0;
                FF <= `UD 1'b1;
                sub_state_03 <= `UD 8'h0;
                sub_state_04 <= `UD 8'h0;
                sub_state_06 <= `UD 8'h0;
                handler_done <= `UD 1'b0;
//                tx_quantity <= `UD 8'h0;
                //exception_out <= `UD 8'h0;
                dpram_wen  <= `UD 1'b0;
                dpram_addr <= `UD 8'h0;
                dpram_wdata <= `UD 16'h0;
                raddr_index <= `UD 16'h0;
                reg_wen     <= `UD 1'b0;
                reg_wdat    <= `UD 16'h0;
            end
        end
        8'd1: // normal handler start
        begin
            if(func_code==8'h03)
            begin
                op_state <= `UD 8'd2;
                exception_out <= `UD exception_in_r;
            end
            else if(func_code==8'h04)
            begin
                op_state <= `UD 8'd3;
                exception_out <= `UD exception_in_r;
            end
            else if(func_code==8'h06)
            begin
                op_state <= `UD 8'd4;
            end
        end
        8'd2:
        begin
            if(FF)
            begin
                FF <= `UD 1'b0;
                sub_state_03 <= `UD 8'd0;
                dpram_wen <= `UD 1'b1;
            end
            else
            begin
                case(sub_state_03)
                8'd0:
                begin
                    if(addr_r==16'h0001)
                    begin
                        dpram_addr <= `UD 8'h00;
                        dpram_wdata <= `UD read_03_01;
                        sub_state_03 <= `UD 8'd1;
                    end
                end
                8'd1:
                begin
                    op_state <= `UD 8'd5;
                    tx_quantity <= `UD 8'd1;
                    sub_state_03 <= `UD 8'd0;
                    dpram_wen <= `UD 1'b0;
                    FF <= `UD 1'b1;
                end
                default:
                begin
                    FF <= `UD 1'b1;
                    sub_state_03 <= `UD 8'd0;
                end
                endcase
            end
        end
        8'd3:
        begin
            if(FF)
            begin
                FF <= `UD 1'b0;
                sub_state_04 <= `UD 8'd0;
                dpram_wen <= `UD 1'b1;
            end
            else
            begin
                case(sub_state_04)
                8'd0:
                begin
                    raddr_index <= `UD addr_r;
                    sub_state_04 <= `UD 8'd1;
                end
                8'd1:
                begin                              
                    if(raddr_index < addr_r + data_r) 
                    begin
                        dpram_addr <= `UD (raddr_index-addr_r);
                        case(raddr_index)                 
                        8'h1:dpram_wdata <= `UD read_04_01;
                        8'h2:dpram_wdata <= `UD read_04_02;
                        8'h3:dpram_wdata <= `UD read_04_03;
                        8'h4:dpram_wdata <= `UD read_04_04;
                        default;
                        endcase
                        raddr_index <= `UD raddr_index + 1'b1;
                        sub_state_04 <= `UD 8'd1;
                    end
                    else
                    begin
                        sub_state_04 <= `UD 8'd2;
                    end
                end 
                8'd2:
                begin
                    op_state <= `UD 8'd5;
                    tx_quantity <= `UD data_r;
                    sub_state_04 <= `UD 8'd0;
                    dpram_wen <= `UD 1'b0;
                    FF <= `UD 1'b1;
                end
                default:
                begin
                    FF <= `UD 1'b1;
                    sub_state_04 <= `UD 8'd0;
                end
                endcase
            end
        end
        8'd4:
        begin
            if(FF)
            begin
                FF <= `UD 1'b0;
                sub_state_06 <= `UD 8'd0;
                reg_wen <= `UD 1'b1;
                reg_wdat <= `UD data_r;
            end
            else
            begin
                case(sub_state_06)
                8'd0:
                begin
                    if(addr_r==16'h0001)
                    begin
                        reg_wen <= `UD 1'b0;
                        sub_state_06 <= `UD 8'd1;
                    end
                    else
                    begin
                        op_state <= `UD 8'd0;
                        FF <= `UD 1'b1;
                    end
                end
                8'd1:
                begin
                    if(reg_w_done)
                    begin
                        if(reg_w_status) // write failed
                        begin
                            exception_out <= `UD 8'h04;
                            op_state <= `UD 8'd5;
                            tx_quantity <= `UD 16'd0;
                            sub_state_06 <= `UD 8'd0;
                            FF <= `UD 1'b1;
                        end
                        else
                        begin
                            exception_out <= `UD exception_in_r;
                            op_state <= `UD 8'd5;
                            tx_quantity <= `UD 16'd1;
                            sub_state_06 <= `UD 8'd0;
                            FF <= `UD 1'b1;
                        end
                    end
                end
                default:
                begin
                    FF <= `UD 1'b1;
                    sub_state_06 <= `UD 8'd0;
                end
                endcase
            end
        end
        
        8'd5:
        begin
            if(FF)
            begin
                FF <= `UD 1'b0;
                handler_done <= `UD 1'b1;
            end
            else
            begin
                FF <= `UD 1'b1;
                op_state <= `UD 8'd0;
                handler_done <= `UD 1'b0;
            end
        end
        
        default:
        begin
            op_state <= `UD 8'h0;
            FF <= `UD 1'b1;
            handler_done <= `UD 1'b0;
        end
        endcase
    end
end

endmodule