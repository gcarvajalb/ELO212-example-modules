//TOP MODULE

module top_module(
    output CA, CB, CC, CD, CE, CF, CG, DP, 
    output reg [7:0] AN,
    input [15:0] SW,
    input BTNC,
    input CLK100MHZ,
    output JA1, JA2
    );
   
   assign JA1 = CLK100MHZ;
   assign JA2 = clk_div;
   
   reg [1:0] counter;
   reg [31:0] DIV_CONSTANT;
   
// El valor de 32 bits ingresado en la entrada div_constant determinara la frecuencia a la 
// que se itera sobre los displays de 7 segmentos. A un numero mas grande, mas lenta la frecuencia
// y mas lento se veran los displays. Puede cambiar esta frecuencia usando los SW[1:0] en la tarjeta.
// Al cambiar la posicion de los switches, presione BTNC (que actua como reset), para que la configuracion
// tenga efecto.
    clock_divider clock_divider_inst (
      .clk_in (CLK100MHZ), 
      .rst (BTNC), 
      .div_constant (DIV_CONSTANT),
      .clk_out (clk_div)
       ); 
   


    always @(posedge clk_div) begin
                counter <= counter+2'b1;
    end
    
    // El siguiente bloque procedural activa uno de los 7 segmentos de acuerdo al valor del contador.
    // El display 0 se activara cuando el contador este en 0, el display 1 cuando el contador este en 1,
    // y asi sucesivamente.
    // Notar que counter tiene solo 2 bits, y el case incluye el default aun cuando las condiciones explicitamente
    // cubren todas las combinaciones posibles. Las sentencias case SIEMPRE DEBEN LLEVAR UN DEFAULT, INCLUSO
    // CUANDO SE CREE QUE LAS CONDICIONES DE ENTRADA NO DECLARADAS EXPLICITAMENTE NO OCURRIRAN.
    always @(*) begin
        case (counter) 
            2'd0 : AN[3:0] = 4'b1110;
            2'd1 : AN[3:0] = 4'b1101;
            2'd2 : AN[3:0] = 4'b1011;
            2'd3 : AN[3:0] = 4'b0111;
            default : AN[3:0] = 4'b1111;
        endcase
    end

    decoder_7_seg decoder_7_seg_inst (
         .D (counter), 
         .SEG ({CA, CB, CC, CD, CE, CF, CG, DP}) // concatenation
          );

    always @(*) begin
        case (SW[1:0]) 
            2'd0 : DIV_CONSTANT = 32'd50_000_000;
            2'd1 : DIV_CONSTANT = 32'd10_000_000;
            2'd2 : DIV_CONSTANT = 32'd500_000;
            2'd3 : DIV_CONSTANT = 32'd50_000;
            default : DIV_CONSTANT = 32'd50_000_000;
        endcase
    end

endmodule