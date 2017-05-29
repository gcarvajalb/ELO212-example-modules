`timescale 1ns / 1ps

module master_endpoint_top
(
	input          clk_100M,
	input          reset_n,

	input          uart_rx,
	output         uart_tx,
	output         uart_tx_busy,
	
	input          button_c,
	input [15:0]   switches,
	output [15:0]   leds
);
	/*
	 * Convertir la señal del botón reset_n a 'active HIGH'
	 * y sincronizar con el reloj.
	 */
	wire [7:0] tx_data; 
	//wire [7:0] rx_data; 
	
	reg [1:0] reset_sr;
	wire reset = reset_sr[1];
	always @(posedge clk_100M)
		reset_sr <= {reset_sr[0], ~reset_n};

    //assign uart_rx_usb = uart_rx;

    assign uart_rx = uart_rx;
    assign uart_tx = uart_tx;
    assign uart_tx_busy = tx_busy;

UART_tx_control_wrapper 
#(  .INTER_BYTE_DELAY (10000),
    .WAIT_FOR_REGISTER_DELAY (100)
    
    ) UART_control_inst (
	.clock(clk_100M),
    .reset(reset),
    .PB(button_c_posedge),
    .SW(switches),
    .tx_data(tx_data),
    .tx_start(tx_start),
    .stateID (leds[2:0])
    );


	/* Módulo UART a 115200/8 bits datos/No paridad/1 bit stop */
	uart_basic #(
		.CLK_FREQUENCY(100000000),
		.BAUD_RATE(115200)
	) uart_basic_inst (
		.clk(clk_100M),
		.reset(reset),
		.rx(uart_rx),
		.rx_data(leds[15:8]),
		.rx_ready(),
		.tx(uart_tx),
		.tx_start(tx_start),
		.tx_data(tx_data),
		.tx_busy(tx_busy)
	);

	/* Debouncer */
	pb_debouncer #(
		.COUNTER_WIDTH(16)
	) pb_deb0 (
		.clk(clk_100M),
		.rst(reset),
		.pb(button_c),
		.pb_state(),
		.pb_negedge(),
		.pb_posedge(button_c_posedge)
	);

endmodule
