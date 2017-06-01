`timescale 1ns / 1ps

module tb_detector_secuencia();

	reg clk;
	reg reset;
	reg entrada;

	wire led1;
	wire led2;

	detector_secuencia dut (
		.clk(clk),
		.reset(reset),
		.entrada(entrada),
		.led1(led1),
		.led2(led2)
	);

	initial begin
		clk = 0;
		reset = 1'b1;

		forever
			#5 clk = ~clk;
	end

	initial begin
		#10
		reset = 1'b0;
		entrada = 1'b0;
	end

	integer i;
	initial begin
		#12

		for (i = 0; i < 256; i = i + 1) begin
			entrada = $urandom % 2;
			#10;
		end
	end

endmodule