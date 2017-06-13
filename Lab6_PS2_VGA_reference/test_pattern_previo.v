`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:		Mauricio Solis
// 
// Create Date:    08:39:01 05/28/2015 
// Design Name: 
// Module Name:    test_pattern_previo_640x480 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: driver_vga_640x480,videotestpattern_640x480
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// Este módulo debería mostrar 8 columnas con los colores RGB
// basicos y una fila de color rojo al final de la pantalla
//////////////////////////////////////////////////////////////////////////////////
module test_pattern_previo_640x480(CLK100MHZ, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);
	input CLK100MHZ;
	output VGA_HS,VGA_VS;
	output [3:0]VGA_R,VGA_G,VGA_B;


	wire [9:0]vc_visible,hc_visible;
	reg [1:0]counter_clk_vga, counter_clk_vga_next;
	wire clk_vga;

	always@(*)
		counter_clk_vga_next = counter_clk_vga + 2'd1;

	always@(posedge CLK100MHZ)
		counter_clk_vga <= counter_clk_vga_next;
	
	assign clk_vga = counter_clk_vga[1];
	wire [2:0]rgb_out;
	
	driver_vga_640x480 m_driver(clk_vga, VGA_HS, VGA_VS, hc_visible, vc_visible);
	videotestpattern_640x480 m_pattern(clk_vga, hc_visible, vc_visible, rgb_out);

	assign VGA_R={4{rgb_out[2]}};
	assign VGA_G={4{rgb_out[1]}};
	assign VGA_B={4{rgb_out[0]}};

endmodule