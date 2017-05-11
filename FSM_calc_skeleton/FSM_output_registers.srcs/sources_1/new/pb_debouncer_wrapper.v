`timescale 1ns / 1ps

module pb_debouncer
#(
	parameter C_WIDTH = 20 // Counter width
)(
	input clk,
	input pb,

	output reg pb_state,
	output pb_down,
	output pb_up
);

	reg [1:0] pb_sync_shift;
	always @(posedge clk)
		pb_sync_shift <= {pb_sync_shift[0], pb};

	reg [C_WIDTH-1:0] counter;
	wire counter_max = (counter == {C_WIDTH{1'b1}});

	wire pb_sync = pb_sync_shift[1];
	wire pb_idle = (pb_state == pb_sync);

	always @(posedge clk) begin
		if (pb_idle)
			counter <= 'd0;
		else begin
			counter <= counter + 'd1;
			if (counter_max) begin
				pb_state <= ~pb_state;
			end
		end
	end

	assign pb_down = ~pb_idle & counter_max & ~pb_state;
	assign pb_up = ~pb_idle & counter_max & pb_state;

endmodule

module pb_debouncer_alt
#(
	parameter C_WIDTH = 20 // Counter width
)(
	input clk,
	input pb,

	output reg pb_state,
	output pb_down,
	output pb_up
);

	/* Shift register for input synchronization */
	reg [1:0] pb_sync_shift;
	wire pb_sync = pb_sync_shift[1];
	always @(posedge clk)
		pb_sync_shift <= {pb_sync_shift[0], pb};

	reg [C_WIDTH-1:0] counter;
	wire counter_min = (counter == 'd0);
	wire counter_max = (counter == (2 ** C_WIDTH - 1));
	
	wire pb_idle = (pb_state == pb_sync);

	always @(posedge clk) begin
		if (pb_sync == 1'b0 && ~counter_min)
			counter <= counter - 'd1;
		else if (pb_sync == 1'b1 && ~counter_max)
			counter <= counter + 'd1;
		else
			counter <= counter;
	end

	always @(posedge clk) begin
		if (counter_min)
			pb_state <= 1'b0;
		else if (counter_max)
			pb_state <= 1'b1;
		else
			pb_state <= pb_state;
	end

	assign pb_down = ~pb_idle & counter_max & ~pb_state;
	assign pb_up = ~pb_idle & counter_min & pb_state;

endmodule

module pb_debouncer2
#(
	parameter C_WIDTH = 20 // Counter width
)(
	input clk,
	input rst,
	input pb,
	output reg pb_state,
	output reg pb_negedge,
	output reg pb_posedge
);
	
	reg [1:0] pb_sync;		// Flip Flops para sincronizar.
	reg [1:0] pb_sync_next;	// Etapa combinacional
	
	reg [1:0] button_state, button_state_next;
	
	reg [C_WIDTH-1:0] pb_cnt;
	
	wire pb_cnt_max = &pb_cnt;	// Se hace el AND de todos los bits
	
/////////////////////////   sincronizando la entrada con un reloj.   //////////////////
	always @(*)
		{pb_sync_next} = {pb_sync[0], pb};
	
	always @(posedge clk or posedge rst)
		if (rst)
			pb_sync <= 2'b00;
		else
			pb_sync <= pb_sync_next;
///////////////////////////////////////////////////////////////////////////////////////
///   Desde aca en adelante se debera utilizar pb_sync[1] como si fuera el boton.  ////
	
	localparam PB_IDLE = 2'b01;
	localparam PB_COUNT = 2'b10;
	localparam PB_STABLE = 2'b11;
	
	/////// Etapa combinacional para el cambio de estado //////////
	always @(*) begin
		button_state_next = PB_IDLE; //default value
		case (button_state)
		PB_IDLE:
			if (pb_sync[1] == 1'b1)
				button_state_next = PB_COUNT;
			else
				button_state_next = PB_IDLE;
		PB_COUNT:
			if (pb_cnt_max == 1'b1)
				button_state_next = PB_STABLE;
			else if (pb_sync[1] == 1'b0)
				button_state_next = PB_IDLE;
			else
				button_state_next = PB_COUNT;
		PB_STABLE:
			if (pb_sync[1] == 1'b0)
				button_state_next = PB_IDLE;
			else
				button_state_next = PB_STABLE;
		endcase
	end
	
	//registrando el estado
	always @(posedge clk or posedge rst)
		if (rst)
			button_state <= PB_IDLE;
		else
			button_state <= button_state_next;
	
	//registrando las salidas
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			{pb_negedge, pb_posedge, pb_state} <= 3'b000;
			pb_cnt <= 16'd0;
		end else begin
			{pb_negedge, pb_posedge, pb_state} <= 3'b000;
			pb_cnt <= 16'd0;

			case (button_state) 
			PB_COUNT: begin
				pb_posedge <= (pb_cnt_max == 1'b1);
				pb_cnt <= pb_cnt + 1'b1;
			end	
			PB_STABLE: begin
				pb_negedge <= (pb_sync[1] == 1'b0);
				pb_state <= 1'b1;
			end
			endcase
		end
	end
endmodule

module pb_debouncer_wrapper
#(
	parameter C_WIDTH = 20 // Counter width
)(
	input clk,
	input pb,

	output pb_state,
	output pb_down,
	output pb_up
);

	pb_debouncer2 #(
		.C_WIDTH(C_WIDTH)
	) pb_inst (
		.clk(clk),
		.rst(1'b0),
		.pb(pb),
		.pb_state(pb_state),
		.pb_negedge(pb_up),
		.pb_posedge(pb_down)
	);

endmodule