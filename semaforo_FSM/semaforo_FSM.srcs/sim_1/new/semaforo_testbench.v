`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// testbenches requires a module without inputs or outputs
// It's only a "virtual" modulo. We cannot implement hardware with this!!!
module testbench();
  
    // We need to give values at the inputs, so we define them as registers  
	reg clock;
	reg reset;
	reg TA, TB;
	
	//The outputs are wires. We don't connect them to anything, but we need to 
	// declare them to visualize them in the output timing diagram
	wire [2:0] LA, LB;
	wire [1:0] state; 
	
	// an instance of the Device Under Test
	semaforo DUT(
        .clock (clock),
        .reset (reset),
        .TA (TA),
        .TB (TB),
        .LA (LA),
        .LB (LB),
        .state_out (state)
        );
            
	// generate a clock signal that inverts its value every five time units
	always  #5 clock=~clock;
	
	//here we assign values to the inputs
	initial begin
		clock = 1'b0;
		reset = 1'b1;
		TA = 1'b1;
		TB = 1'b0;
		#100;
		
		reset = 1'b0;
		#30 TA = 1'b0;
		
		#200 TB = 1'b1;
		#100 TA = 1'b1;
		#100 TB = 1'b0;
	end

endmodule
