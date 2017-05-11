module FDCE #(parameter N=8)
(	input clk,
	input RST_BTN_n,
	input [N-1:0] switches,
	input retain,
	output [N-1:0] leds
);

    reg [N-1:0] Q, Q_next;
    
    assign reset = ~RST_BTN_n;
    assign leds = Q;

	always @(posedge clk) begin
	   if (reset) begin
	       Q <= 2'd0;
	   end else begin
	       Q <= Q_next;
	   end
	end

	always @(*) begin
        Q_next = Q;
        
		case (retain)
		  1'b0: 	  Q_next = switches;
		  1'b1: 	  ;
        endcase
	end

endmodule