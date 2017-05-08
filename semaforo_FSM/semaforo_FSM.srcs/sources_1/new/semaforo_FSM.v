`timescale 1ns / 1ps

module semaforo(
	input clock,
	input reset,
	input TA, TB,
	output reg [2:0] LA, LB,
	output [1:0] state_out //esta salida es irrelevante para la funcionalidad
	                       // solo se incluye para poder visualizarla en el testbech.
	                       //Para la implementacion final debe eliminarse como salida.
    );
    
    reg[1:0] next_state, state; 

    assign state_out = state; // esta senal es solo para debugging. Debe eliminarse en implementacion final
    
    //state encoding
    localparam S0 = 2'd0;
    localparam S1 = 2'd1;
    localparam S2 = 2'd2;
    localparam S3 = 2'd3;

    // one combinational block computes the next_state and outputs for the
    // current state
    always@(*) begin
        //using default assignments here allows to save space, helps on readability,
        // and reduces the changes of errors
        next_state = state;
    	LA = 3'b100;
    	LB = 3'b100;
    	
    	case (state)
    		S0: begin
    			     LA = 3'b010;
    			     if(TA == 1'b0) begin
    			 	   next_state = S1;
    		         end
    		    end

            S1: begin
                    LA = 3'b001;
                    next_state = S2;
                end
            
            S2: begin
                    LA = 3'b100;
                    LB = 3'b010;
                    if(TB == 1'b0) begin
                        next_state = S3;
                    end
                end

            S3: begin
                    LA = 3'b100;
                    LB = 3'b001;
                if(TB == 1'b0) begin
                    next_state = S0;
                end
                end                
    	endcase
    end	

    //when clock ticks, update the state
    always@(posedge clock or posedge reset)
    	if(reset)
    		state <= S0;
    	else
    		state <= next_state;
endmodule
