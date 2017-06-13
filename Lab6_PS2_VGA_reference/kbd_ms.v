`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:			UTFSM
// Engineer:		Mauricio Solis
// 
// Create Date:		09:01:45 29/04/2015 
// Design Name: 
// Module Name:		kbd_ms
// Project Name:	Experiencia 5
// Target Devices: 
// Tool versions: 
// Description:		Es un driver para el teclado y es capaz de 
//					indicar si llego un make code,break code, E0 make code
//					y E0 break code
//
// Dependencies:	ps2_read_ms
// Additional Comments: Cada vez que llega un paquete, se genera un pulso en kbs_tot
//                      en data_type se indica el tipo de dato recibido.
//                      y en new_data estará el dato.
//////////////////////////////////////////////////////////////////////////////////

`define MAKE_CODE		3'b001
`define MAKE_CODE_E0	3'b010
`define BRAKE_CODE		3'b011
`define BRAKE_CODE_E0	3'b100

`define KBD_STATE_INIT			4'b0001
`define KBD_STATE_F0			4'b0010		//F0 detected
`define KBD_STATE_F0_MAKE		4'b0011		//F0 and then code
`define KBD_STATE_E0			4'b0100		//E0 detected
`define KBD_STATE_E0_F0			4'b0101		//E0 and then F0 
`define KBD_STATE_E0_F0_MAKE	4'b0110		//E0_F0 and then code
`define KBD_STATE_E0_MAKE		4'b0111		//E0 and then code
`define KBD_STATE_MAKE			4'b1000		//make code
`define KBD_STATE_GEN_KBS		4'b1001		//To generate a kbs


module kbd_ms(clk,rst,kd,kc,new_data,data_type,kbs_tot,parity_error);
	input clk,rst,kd,kc;
	output reg[7:0] new_data;
	output reg[2:0]data_type;
	output reg kbs_tot;
	output parity_error;
	
	reg [3:0] kds_state_machine=`KBD_STATE_INIT;
	reg [3:0] kds_state_machine_next;
	
	wire [7:0]ps2_value;
	wire kbs;


	ps2_read_ms m_ps2read(clk, rst, kd, kc, kbs, ps2_value, parity_error);
	
	//maquina de estados para saber que dato esta llegando
	reg kbs_0=1'b0;
	wire kbs_pe;
	
	always@(posedge clk or posedge rst)
		if (rst)
			kbs_0 <= 1'b0;
		else
			kbs_0 <= kbs;

	assign kbs_pe = (kbs & ( ~kbs_0 ) );

	always@(*)
		if(kbs_pe)
			case(kds_state_machine)
				`KBD_STATE_INIT:		kds_state_machine_next=(ps2_value == 8'HF0)?`KBD_STATE_F0:
																(ps2_value == 8'HE0)?`KBD_STATE_E0:
																`KBD_STATE_MAKE;
																	
				`KBD_STATE_F0:			kds_state_machine_next = `KBD_STATE_F0_MAKE;
				
				`KBD_STATE_E0:			kds_state_machine_next = (ps2_value == 8'HF0)?`KBD_STATE_E0_F0:
																`KBD_STATE_E0_MAKE;
																	
				`KBD_STATE_E0_F0:		kds_state_machine_next=`KBD_STATE_E0_F0_MAKE;

				default:				kds_state_machine_next=kds_state_machine;
			endcase
		else
			case(kds_state_machine)
				`KBD_STATE_INIT,
				`KBD_STATE_F0,
				`KBD_STATE_E0,
				`KBD_STATE_E0_F0:		kds_state_machine_next=kds_state_machine;

				`KBD_STATE_F0_MAKE,
				`KBD_STATE_E0_F0_MAKE,
				`KBD_STATE_E0_MAKE,
				`KBD_STATE_MAKE:		kds_state_machine_next=`KBD_STATE_GEN_KBS;
				`KBD_STATE_GEN_KBS:		kds_state_machine_next=`KBD_STATE_INIT;
				default:				kds_state_machine_next=`KBD_STATE_INIT;
			endcase
	
	wire rst_state_machine;
	assign rst_state_machine = parity_error|rst;

	always@(posedge clk or posedge rst_state_machine)
		if(rst_state_machine)
			kds_state_machine <= `KBD_STATE_INIT;
		else
			kds_state_machine <= kds_state_machine_next;
	
	//describiendo las salidas new_data
	reg [7:0]new_data_next;

	always@(*)
		case(kds_state_machine)
			`KBD_STATE_F0_MAKE,`KBD_STATE_E0_F0_MAKE,`KBD_STATE_E0_MAKE,`KBD_STATE_MAKE:
				new_data_next = ps2_value;
			default: new_data_next = new_data;
		endcase
		
	always@(posedge clk or posedge rst)
		if(rst)
			new_data <= 8'd0;
		else
			new_data <= new_data_next;

	//describiendo la salida data_type;
	reg [2:0]data_type_next;

	always@(*)
		case(kds_state_machine)
			`KBD_STATE_F0_MAKE:		data_type_next = `BRAKE_CODE;
			`KBD_STATE_E0_F0_MAKE:	data_type_next = `BRAKE_CODE_E0;
			`KBD_STATE_E0_MAKE:		data_type_next = `MAKE_CODE_E0;
			`KBD_STATE_MAKE:		data_type_next = `MAKE_CODE;
			default:				data_type_next = data_type;
		endcase
	
	always@(posedge clk or posedge rst)
		if(rst)
			data_type <= 3'd0;
		else
			data_type <= data_type_next;
	
	//describiendo la salida kbs_tot;
	reg kbs_tot_next;

	always@(*)
		if(kds_state_machine == `KBD_STATE_GEN_KBS)
			kbs_tot_next = 1'b1;
		else
			kbs_tot_next = 1'b0;
			
	always@(posedge clk)
		kbs_tot <= kbs_tot_next;
		
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company:			UTFSM
// Engineer:		Mauricio Solis
// 
// Create Date:		08:20:34 29/04/2015 
// Design Name: 
// Module Name:		ps2_read_ms
// Project Name:	Experiencia 5
// Target Devices: 
// Tool versions: 
// Description:		Es un driver que permite recibir datos
//					desde un dispositivo cuyo protocolo de
//					comunicación es PS2
//
// Dependencies:	
// Additional Comments:
//Cada vez que se lee un dato correctamente, se genera un pulso
//en la señal "kbs", lo que permite saber cuando leer "data"
//////////////////////////////////////////////////////////////////////////////////

module ps2_read_ms(clk,rst,kd,kc,kbs,data,parity_error);
	input clk,rst,kd,kc;
	output kbs;
	output reg parity_error = 1'b0;
	output reg [7:0]data;
	reg [7:0] data_next;
	reg [10:2]shift;
	reg [10:2]shift_next;
	reg [3:0] data_in_counter = 4'd0;
	reg [3:0] data_in_counter_next;
	
	reg [1:0]kd_s = 2'b00;
	reg [1:0]kc_s = 2'b00;
	reg reset_data_in_counter;
	reg new_data_available = 1'b0;
	reg new_data_available_next;
	
	wire kc_ne;
	assign kbs=new_data_available;

	//sincronizando la entrada con el reloj de la FPGA
	always@(posedge clk)
		if(rst)
			{kd_s,kc_s} <= 4'b0;
		else
		begin
			kd_s <= {kd_s[0], kd};
			kc_s <= {kc_s[0], kc};
		end
		
	// Canto de bajada de la senal de keyboard clock
	assign kc_ne = (~kc_s[0]) & (kc_s[1]);
	
	//asignacion del registro de desplazamiento
	always@(*)
		case ({rst,kc_ne})
			2'b00:shift_next = shift;
			2'b01:shift_next = {kd_s[1], shift[10:3]};
			default:shift_next = 11'd0;
		endcase

	always@(posedge clk)
		shift <= shift_next;
	
	always @(*)
		if(data_in_counter == 4'd11)//llego el stop y es necesario resetar la cuenta
			reset_data_in_counter = 1'b1;
		else
			reset_data_in_counter=rst;

	//contador de los bits de entrada
	//por el carater sincronico del rst, la cuenta en 11 durar un ciclo de reloj
	always@(*)
		case({reset_data_in_counter,kc_ne})
			2'b00: data_in_counter_next = data_in_counter;
			2'b01: data_in_counter_next = data_in_counter + 4'd1;
			default:data_in_counter_next = 4'd0;
		endcase
		
	always@(posedge clk)
		data_in_counter <= data_in_counter_next;
			
	//aviso de new data disponible
	reg parity_error_next;
	always@(*)
		if((data_in_counter == 4'd10) && (!parity_error_next))//estamos en la paridad a la espera del stop
			new_data_available_next = 1'b1;
		else
			new_data_available_next = 1'b0;
	
	always@(posedge clk)
		new_data_available <= new_data_available_next;
	
	//la data
	always@(*)
		if(data_in_counter == 4'd9)//tengo el dato nuevo completo
			data_next = shift[10:3];
		else
			data_next = data;
	
	always@(posedge clk)
		data <= data_next;

	//checkeando paridad
	
	wire parity_local;

	assign parity_local = (^shift[10:2]);//calculando la paridad (odd)
	
	always@(*)
		if(data_in_counter == 4'd10)//acaba de llegar la paridad (ya esta almacenada)
			if(parity_local == 1'b1)
				parity_error_next = 1'b0;
			else
				parity_error_next = 1'b1;
		else
			parity_error_next = parity_error;
	
	always@(posedge clk or posedge rst)
		if(rst)
			parity_error <= 1'b0;
		else
			parity_error<=parity_error_next;
	
endmodule


