module TX_sequence 
(
	input clock,
	input reset,
	input PB,             //PushButton
	output reg send16,    // Si esta alto, se deben transmitir 16 bits (2 bytes)
	input busy,           // Si esta alto, la UART se encuentra transmitiendo un dato
	output [1:0] stateID  // Indica en que estado de la secuencia esta para mostrarlo en los LEDs
    );
    
    reg[1:0] next_state, state; 

    //state encoding
    localparam IDLE 		 = 2'd0;  // Esperando dato
    localparam TX_OPERAND01  = 2'd1;  // Transmitiendo el primer operando
    localparam TX_OPERAND02  = 2'd2;  // Transmitiendo el segundo operando
    localparam TX_ALU_CTRL 	 = 2'd3;  // Transmitiendo la senal de control para la operacion

    assign stateID = state;
    
    // combo logic of FSM
    always@(*) begin
        //default assignments
        next_state = state;
        send16 = 1'b1;
    	
    	case (state)
    		IDLE: 	begin
						if(PB & ~busy) begin
							next_state=TX_OPERAND01;
						end
					end

            TX_OPERAND01: begin
							if(PB & ~busy) begin
								next_state=TX_OPERAND02;
							end								
						end
						
            TX_OPERAND02: begin
							if(PB & ~busy) begin
								next_state=TX_ALU_CTRL;
							end								
						end

            TX_ALU_CTRL: begin
                            send16 = 1'b0;
                            if(~busy) begin
                                next_state=IDLE;
                            end
						end	
    	endcase
    end	

    //when clock ticks, update the state
    always@(posedge clock) begin
    	if(reset)
    		state <= IDLE;
    	else
    		state <= next_state;
	end
	
endmodule