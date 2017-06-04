module lab3bis_top
(
	input clk_100M,
	input reset_n,
	input [15:0] switches,
	input [4:0] button,
	output [7:0] ss_value,
	output [7:0] ss_select,
	output [2:0] led16,
	output [15:0] leds
);

	/*
	 * Estado de los botones en el siguiente orden, MSB a LSB:
	 *   Center, Up, Down, Left, Right
	 */
	wire [4:0] button_states;
	wire button_c_push; // Pulso asociado al boton central (Enter)

	/* Reloj externo de 100 MHz (es solo un renombre) */
	wire clk = clk_100M;

	/* Estados de la máquina */
	localparam S_IN1 = 'b0001;
	localparam S_IN2 = 'b0010;
	localparam S_OPE = 'b0100;
	localparam S_RES = 'b1000;
	reg [3:0] state, state_next = S_IN1;

	/* Reset cuando se presionan todos los botones (o el botón CPU_RESET) */
	wire fsm_reset = (button_states == 5'b11111) || (~reset_n);

	/* Operaciones de la ALU */
	localparam ALU_OP_ADD = 'b001;
	localparam ALU_OP_SUB = 'b010;
	localparam ALU_OP_MUL = 'b011;
	localparam ALU_OP_AND = 'b100;
	localparam ALU_OP_OR  = 'b101;
	reg [2:0] alu_op, alu_op_next;
	assign led16 = alu_op;

	/* Operandos de la ALU */
	reg [15:0] alu_in1, alu_in1_next;
	reg [15:0] alu_in2, alu_in2_next;
	assign leds = switches;

	/* Resultado de la ALU */
	wire [15:0] alu_out;
	wire [3:0] alu_flags;

	always @(*) begin
		alu_in1_next = alu_in1;
		alu_in2_next = alu_in2;
		state_next = state;

		case (state)
		S_IN1: begin
			alu_in1_next = switches;
			state_next = S_IN2;
		end
		S_IN2: begin
			alu_in2_next = switches;
			state_next = S_OPE;
		end
		S_OPE: state_next = S_RES;
		S_RES: state_next = S_IN1;
		default: state_next = S_IN1;
		endcase
	end

	always @(*) begin
		alu_op_next = alu_op;

		if (state == S_OPE) begin
			case (button_states)
			5'b00001: alu_op_next = ALU_OP_OR;
			5'b00010: alu_op_next = ALU_OP_AND;
			5'b00100: alu_op_next = ALU_OP_SUB;
			5'b01000: alu_op_next = ALU_OP_ADD;
			5'b00101: alu_op_next = ALU_OP_MUL; /* Down & Right */
			default: alu_op_next = alu_op;
			endcase
		end
	end

	/* Registar las entradas de la ALU */
	always @(posedge clk) begin
		if (fsm_reset) begin
			alu_in1 <= 'd0;
			alu_in2 <= 'd0;
			alu_op <= ALU_OP_OR;
		end else begin
			alu_in1 <= alu_in1_next;
			alu_in2 <= alu_in2_next;
			alu_op <= alu_op_next;
		end
	end

	/* Registrar el estado */
	always @(posedge clk) begin
		if (fsm_reset)
			state <= S_IN1;
		else if (button_c_push)
			state <= state_next;
		else
			state <= state;
	end

	/* Registrar las salidas de la ALU */
	reg [15:0] alu_out_reg;
	reg [3:0] alu_flags_reg;

	always @(posedge clk) begin
		if (state == S_RES) begin
			alu_out_reg <= alu_out;
			alu_flags_reg <= alu_flags;
		end else begin
			alu_out_reg <= alu_out_reg;
			alu_flags_reg <= alu_flags_reg;
		end
	end

	/* Divisor de reloj para display de 7 segmentos */
	wire clk_ss;
	clk_divider #(
		.O_CLK_FREQ(480)
	) clk_div_ss_display (
		.clk_in(clk),
		.reset(1'b0),
		.clk_out(clk_ss)
	);

	/*
	 * Double dabble y su "glue logic" para saber si se trata de
	 * un número negativo (en complemento a 2) y obtener su valor
	 * absoluto.
	 *
	 * http://www.pcmag.com/encyclopedia/term/43822/glue-logic
	 * https://es.wikipedia.org/wiki/L%C3%B3gica_de_pegamento
	 */
	wire [31:0] bcd;
	wire [15:0] s16_tmp =
		(state == S_RES) ? alu_out_reg :
		(state == S_IN1) ? alu_in1 : alu_in2;
	wire is_negative = s16_tmp[15];
	wire [15:0] abs_tmp =
		(is_negative) ? (~s16_tmp + 1) : s16_tmp;

	unsigned_to_bcd u32_to_bcd_inst (
		.clk(clk),
		.trigger(1'b1),
		.in({16'd0, abs_tmp}),
		.idle(),
		.bcd(bcd)
	);

	/* Multiplexor para display de 7 segmentos */
	display_mux display_mux_inst (
		.clk(clk_ss),
		.clk_enable(1'b1),
		.bcd(bcd),
		.dots({alu_flags_reg, state}),
		.is_negative(is_negative),
		.turn_off(1'b0),
		.ss_value(ss_value),
		.ss_select(ss_select)
	);

	/* Instanciación de la ALU */
	alu #(
		.WIDTH(16)
	) alu_inst (
		.in1(alu_in1),
		.in2(alu_in2),
		.op(alu_op),
		.out(alu_out),
		.flags(alu_flags)
	);

	/* Debouncers para cada botón */
	pb_debouncer_wrapper deb_btn_right (
		.clk(clk),
		.pb(button[0]),
		.pb_state(button_states[0]),
		.pb_down(),
		.pb_up()
	);

	pb_debouncer_wrapper deb_btn_left (
		.clk(clk),
		.pb(button[1]),
		.pb_state(button_states[1]),
		.pb_down(),
		.pb_up()
	);

	pb_debouncer_wrapper deb_btn_down (
		.clk(clk),
		.pb(button[2]),
		.pb_state(button_states[2]),
		.pb_down(),
		.pb_up()
	);

	pb_debouncer_wrapper deb_btn_up (
		.clk(clk),
		.pb(button[3]),
		.pb_state(button_states[3]),
		.pb_down(),
		.pb_up()
	);

	pb_debouncer_wrapper deb_btn_center (
		.clk(clk),
		.pb(button[4]),
		.pb_state(button_states[4]),
		.pb_down(button_c_push),
		.pb_up()
	);

endmodule
