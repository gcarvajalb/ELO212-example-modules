`timescale 1ns / 1ps

module detector_secuencia
(
	input clk,
	input reset,
	input entrada,
	output reg led1,
	output reg led2
);

	localparam E0 = 'b000;
	localparam E1 = 'b001;
	localparam E2 = 'b010;
	localparam E3 = 'b011;
	localparam E4 = 'b100;

	reg [2:0] estado_actual, estado_siguiente;

	/* Lógica para definir el estado siguiente */
	always @(*) begin
		case (estado_actual)
		E0:
			if (entrada == 1'b1)
				estado_siguiente = E1;
			else
				estado_siguiente = E0;
		E1:
			estado_siguiente = (entrada == 1'b1) ? E2 : E0;
		E2:
			estado_siguiente = (entrada == 1'b0) ? E3 : E2;
		E3:
			estado_siguiente = (entrada == 1'b0) ? E4 : E1;
		E4:
			estado_siguiente = (entrada == 1'b0) ? E0 : E1;
		default:
			estado_siguiente = E0;
		endcase
	end

	/* Lógica para definir las salidas asociadas a los estados */
	always @(*) begin
		led1 = 1'b0;
		led2 = 1'b0;
		case (estado_actual)
		E2:
			led1 = 1'b1;
		E4:
			led2 = 1'b1;
		endcase
	end

	/* Registrando el estado */
	always @(posedge clk) begin
		if (reset)
			estado_actual <= E0;
		else
			estado_actual <= estado_siguiente;
	end

endmodule
