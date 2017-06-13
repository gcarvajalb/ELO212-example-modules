module lab_6(
	input CLK100MHZ,
	input [15:0]SW,
	input PS2_CLK,
	input PS2_DATA,
	//input rst,
	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
	);
	
	localparam CUADRILLA_XI = 		212;
	localparam CUADRILLA_XF = 		812;
	
	localparam CUADRILLA_YI = 		184;
	localparam CUADRILLA_YF = 		584;
	
	wire [10:0]vc_visible,hc_visible;
	wire CLK82MHZ;
	
	clk_wiz_0 inst(
		// Clock out ports  
		.clk_out1(CLK82MHZ),
		// Status and control signals               
		.reset(1'b0), 
		//.locked(locked),
		// Clock in ports
		.clk_in1(CLK100MHZ)
		);
		
	//driver_vga_640x480 m_driver(CLK82MHZ, VGA_HS, VGA_VS,hc_visible,vc_visible);
	driver_vga_1024x768 m_driver(CLK82MHZ, VGA_HS, VGA_VS, hc_visible, vc_visible);
	kbd_ms m_kd(CLK82MHZ, 1'b0, PS2_DATA, PS2_CLK, data, data_type, kbs_tot, parity_error);
	
	wire kbs_tot;
	wire [7:0] data;
	wire [2:0] data_type;
	wire parity_error;
	
	
	wire [10:0]hc_template, vc_template;
	wire [2:0]matrix_x;
	wire [1:0]matrix_y;
	wire lines;
	
	template_6x4_600x400 template_1(CLK82MHZ, hc_visible, vc_visible, matrix_x, matrix_y, lines);
	
	reg [11:0]VGA_COLOR;
	
	wire in_sq, dr;
	hello_world m_hw(CLK82MHZ, 1'b0, hc_visible, vc_visible, in_sq, dr);
	
	always@(*)
		if((hc_visible != 0) && (vc_visible != 0))
		begin
			if(dr == 1'b1)
				VGA_COLOR = {12'h555};
			else if (in_sq == 1'b1)
				VGA_COLOR = {12'hFFFF};
			else if((hc_visible > CUADRILLA_XI) && (hc_visible <= CUADRILLA_XF) && (vc_visible > CUADRILLA_YI) && (vc_visible <= CUADRILLA_YF))
				if(lines)
					VGA_COLOR = {12'h000};
				else
					VGA_COLOR = {3'h7, {2'b0, matrix_x} + {3'b00, matrix_y}, 4'h3};
			else
				VGA_COLOR = {12'h00F};
		end
		else
			VGA_COLOR = {12'd0};

	assign {VGA_R, VGA_G, VGA_B} = VGA_COLOR;
	
endmodule
