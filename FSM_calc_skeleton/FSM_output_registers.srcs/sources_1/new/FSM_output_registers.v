module FSM_output_registers
(	input clk_100M,
	input reset_n,
	input [3:0] switches,
	input [4:0] button,
	output [3:0] leds
);

	wire button_c_push; // Pulso asociado al boton central (Enter)

	/* Reloj externo de 100 MHz (es solo un renombre) */
	wire clk = clk_100M;

    reg [1:0] ALU_in1, next_ALU_in1;
    
	/* Estados de la máquina */
	localparam S1 = 'b00;
	localparam S2 = 'b01;
	localparam S3 = 'b10;
	
	reg [1:0] state, next_state;
	wire fsm_reset = ~reset_n;

	assign leds = ALU_in1;

	pb_debouncer_wrapper deb_btn_center (
		.clk(clk),
		.pb(button[4]),
		.pb_state(button[0]),
		.pb_down(button_c_push),
		.pb_up()
	);

	always @(*) begin
        next_state = state;
        
		case (state)
		  S1: 	  if (button_c_push)
		                  next_state = S2;
                      		  
		  S2: 	  if (button_c_push)
                          next_state = S3;
                      	
		  S3:      if (button_c_push)
                          next_state = S1;
        endcase
	end

	/* Registrar el estado */
	always @(posedge clk) begin
		if (fsm_reset)
			state <= S1;
		else
			state <= next_state;
	end


	always @(*) begin
        next_ALU_in1 = ALU_in1;

		case (state)
		  S1: 	  next_ALU_in1 = switches;
		  S2: 	  ;
		  S3:     ;
      endcase
	end
		
	always @(posedge clk) begin
	   if (fsm_reset) begin
	       ALU_in1 <= 2'd0;
	   end else begin
	       ALU_in1 <= next_ALU_in1;
	   end
	end

endmodule