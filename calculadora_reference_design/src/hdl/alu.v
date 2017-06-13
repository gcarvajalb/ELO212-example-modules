/*
 *
 */

`timescale 1ns / 1ps

module alu
#(
	parameter WIDTH = 16
)(
	input signed [WIDTH-1:0] in1,
	input signed [WIDTH-1:0] in2,
	input [2:0] op,

	output signed [WIDTH-1:0] out,
	output [3:0] flags
);

	localparam ALU_OP_ADD = 'b001;
	localparam ALU_OP_SUB = 'b010;
	localparam ALU_OP_MUL = 'b011;
	localparam ALU_OP_AND = 'b100;
	localparam ALU_OP_OR  = 'b101;

	/* Sign extension */
	reg signed [WIDTH:0] out_ext;
	wire [WIDTH:0] in1_ext, in2_ext;
	assign in1_ext = {in1[WIDTH-1], in1};
	assign in2_ext = {in2[WIDTH-1], in2};

	/* Flags */
	reg negative;
	reg zero;
	reg carry;
	reg overflow;

	always @(*) begin
		case (op)
		ALU_OP_ADD:
			out_ext = in1_ext + in2_ext;
		ALU_OP_SUB:
			out_ext = in1_ext - in2_ext;
		ALU_OP_MUL:
			out_ext = in1_ext * in2_ext;
		ALU_OP_AND:
			out_ext = in1_ext & in2_ext;
		ALU_OP_OR:
			out_ext = in1_ext | in2_ext;
		default:
			out_ext = 'd0;
		endcase
	end

	/* Overflow/underflow, carry and negative detection */
	always @(*) begin
		case (out_ext[WIDTH:WIDTH-1])
		'b00: begin
			carry = 1'b0;
			overflow = 1'b0;
			negative = 1'b0;
		end
		'b01: begin
			carry = 1'b0;
			overflow = 1'b1;
			negative = 1'b1;
		end
		'b10: begin
			carry = 1'b1;
			/* Technically this is an underflow,
			   but we make no distinction */
			overflow = 1'b1;
			negative = 1'b0;
		end
		'b11: begin
			carry = 1'b1;
			overflow = 1'b0;
			negative = 1'b1;
		end
		endcase
	end

	/* Zero value detection */
	always @(*) begin
		if (out_ext == 'd0)
			zero = 1'b1;
		else
			zero = 1'b0;
	end

	/* Outputs */
	assign out = out_ext[WIDTH-1:0];
	assign flags = {negative, zero, carry, overflow};

endmodule
