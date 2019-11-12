
module MultiplesBCD(
	input [3:0] hex_digit,
	output reg [6:0] seg_0,
	output reg [6:0] seg_1,
	output reg [6:0] seg_2,
	output reg [6:0] seg_3,
	output reg [6:0] seg_4,
	output reg [6:0] seg_5,
	output reg [6:0] seg_6,
	output reg [6:0] seg_7,
	output reg [7:0] punto
	);

always @* begin
      punto = ~8'b00000000; //apagamos todos los puntos de los BCD 

		// seg = {6,5,4,3,2,1,0};
		// 0 es encendido y 1 es apagado
		// Creamos los valores de seg_0 y seg_1 de forma simultanea en una sentencia case
			case (hex_digit)
			4'b0000 :  begin seg_0 = ~7'b0111111; seg_1 = ~7'b0111111;	end	// Hexadecimal 0   // ---0----
			4'b0001 :  begin seg_0 = ~7'b0000110; seg_1 = ~7'b0000110;	end	// Hexadecimal 1   // |      |
			4'b0010 :  begin seg_0 = ~7'b1011011; seg_1 = ~7'b1011011;	end	// Hexadecimal 2   // 5      1
			4'b0011 :  begin seg_0 = ~7'b1001111; seg_1 = ~7'b1001111;	end	// Hexadecimal 3   // |      |
			4'b0100 :  begin seg_0 = ~7'b1100110; seg_1 = ~7'b1100110;	end	// Hexadecimal 4   // ---6----
			4'b0101 :  begin seg_0 = ~7'b1101101; seg_1 = ~7'b1101101;	end	// Hexadecimal 5   // |      |
			4'b0110 :  begin seg_0 = ~7'b1111101; seg_1 = ~7'b1111101;	end	// Hexadecimal 6   // 4      2
			4'b0111 :  begin seg_0 = ~7'b0000111; seg_1 = ~7'b0000111;	end	// Hexadecimal 7   // |      |
			4'b1000 :  begin seg_0 = ~7'b1111111; seg_1 = ~7'b1111111;	end	// Hexadecimal 8   // ---3----
			4'b1001 :  begin seg_0 = ~7'b1101111; seg_1 = ~7'b1101111;	end	// Hexadecimal 9
			4'b1010 :  begin seg_0 = ~7'b1110111; seg_1 = ~7'b1110111;	end	// Hexadecimal A
			4'b1011 :  begin seg_0 = ~7'b1111100; seg_1 = ~7'b1111100;	end	// Hexadecimal B
			4'b1100 :  begin seg_0 = ~7'b0111001; seg_1 = ~7'b0111001;	end	// Hexadecimal C
			4'b1101 :  begin seg_0 = ~7'b1011110; seg_1 = ~7'b1011110;	end	// Hexadecimal D
			4'b1110 :  begin seg_0 = ~7'b1111001; seg_1 = ~7'b1111001;	end	// Hexadecimal E
			4'b1111 :  begin seg_0 = ~7'b1110001; seg_1 = ~7'b1110001;	end	// Hexadecimal F
			endcase	  
	seg_2=seg_0; //igualamos las salidas del BCD2 hasta el BCD7 al BCD0
	seg_3=seg_0;
	seg_4=seg_0;
	seg_5=seg_0;
	seg_6=seg_0;
	seg_7=seg_0;
	
	
	
	
	
	end
	
	endmodule
	