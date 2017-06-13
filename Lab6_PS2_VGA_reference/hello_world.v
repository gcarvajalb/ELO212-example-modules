`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:			USM
// Engineer:		Mauricio Solis
// 
// Create Date:    11:26:20 05/25/2015 
// Design Name: 
// Module Name:    hello_world
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 	characters.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// Este modulo permite dibujar letras en la pantalla.
// En particular este ejemplo dibuja:
// hola mundo
// elo212 ñam
//////////////////////////////////////////////////////////////////////////////////


/*
 * clk = pixel clock
 * rst = reset
 * hc_visible = contador pixeles horizontales del modulo driver_vga
 * vc_visible = contador pixeles verticales del modulo driver_vga
 * in_square = indica si esta en cuadro de texto
 * in_character = se pone en alto si hay que pintar el pixel
*/
module hello_world_text_square(
	input clk, 
	input rst, 
	input [10:0]hc_visible,
	input [10:0]vc_visible,
	output in_square,
	output reg in_character
	);
	
	
	localparam ancho_pixel = 			2'd3;			//ancho y alto de cada pixel que compone a un caracter.
	localparam MENU_X_LOCATION =		11'd70;
	localparam MENU_Y_LOCATION =		11'd50;
	localparam CHARACTER_WIDTH = 		8'd5;
	localparam CHARACTER_HEIGHT = 		8'd8;
	localparam MAX_CHARACTER_LINE = 	10;		//habran 10 caracteres por linea
	localparam MAX_NUMBER_LINES = 		2;		//numero de lineas
	localparam MENU_WIDTH = 			( CHARACTER_WIDTH + 8'd1 ) * MAX_CHARACTER_LINE * ancho_pixel;
	localparam MENU_HEIGHT =			(CHARACTER_HEIGHT) * MAX_NUMBER_LINES * ancho_pixel;
	localparam MENU_X_TOP = 			MENU_X_LOCATION + MENU_WIDTH;
	localparam MENU_Y_TOP = 			MENU_Y_LOCATION + MENU_HEIGHT;

	
	reg [5:0]menu_character_position_x;		//indica la posicion x del caracter dentro del cuadro
	reg [5:0]menu_character_position_y;		//indica la posicion y del caracter dentro del cuadro
	reg [5:0]menu_character_position_x_next;
	reg [5:0]menu_character_position_y_next;
	
	reg [7:0]push_menu_minimat_x;			//se incremente a incrementos de ancho de caracter
	reg [7:0]push_menu_minimat_y;			//se incremente a incrementos de largo de caracter
	reg [7:0]push_menu_minimat_x_next;
	reg [7:0]push_menu_minimat_y_next;
	
	reg [2:0]pixel_x_to_show;				//indica la coordenada x del pixel que se debe dibujar
	reg [2:0]pixel_y_to_show;				//indica la coordenada y del pixel que se debe dibujar
	reg [2:0]pixel_x_to_show_next;
	reg [2:0]pixel_y_to_show_next;
	
	wire [10:0]hc_visible_menu;				//para fijar la posicion x en la que aparecera el cuadro de texto
	wire [10:0]vc_visible_menu;				//para fijar la posicion y en la que aparecera el cuadro de texto
	
	assign in_square=(hc_visible_menu>0)&&(vc_visible_menu>0);
	
	assign hc_visible_menu=( (hc_visible >= MENU_X_LOCATION) && (hc_visible <= MENU_X_TOP) )? hc_visible - MENU_X_LOCATION:11'd0;
	assign vc_visible_menu=( (vc_visible >= MENU_Y_LOCATION) && (vc_visible <= MENU_Y_TOP) )? vc_visible - MENU_Y_LOCATION:11'd0;
	
	reg [1:0]contador_pixels_horizontales;	//este registro cuenta de 0 a 2
	reg [1:0]contador_pixels_verticales;	//este registro cuenta de 0 a 2
	
	reg [1:0]contador_pixels_horizontales_next;
	reg [1:0]contador_pixels_verticales_next;
	//1 pixel por pixel de letra
	
	//contando cada 3 pixeles
	always@(*)
		if(in_square)
			if(contador_pixels_horizontales == (ancho_pixel - 2'd1))
				contador_pixels_horizontales_next = 2'd0;
			else
				contador_pixels_horizontales_next = contador_pixels_horizontales + 2'd1;
		else
			contador_pixels_horizontales_next = 2'd0;
			
	always@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_horizontales <= 2'd0;
		else
			contador_pixels_horizontales <= contador_pixels_horizontales_next;
//////////////////////////////////////////////////////////////////////////////			
	
//contando cada tres pixeles verticales
	always@(*)
		if(vc_visible_menu > 0)
			if(hc_visible_menu == MENU_WIDTH)
				if(contador_pixels_verticales == (ancho_pixel - 2'd1))
					contador_pixels_verticales_next = 2'd0;
				else
					contador_pixels_verticales_next = contador_pixels_verticales + 2'd1;
			else
				contador_pixels_verticales_next = contador_pixels_verticales;
		else
			contador_pixels_verticales_next = 2'd0;
			
	always@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_verticales <= 2'd0;
		else
			contador_pixels_verticales <= contador_pixels_verticales_next;
/////////////////////////////////////////////////////////////////////////////
	
//Calculando en que caracter est?? el haz y qu?? pixel hay que dibujar
	wire pixel_limit_h = contador_pixels_horizontales == (ancho_pixel - 2'd1);//cuando se lleg?? al m??ximo.
	wire hor_limit_char = push_menu_minimat_x == ((CHARACTER_WIDTH + 8'd1) - 8'd1);//se debe agregar el espacio de separaci??n

	always@(*)
	begin
		case({in_square, pixel_limit_h, hor_limit_char})
			3'b111: push_menu_minimat_x_next = 8'd0;
			3'b110: push_menu_minimat_x_next = push_menu_minimat_x + 8'd1;
			3'b100, 3'b101: push_menu_minimat_x_next = push_menu_minimat_x;
			default: push_menu_minimat_x_next = 8'd0;
		endcase
	
		case({in_square,pixel_limit_h,hor_limit_char})
			3'b111: menu_character_position_x_next = menu_character_position_x + 6'd1;
			3'b110: menu_character_position_x_next = menu_character_position_x;
			3'b100,3'b101: menu_character_position_x_next = menu_character_position_x;
			default:menu_character_position_x_next = 6'd0;
		endcase
		
		case({in_square,pixel_limit_h,hor_limit_char})
			3'b111:pixel_x_to_show_next = 3'd0;
			3'b110:pixel_x_to_show_next = pixel_x_to_show + 3'd1;
			3'b100,3'b101:pixel_x_to_show_next = pixel_x_to_show;
			default:pixel_x_to_show_next = 3'd0;
		endcase
	end
	
	always@(posedge clk)
	begin
		push_menu_minimat_x <= push_menu_minimat_x_next;
		menu_character_position_x <= menu_character_position_x_next;
		pixel_x_to_show <= pixel_x_to_show_next;
	end

	wire pixel_limit_v = (contador_pixels_verticales == (ancho_pixel - 2'd1) && (hc_visible_menu == MENU_WIDTH)); //cuando se llega al maximo.
	//wire pixel_limit_v = (contador_pixels_verticales == (ancho_pixel - 2'd1) && (hc_visible == 32'd0));//cuando se llega al maximo.
	wire ver_limit_char = push_menu_minimat_y == (CHARACTER_HEIGHT - 8'd1);
	always @(*)
	begin
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:push_menu_minimat_y_next = 8'd0;
			3'b110:push_menu_minimat_y_next = push_menu_minimat_y + 8'd1;
			3'b100,3'b101:push_menu_minimat_y_next = push_menu_minimat_y;
			default:push_menu_minimat_y_next = 8'd0;
		endcase
		
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:menu_character_position_y_next = menu_character_position_y + 6'd1;
			3'b110:menu_character_position_y_next = menu_character_position_y;
			3'b100,3'b101:menu_character_position_y_next = menu_character_position_y;
			default:menu_character_position_y_next = 6'd0;
		endcase
		
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:pixel_y_to_show_next = 3'd0;
			3'b110:pixel_y_to_show_next = pixel_y_to_show + 3'd1;
			3'b100,3'b101:pixel_y_to_show_next = pixel_y_to_show;
			default:pixel_y_to_show_next = 3'd0;
		endcase
	end
	
	always@(posedge clk)
	begin
		push_menu_minimat_y <= push_menu_minimat_y_next;
		menu_character_position_y <= menu_character_position_y_next;
		pixel_y_to_show <= pixel_y_to_show_next;
	end

	wire [4:0]character_to_show[0:7];
	wire [39:0]char_vect_to_show;
	
	wire [8 * MAX_CHARACTER_LINE - 1:0] textos[0:MAX_NUMBER_LINES - 1'd1];
	
	assign textos[0]="hola mundo";
	assign textos[1]={"elo212 ", 8'd164, "am"};
	wire [8 * MAX_CHARACTER_LINE - 1:0] tex_row_tmp;
	
	wire [7:0]select;
	assign tex_row_tmp = textos[menu_character_position_y] >> (8 * (MAX_CHARACTER_LINE - 1'd1 -menu_character_position_x) );
	assign select = tex_row_tmp[7:0];
	
	characters m_ch(select, char_vect_to_show);
	
	assign { character_to_show[7], character_to_show[6], character_to_show[5], character_to_show[4],
			character_to_show[3], character_to_show[2], character_to_show[1], character_to_show[0] } = 
			char_vect_to_show;
	
	wire [5:0]pixel_row;	//agregamos un cero para que se espaceen las letras
	assign pixel_row = {1'b0, character_to_show[pixel_y_to_show]};

	always@(*)
		if(in_square)
			in_character = ( pixel_row[pixel_x_to_show] );
		else
			in_character = 1'd0;
endmodule

/**
 * clk = pixel clock
 * rst = reset
 * hc_visible = contador pixeles horizontales
 * vc_visible = contador pixeles verticales del modulo driver_vga
 * in_square = indica si esta en cuadro de texto
 * in_character = se pone en alto si hay que pintar el pixel
**/

module show_one_char(
	input clk, 
	input rst, 
	input [10:0]hc_visible,
	input [10:0]vc_visible,
	input [7:0] the_char,
	output in_square,
	output reg in_character
	);
	
	localparam n = 						3;				//numero de bits necesario para contar los pixeles definidos por ancho_pixel
	localparam ancho_pixel = 			'd7;			//ancho y alto de cada pixel que compone a un caracter.
	parameter MENU_X_LOCATION =		11'd70;
	parameter MENU_Y_LOCATION =		11'd150;
	localparam CHARACTER_WIDTH = 		8'd5;
	localparam CHARACTER_HEIGHT = 		8'd8;
	localparam MAX_CHARACTER_LINE = 	1;		//habran 1 caracteres por linea
	localparam MAX_NUMBER_LINES = 		1;		//numero de lineas
	localparam MENU_WIDTH = 			( CHARACTER_WIDTH + 8'd1 ) * MAX_CHARACTER_LINE * ancho_pixel;
	localparam MENU_HEIGHT =			(CHARACTER_HEIGHT) * MAX_NUMBER_LINES * ancho_pixel;
	localparam MENU_X_TOP = 			MENU_X_LOCATION + MENU_WIDTH;
	localparam MENU_Y_TOP = 			MENU_Y_LOCATION + MENU_HEIGHT;

	
	reg [5:0]menu_character_position_x;		//indica la posicion x del caracter dentro del cuadro
	reg [5:0]menu_character_position_y;		//indica la posicion y del caracter dentro del cuadro
	reg [5:0]menu_character_position_x_next;
	reg [5:0]menu_character_position_y_next;
	
	reg [7:0]push_menu_minimat_x;			//se incremente a incrementos de ancho de caracter
	reg [7:0]push_menu_minimat_y;			//se incremente a incrementos de largo de caracter
	reg [7:0]push_menu_minimat_x_next;
	reg [7:0]push_menu_minimat_y_next;
	
	
	reg [2:0]pixel_x_to_show;				//indica la coordenada x del pixel que se debe dibujar
	reg [2:0]pixel_y_to_show;				//indica la coordenada y del pixel que se debe dibujar
	reg [2:0]pixel_x_to_show_next;
	reg [2:0]pixel_y_to_show_next;
	
	wire [10:0]hc_visible_menu;				//para fijar la posicion x en la que aparecera el cuadro de texto
	wire [10:0]vc_visible_menu;				//para fijar la posicion y en la que aparecera el cuadro de texto
	
	assign in_square=(hc_visible_menu>0)&&(vc_visible_menu>0);
	
	assign hc_visible_menu=( (hc_visible >= MENU_X_LOCATION) && (hc_visible <= MENU_X_TOP) )? hc_visible - MENU_X_LOCATION:11'd0;
	assign vc_visible_menu=( (vc_visible >= MENU_Y_LOCATION) && (vc_visible <= MENU_Y_TOP) )? vc_visible - MENU_Y_LOCATION:11'd0;
	
	
	reg [n-1:0]contador_pixels_horizontales;	//este registro cuenta de 0 a 2
	reg [n-1:0]contador_pixels_verticales;	//este registro cuenta de 0 a 2
	
	reg [n-1:0]contador_pixels_horizontales_next;
	reg [n-1:0]contador_pixels_verticales_next;
	//1 pixel por pixel de letra
	
	//contando cada 3 pixeles
	always@(*)
		if(in_square)
			if(contador_pixels_horizontales == (ancho_pixel - 'd1))
				contador_pixels_horizontales_next = 2'd0;
			else
				contador_pixels_horizontales_next = contador_pixels_horizontales + 'd1;
		else
			contador_pixels_horizontales_next = 'd0;
			
	always@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_horizontales <= 'd0;
		else
			contador_pixels_horizontales <= contador_pixels_horizontales_next;
//////////////////////////////////////////////////////////////////////////////			
	
//contando cada tres pixeles verticales
	always@(*)
		if(vc_visible_menu > 0)
			if(hc_visible_menu == MENU_WIDTH)
				if(contador_pixels_verticales == (ancho_pixel - 'd1))
					contador_pixels_verticales_next = 'd0;
				else
					contador_pixels_verticales_next = contador_pixels_verticales + 'd1;
			else
				contador_pixels_verticales_next = contador_pixels_verticales;
		else
			contador_pixels_verticales_next = 'd0;
			
	always@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_verticales <= 'd0;
		else
			contador_pixels_verticales <= contador_pixels_verticales_next;
/////////////////////////////////////////////////////////////////////////////
	
//Calculando en que caracter est?? el haz y qu?? pixel hay que dibujar
	wire pixel_limit_h = contador_pixels_horizontales == (ancho_pixel - 'd1);//cuando se lleg?? al m??ximo.
	wire hor_limit_char = push_menu_minimat_x == ((CHARACTER_WIDTH + 8'd1) - 8'd1);//se debe agregar el espacio de separaci??n

	always@(*)
	begin
		case({in_square, pixel_limit_h, hor_limit_char})
			3'b111: push_menu_minimat_x_next = 8'd0;
			3'b110: push_menu_minimat_x_next = push_menu_minimat_x + 8'd1;
			3'b100, 3'b101: push_menu_minimat_x_next = push_menu_minimat_x;
			default: push_menu_minimat_x_next = 8'd0;
		endcase
	
		case({in_square,pixel_limit_h,hor_limit_char})
			3'b111: menu_character_position_x_next = menu_character_position_x + 6'd1;
			3'b110: menu_character_position_x_next = menu_character_position_x;
			3'b100,3'b101: menu_character_position_x_next = menu_character_position_x;
			default:menu_character_position_x_next = 6'd0;
		endcase
		
		case({in_square,pixel_limit_h,hor_limit_char})
			3'b111:pixel_x_to_show_next = 3'd0;
			3'b110:pixel_x_to_show_next = pixel_x_to_show + 3'd1;
			3'b100,3'b101:pixel_x_to_show_next = pixel_x_to_show;
			default:pixel_x_to_show_next = 3'd0;
		endcase
	end
	
	always@(posedge clk)
	begin
		push_menu_minimat_x <= push_menu_minimat_x_next;
		menu_character_position_x <= menu_character_position_x_next;
		pixel_x_to_show <= pixel_x_to_show_next;
	end

	wire pixel_limit_v = (contador_pixels_verticales == (ancho_pixel - 'd1) && (hc_visible_menu == MENU_WIDTH)); //cuando se llega al maximo.
	//wire pixel_limit_v = (contador_pixels_verticales == (ancho_pixel - 2'd1) && (hc_visible == 32'd0));//cuando se llega al maximo.
	wire ver_limit_char = push_menu_minimat_y == (CHARACTER_HEIGHT - 8'd1);
	always @(*)
	begin
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:push_menu_minimat_y_next = 8'd0;
			3'b110:push_menu_minimat_y_next = push_menu_minimat_y + 8'd1;
			3'b100,3'b101:push_menu_minimat_y_next = push_menu_minimat_y;
			default:push_menu_minimat_y_next = 8'd0;
		endcase
		
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:menu_character_position_y_next = menu_character_position_y + 6'd1;
			3'b110:menu_character_position_y_next = menu_character_position_y;
			3'b100,3'b101:menu_character_position_y_next = menu_character_position_y;
			default:menu_character_position_y_next = 6'd0;
		endcase
		
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:pixel_y_to_show_next = 3'd0;
			3'b110:pixel_y_to_show_next = pixel_y_to_show + 3'd1;
			3'b100,3'b101:pixel_y_to_show_next = pixel_y_to_show;
			default:pixel_y_to_show_next = 3'd0;
		endcase
	end
	
	always@(posedge clk)
	begin
		push_menu_minimat_y <= push_menu_minimat_y_next;
		menu_character_position_y <= menu_character_position_y_next;
		pixel_y_to_show <= pixel_y_to_show_next;
	end

	wire [4:0]character_to_show[0:7];
	wire [39:0]char_vect_to_show;
	
	wire [8 * MAX_CHARACTER_LINE - 1:0] tex_row_tmp;
	
	wire [7:0]select;
	assign tex_row_tmp = the_char;
	assign select = tex_row_tmp[7:0];
	
	characters m_ch(select, char_vect_to_show);
	
	assign { character_to_show[7], character_to_show[6], character_to_show[5], character_to_show[4],
			character_to_show[3], character_to_show[2], character_to_show[1], character_to_show[0] } = 
			char_vect_to_show;
	
	wire [5:0]pixel_row;	//agregamos un cero para que se espaceen las letras
	assign pixel_row = {1'b0, character_to_show[pixel_y_to_show]};

	always@(*)
		if(in_square)
			in_character = ( pixel_row[pixel_x_to_show] );
		else
			in_character = 1'd0;
endmodule



/**
 * clk = pixel clock
 * rst = reset
 * hc_visible = contador pixeles horizontales
 * vc_visible = contador pixeles verticales del modulo driver_vga
 * in_square = indica si esta en cuadro de texto
 * in_character = se pone en alto si hay que pintar el pixel
**/
module show_one_line(
	input clk, 
	input rst, 
	input [10:0]hc_visible,
	input [10:0]vc_visible,
	input [8 * MAX_CHARACTER_LINE - 1 : 0] the_line,
	output in_square,
	output reg in_character
	);
	
	localparam ancho_pixel = 			3'd7;			//ancho y alto de cada pixel que compone a un caracter.
	parameter MENU_X_LOCATION =			11'd280;
	parameter MENU_Y_LOCATION =			11'd50;
	localparam CHARACTER_WIDTH = 		8'd5;
	localparam CHARACTER_HEIGHT = 		8'd8;
	localparam MAX_CHARACTER_LINE = 	10;		//habran 10 caracteres por linea
	localparam MAX_NUMBER_LINES = 		1;		//numero de lineas
	localparam MENU_WIDTH = 			( CHARACTER_WIDTH + 8'd1 ) * MAX_CHARACTER_LINE * ancho_pixel;
	localparam MENU_HEIGHT =			(CHARACTER_HEIGHT) * MAX_NUMBER_LINES * ancho_pixel;
	localparam MENU_X_TOP = 			MENU_X_LOCATION + MENU_WIDTH;
	localparam MENU_Y_TOP = 			MENU_Y_LOCATION + MENU_HEIGHT;

	
	reg [5:0]menu_character_position_x;		//indica la posicion x del caracter dentro del cuadro
	reg [5:0]menu_character_position_y;		//indica la posicion y del caracter dentro del cuadro
	reg [5:0]menu_character_position_x_next;
	reg [5:0]menu_character_position_y_next;
	
	reg [7:0]push_menu_minimat_x;			//se incremente a incrementos de ancho de caracter
	reg [7:0]push_menu_minimat_y;			//se incremente a incrementos de largo de caracter
	reg [7:0]push_menu_minimat_x_next;
	reg [7:0]push_menu_minimat_y_next;
	
	reg [2:0]pixel_x_to_show;				//indica la coordenada x del pixel que se debe dibujar
	reg [2:0]pixel_y_to_show;				//indica la coordenada y del pixel que se debe dibujar
	reg [2:0]pixel_x_to_show_next;
	reg [2:0]pixel_y_to_show_next;
	
	wire [10:0]hc_visible_menu;				//para fijar la posicion x en la que aparecera el cuadro de texto
	wire [10:0]vc_visible_menu;				//para fijar la posicion y en la que aparecera el cuadro de texto
	
	assign in_square = (hc_visible_menu > 0) && (vc_visible_menu > 0);
	
	assign hc_visible_menu=( (hc_visible >= MENU_X_LOCATION) && (hc_visible <= MENU_X_TOP) )? hc_visible - MENU_X_LOCATION:11'd0;
	assign vc_visible_menu=( (vc_visible >= MENU_Y_LOCATION) && (vc_visible <= MENU_Y_TOP) )? vc_visible - MENU_Y_LOCATION:11'd0;
	
	reg [2:0]contador_pixels_horizontales;	//este registro cuenta de 0 a 2
	reg [2:0]contador_pixels_verticales;	//este registro cuenta de 0 a 2
	
	reg [2:0]contador_pixels_horizontales_next;
	reg [2:0]contador_pixels_verticales_next;
	//1 pixel por pixel de letra
	
	//contando cada 3 pixeles
	always@(*)
		if(in_square)
			if(contador_pixels_horizontales == (ancho_pixel - 3'd1))
				contador_pixels_horizontales_next = 3'd0;
			else
				contador_pixels_horizontales_next = contador_pixels_horizontales + 3'd1;
		else
			contador_pixels_horizontales_next = 3'd0;
			
	always@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_horizontales <= 3'd0;
		else
			contador_pixels_horizontales <= contador_pixels_horizontales_next;
//////////////////////////////////////////////////////////////////////////////			
	
//contando cada tres pixeles verticales
	always@(*)
		if(vc_visible_menu > 0)
			if(hc_visible_menu == MENU_WIDTH)
				if(contador_pixels_verticales == (ancho_pixel - 3'd1))
					contador_pixels_verticales_next = 3'd0;
				else
					contador_pixels_verticales_next = contador_pixels_verticales + 3'd1;
			else
				contador_pixels_verticales_next = contador_pixels_verticales;
		else
			contador_pixels_verticales_next = 3'd0;
			
	always@(posedge clk or posedge rst)
		if(rst)
			contador_pixels_verticales <= 3'd0;
		else
			contador_pixels_verticales <= contador_pixels_verticales_next;
/////////////////////////////////////////////////////////////////////////////
	
//Calculando en que caracter esta el haz y que pixel hay que dibujar
	wire pixel_limit_h = contador_pixels_horizontales == (ancho_pixel - 3'd1);//cuando se llega al maximo.
	wire hor_limit_char = push_menu_minimat_x == ((CHARACTER_WIDTH + 8'd1) - 8'd1);//se debe agregar el espacio de separacion

	always@(*)
	begin
		case({in_square, pixel_limit_h, hor_limit_char})
			3'b111: push_menu_minimat_x_next = 8'd0;
			3'b110: push_menu_minimat_x_next = push_menu_minimat_x + 8'd1;
			3'b100, 3'b101: push_menu_minimat_x_next = push_menu_minimat_x;
			default: push_menu_minimat_x_next = 8'd0;
		endcase
	
		case({in_square,pixel_limit_h,hor_limit_char})
			3'b111: menu_character_position_x_next = menu_character_position_x + 6'd1;
			3'b110: menu_character_position_x_next = menu_character_position_x;
			3'b100,3'b101: menu_character_position_x_next = menu_character_position_x;
			default:menu_character_position_x_next = 6'd0;
		endcase
		
		case({in_square,pixel_limit_h,hor_limit_char})
			3'b111:pixel_x_to_show_next = 3'd0;
			3'b110:pixel_x_to_show_next = pixel_x_to_show + 3'd1;
			3'b100,3'b101:pixel_x_to_show_next = pixel_x_to_show;
			default:pixel_x_to_show_next = 3'd0;
		endcase
	end
	
	always@(posedge clk)
	begin
		push_menu_minimat_x <= push_menu_minimat_x_next;
		menu_character_position_x <= menu_character_position_x_next;
		pixel_x_to_show <= pixel_x_to_show_next;
	end

	wire pixel_limit_v = (contador_pixels_verticales == (ancho_pixel - 3'd1) && (hc_visible_menu == MENU_WIDTH)); //cuando se llega al maximo.
	wire ver_limit_char = push_menu_minimat_y == (CHARACTER_HEIGHT - 8'd1);
	always @(*)
	begin
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:push_menu_minimat_y_next = 8'd0;
			3'b110:push_menu_minimat_y_next = push_menu_minimat_y + 8'd1;
			3'b100,3'b101:push_menu_minimat_y_next = push_menu_minimat_y;
			default:push_menu_minimat_y_next = 8'd0;
		endcase
		
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:menu_character_position_y_next = menu_character_position_y + 6'd1;
			3'b110:menu_character_position_y_next = menu_character_position_y;
			3'b100,3'b101:menu_character_position_y_next = menu_character_position_y;
			default:menu_character_position_y_next = 6'd0;
		endcase
		
		case({vc_visible_menu > 0, pixel_limit_v, ver_limit_char})
			3'b111:pixel_y_to_show_next = 3'd0;
			3'b110:pixel_y_to_show_next = pixel_y_to_show + 3'd1;
			3'b100,3'b101:pixel_y_to_show_next = pixel_y_to_show;
			default:pixel_y_to_show_next = 3'd0;
		endcase
	end
	
	always@(posedge clk)
	begin
		push_menu_minimat_y <= push_menu_minimat_y_next;
		menu_character_position_y <= menu_character_position_y_next;
		pixel_y_to_show <= pixel_y_to_show_next;
	end

	wire [4:0]character_to_show[0:7];
	wire [39:0]char_vect_to_show;
	
	wire [8 * MAX_CHARACTER_LINE - 1:0] textos[0:MAX_NUMBER_LINES - 1'd1];
	
	wire [8 * MAX_CHARACTER_LINE - 1:0] tex_row_tmp;
	
	wire [7:0]select;
	assign tex_row_tmp = the_line >> (8 * (MAX_CHARACTER_LINE - 1'd1 -menu_character_position_x) );
	assign select = tex_row_tmp[7:0];
	
	characters m_ch(select, char_vect_to_show);
	
	assign { character_to_show[7], character_to_show[6], character_to_show[5], character_to_show[4],
			character_to_show[3], character_to_show[2], character_to_show[1], character_to_show[0] } = 
			char_vect_to_show;
	
	wire [5:0]pixel_row;	//agregamos un cero para que se espaceen las letras
	assign pixel_row = {1'b0, character_to_show[pixel_y_to_show]};

	always@(*)
		if(in_square)
			in_character = ( pixel_row[pixel_x_to_show] );
		else
			in_character = 1'd0;
endmodule


