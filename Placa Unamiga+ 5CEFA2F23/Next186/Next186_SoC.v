
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================
// modif jepalza, para placa altera generica con "sombrilla" de antoniovillena
module Next186_SoC(

	input CLOCK_50,
	
//////////// I2C EEPROM, Accelerometer //////////
//	output I2C_SCLK,
//	inout  I2C_SDAT,
//	input G_SENSOR_CS_N,
//	input G_SENSOR_INT,

	//////////// SDRAM //////////
	output	[12:0]DRAM_ADDR,
	output	[1:0]DRAM_BA,
	output	DRAM_CAS_N,
	output	DRAM_CKE,
	output	DRAM_CLK,
	output	DRAM_CS_N,
	inout		[15:0]DRAM_DQ,
	output	[1:0]DRAM_DQM,
	output	DRAM_RAS_N,
	output	DRAM_WE_N,
	
	output [5:0]VGA_R,
	output [5:0]VGA_G,
	output [5:0]VGA_B,
	output VGA_VSYNC,
	output VGA_HSYNC,
	
//	output	[7:0]LED,
	output HLLED, // HALT? led en placa rojo
	output SDLED, // sactividad de la SD, naranja
	output SYLED, // actividad systema, azul
	
//	input BTN_EAST,
	input BTN_SOUTH, // boton RESET
//	input BTN_WEST,
//	input BTN_NORTH,

	inout PS2_CLKA,
	inout PS2_DATA,
	inout PS2_CLKB,
	inout PS2_DATB,
	
	output AUDIO_L,
	output AUDIO_R,
	
	output SD_nCS,
	input  SD_DO,
	output SD_CK,
	output SD_DI,
	
	input RX_EXT,
	output TX_EXT
//	inout [3:0]GPIO 
);

	wire CLK44100x256;
	assign DRAM_CKE = 1'b1;
	wire [3:0]IO;
	wire [7:0]LED; // separo los LED para quedarme solo son el "1"
 
   // para adpatar los colores VGA666 al mio, VGA565 (ya no, ahora es directo)
	reg [5:0]VGA_R6;
	reg [5:0]VGA_G6;
	reg [5:0]VGA_B6;
	
	wire SDR_CLK;
	wire clk_25;
	dd_buf sdrclk_buf
	(
		.datain_h(1'b1),
		.datain_l(1'b0),
		.outclock(SDR_CLK),
		.dataout(DRAM_CLK)
	);
	
	assign HLLED=1'b1; // LED ROJO: apagado
	assign SDLED=LED[1]; // LED NARANJA: actividad de la SD, a modo led HD
	assign SYLED=1'b0; // LED AZUL: apagado (es inverso)

	system sys_inst
	(
		.CLK_50MHZ(CLOCK_50),
		
		.VGA_R(VGA_R6),
		.VGA_G(VGA_G6),
		.VGA_B(VGA_B6),
		.VGA_HSYNC(VGA_HSYNC),
		.VGA_VSYNC(VGA_VSYNC),
		.frame_on(),
		
		.clk_25(clk_25),
		
		.sdr_CLK_out(SDR_CLK),
		.sdr_n_CS_WE_RAS_CAS({DRAM_CS_N, DRAM_WE_N, DRAM_RAS_N, DRAM_CAS_N}),
		.sdr_BA(DRAM_BA),
		.sdr_ADDR(DRAM_ADDR),
		.sdr_DATA(DRAM_DQ),
		.sdr_DQM({DRAM_DQM}),
		
		.LED(LED), 
		
		.BTN_RESET(~BTN_SOUTH), // boton de RESET en placa principal K3
		.BTN_NMI(1'b0), // ~BTN_WEST), // anulo NMI, no me hace falta
		
		.RS232_DCE_RXD(RX_EXT),
		.RS232_DCE_TXD(TX_EXT),
		.RS232_EXT_RXD(),
		.RS232_EXT_TXD(),
		
		.SD_n_CS(SD_nCS),
		.SD_DI(SD_DI),
		.SD_CK(SD_CK),
		.SD_DO(SD_DO),
		
		.AUD_L(AUDIO_L),
		.AUD_R(AUDIO_R),
		
	 	.PS2_CLK1(PS2_CLKA),
		.PS2_CLK2(PS2_CLKB),
		.PS2_DATA1(PS2_DATA),
		.PS2_DATA2(PS2_DATB),
		
		.RS232_HOST_RXD(),
		.RS232_HOST_TXD(),
		.RS232_HOST_RST(),
		
		.GPIO(), //{IO, GPIO}), // jepalza, anulados
		
		.I2C_SCL(),//I2C_SCLK), // JEPALZA, ANULADOS
		.I2C_SDA() //I2C_SDAT)
	);

		// jepalza, en la placa de antoniovillena renemos VGA666
		assign VGA_R = VGA_R6;//[5:1];
		assign VGA_G = VGA_G6; 
		assign VGA_B = VGA_B6;//[5:1];
	
endmodule

