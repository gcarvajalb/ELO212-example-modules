`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// video_testpattern.v -- basic video test pattern generator
//
// Author:  W. Freund, UTFSM, Valparaiso, Chile
//          03/05/06, 14/06/12
// Modified: Mauricio Solis 03/06/2013
// Modified: Mauricio Solis 28/05/2014
// Modified: Mauricio Solís 09/06/2017
////////////////////////////////////////////////////////////////////////////////

module videotestpattern_640x480(clk_vga,hc_visible,vc_visible,rgb_out);
	input clk_vga;				
	input [9:0]hc_visible;
	input [9:0]vc_visible;
	output [2:0] rgb_out;
	reg [2:0]rgb_value, rgb_value_next;
	reg [5:0] col, col_next;
	
	always@(*)
	begin
		if (hc_visible == 'd0)
			{rgb_value_next, col_next} = {3'd0,6'd5};
		else if(vc_visible <= 9'd300)
		begin
			if( hc_visible > {col,4'b0000} )
				{rgb_value_next, col_next} = {rgb_value + 3'd1, col + 6'd5};
			else
				{rgb_value_next, col_next} = {rgb_value, col};
		end
		else
			{rgb_value_next, col_next} = {3'b100, 6'd0};
	end

	always @(posedge clk_vga) 
	begin
		col <= col_next;
		rgb_value <= rgb_value_next;
	end
	
	assign rgb_out = ((hc_visible>0) && (vc_visible>0))? rgb_value : 3'd0; 

endmodule

