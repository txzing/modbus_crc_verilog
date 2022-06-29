`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2022 05:40:15 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top
(
    input                   sys_clk  ,
    input  [3:0]            dev_addr ,
    input                   rs485_rx ,
    output  wire            rs485_tx ,
    output  wire            rs485_oe
);

//wire sys_clk;

wire reset_n;
//IBUFDS IBUFDS_inst 
//(
//    .O          (sys_clk_200),   // 1-bit output: Buffer output
//    .I          (sys_clk_p),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
//    .IB         (sys_clk_n)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
//);

reset_module reset_module_inst
(
    .clk        (sys_clk),
    .rst_o      (),
    .rst_n_o    (reset_n)
);

//clk_div #
//(
//    .N          (4)
//)
//clk_div_inst
//(
//    .reset_n    (1'b1),      // Reset Input
//    .clk_in     (sys_clk_200),     //Input Clock
//    .clk_out    (sys_clk)     // Output Clock
//);

wire    [15:0]  reg_03_01_o;
wire            reg_03_01_update;
wire            response_done;
modbus_rtu_slave_top #
(
    .CLK_FREQ       ('d50000000    ),  //system clock
    .BAUD_RATE      ('d115200       )
)modbus_rtu_slave_top_inst0
(
    .clk                    (sys_clk            ),			// system clock
    .rst_n                  (reset_n            ),		// system reset, active low
    
    .dev_addr               ({4'hf, dev_addr}   ),
    .read_04_01             (16'h5347           ),
    .read_04_02             (16'h7414           ),
    .read_04_03             (16'h2021           ),
    .read_04_04             (16'h0402           ),

    .reg_03_01_o            (reg_03_01_o        ),
    .reg_03_01_update       (reg_03_01_update   ),
    
    .rs485_rx               (rs485_rx           ),
    .rs485_tx               (rs485_tx           ),
    .rs485_oe               (rs485_oe           ),
    
    .response_done          (response_done      )
);


// ila_0 ila_inst (
// 	.clk(sys_clk), // input wire clk
// 	.probe0(dev_addr),
// 	.probe1(modbus_rtu_slave_top_inst0.rx_data)
// );

endmodule
