//TOP MODULE

module top_module(
    output reg CA, CB, CC, CD, CE, CF, CG, DP, 
    output reg [7:0] AN,
    input [15:0] SW,
    input BTNC,
    input CLK100MHZ
    );
   
    // Buscar como asignar valores a los parametros de un modulo cuando este se instancia en Verilog-2001.
    // Como ejercicio, cambie el parametro CONSTANT a 5_000_000, implemente, y vea el efecto en su display.
    // Pruebe luego con 500_000 y vea el efecto.
    clock_divider clock_divider_inst (
      .clk_in (CLK100MHZ), 
      .rst (BTNC), 
      .div_constant (32'd50_000),//(DIV_CONSTANT),
      .clk_out (clk_div)
       ); 
   
    reg [2:0] counter;
    reg [31:0] DIV_CONSTANT;

    always @(posedge clk_div) begin
                counter <= counter+3'b1;
    end
    
    // El siguiente bloque procedural activa uno de los 7 segmentos de acuerdo al valor del contador.
    // El display 0 se activara cuando el contador este en 0, el display 1 cuando el contador este en 1,
    // y asi sucesivamente.
    // Notar que counter tiene solo 2 bits, y el case incluye el default aun cuando las condiciones explicitamente
    // cubren todas las combinaciones posibles. Las sentencias case SIEMPRE DEBEN LLEVAR UN DEFAULT, INCLUSO
    // CUANDO SE CREE QUE LAS CONDICIONES DE ENTRADA NO DECLARADAS EXPLICITAMENTE NO OCURRIRAN.
    always @(*) begin
        case (counter) 
            3'd7 : AN[7:0] = 8'b11111110;
            3'd6 : AN[7:0] = 8'b11111101;
            3'd5 : AN[7:0] = 8'b11111011;
            3'd4 : AN[7:0] = 8'b11110111;
            3'd3 : AN[7:0] = 8'b11101111;
            3'd2 : AN[7:0] = 8'b11011111;
            3'd1 : AN[7:0] = 8'b10111111;
            3'd0 : AN[7:0] = 8'b01111111;
            default : AN[7:0] = 8'b11111111;
        endcase
    end

    gonzalo gonzalo_inst (
         .D (counter), 
         .SEG ({CA_G, CB_G, CC_G, CD_G, CE_G, CF_G, CG_G, DP_G}) // concatenation
          );

    elo211 elo211_inst (
         .D (counter), 
         .SEG ({CA_E, CB_E, CC_E, CD_E, CE_E, CF_E, CG_E, DP_E}) // concatenation
          );
          
    alejandro alejandro_inst (
               .D (counter), 
               .SEG ({CA_A, CB_A, CC_A, CD_A, CE_A, CF_A, CG_A, DP_A}) // concatenation
                );

    mauricio mauricio_inst (
               .D (counter), 
               .SEG ({CA_M, CB_M, CC_M, CD_M, CE_M, CF_M, CG_M, DP_M}) // concatenation
                );


always @(*) begin                                  
    case (SW[1:0])                                 
        2'd0 : {CA, CB, CC, CD, CE, CF, CG, DP} = {CA_M, CB_M, CC_M, CD_M, CE_M, CF_M, CG_M, DP_M};      
        2'd1 : {CA, CB, CC, CD, CE, CF, CG, DP} = {CA_G, CB_G, CC_G, CD_G, CE_G, CF_G, CG_G, DP_G};      
        2'd2 : {CA, CB, CC, CD, CE, CF, CG, DP} = {CA_A, CB_A, CC_A, CD_A, CE_A, CF_A, CG_A, DP_A};         
        2'd3 : {CA, CB, CC, CD, CE, CF, CG, DP} = {CA_E, CB_E, CC_E, CD_E, CE_E, CF_E, CG_E, DP_E};          
        default : {CA, CB, CC, CD, CE, CF, CG, DP} = {CA_M, CB_M, CC_M, CD_M, CE_M, CF_M, CG_M, DP_M};   
    endcase                                        
end                                                
//    always @(*) begin
//        case (SW[1:0]) 
//            2'd0 : DIV_CONSTANT = 32'd50_000_000;
//            2'd1 : DIV_CONSTANT = 32'd10_000_000;
//            2'd2 : DIV_CONSTANT = 32'd500_000;
//            2'd3 : DIV_CONSTANT = 32'd50_000;
//            default : DIV_CONSTANT = 32'd50_000_000;
//        endcase
//    end

endmodule