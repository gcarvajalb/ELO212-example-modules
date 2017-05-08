////////////// Modulo clock_divider

//Este modulo se basa en el siguiente ejemplo: 
//https://reference.digilentinc.com/learn/programmable-logic/tutorials/counter-and-clock-divider/start

/*
Modulo de ejemplo para generar un reloj lento (clk_out) a partir de un reloj mas rapido (clk_in).
La idea es generar una senal (clk_out) que invierte su valor cada cierto numero de 
pulsos de clk_in (especificados en el parametro CONSTANT del modulo).
Como resultado, clk_out se mantendra en alto durante CONSTANT pulsos de clk_in, y luego se mantendra
en bajo durante otros CONSTANT pulsos de clk_in. El periodo de clk_out sera entonces 2*CONSTANT ciclos
de clk_in. 
La frecuencia en Hz. de clk_out sera [(frecuencia de clk_in)/(2*CONSTANT)] .
*/

// Notar el uso de parametros en la definicion del modulo. Los parametros permiten setear ciertas propiedades
// del modulo al momento de instanciarlos desde el archivo padre.
// El valor asignado durante la declaracion corresponde al valor por defecto. Si al instanciar el modulo no
// se indica el parametro, este toma el valor por defecto. De otra forma tomara el valor indicado cuando
// se instancie.
// Buscar el uso de parameter y localparam para Verilog-2001.

// Para un reloj de entrada de 100MHz, el parametro por defecto generara un reloj de salida de 1MHz.
module clock_divider 
(   input clk_in,
    input rst,
    input [31:0] div_constant,
    output reg clk_out
    );
    
   
   // Este reg debe ser de tamano suficiente para poder contar hasta el numero especificado
   // en div_constant. Puede ser de 16, 32, 64, o cualquier numero de bits, de acuerdo a los valores
   // que se espera pueda tener div_constant.
   reg [31:0] count;
    
  //Este bloque procedural solo incrementa un contador por cada pulso del reloj de entrada.
  // La cuenta llega hasta CONSTANT-1, y luego se reinicia.
  // Notar tambien que se usa una senal de reset, que permite setear el contador a un valor conocido
  // en cualquier momento. La logica que gatilla el reset puede ser un simple boton o alguna condicion
  // preprogramada. Siempre que se describa logica secuencial deberia incluirse por defecto una logica de reset.
   always @ (posedge(clk_in) or posedge(rst))
   begin
       if (rst == 1'b1)
           count <= 32'd0;
       else if (count == (div_constant - 32'd1))
           count <= 32'd0;
       else
           count <= count + 32'b1;
   end

// Este bloque procedural utiliza el valor de count para decidir cuando invertir el valor del 
// reloj de salida.
   
   always @ (posedge(clk_in) or posedge(rst))
   begin
       if (rst == 1'b1)
           clk_out <= 1'b0;
       else if (count == (div_constant - 32'd1))  //cuando el contador haya alcanzado el valor de referencia
           clk_out <= ~clk_out;                     // se invierte su valor. Notar que esto ocurre solo durante un 
       else                                         // ciclo del reloj de entrada, y este valor se mantiene constante 
           clk_out <= clk_out;                      // hasta que el contador nuevamente llegue a CONSTANT.
   end 
    
endmodule