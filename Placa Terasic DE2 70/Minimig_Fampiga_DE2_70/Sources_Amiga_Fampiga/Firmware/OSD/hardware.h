//#define MCLK 48000000
//#define FWS 1 // Flash wait states
//
//#define DISKLED    AT91C_PIO_PA10
//#define MMC_CLKEN  AT91C_PIO_PA24
//#define MMC_SEL    AT91C_PIO_PA27
//#define DIN AT91C_PIO_PA20
//#define CCLK AT91C_PIO_PA4
//#define PROG_B AT91C_PIO_PA9
//#define INIT_B AT91C_PIO_PA7
//#define DONE AT91C_PIO_PA8
//#define FPGA0 AT91C_PIO_PA26
//#define FPGA1 AT91C_PIO_PA25
//#define FPGA2 AT91C_PIO_PA15
//#define BUTTON AT91C_PIO_PA28

#define DISKLED_ON // *AT91C_PIOA_SODR = DISKLED;
#define DISKLED_OFF // *AT91C_PIOA_CODR = DISKLED;

#define EnableCard()  *(volatile unsigned short *)0xda4004=0x02
#define DisableCard() *(volatile unsigned short *)0xda4004=0x03
#define EnableFpga()  *(volatile unsigned short *)0xda4004=0x10
#define DisableFpga() *(volatile unsigned short *)0xda4004=0x11
#define EnableOsd()   *(volatile unsigned short *)0xda4004=0x20
#define DisableOsd()  *(volatile unsigned short *)0xda4004=0x21
#define EnableDMode() *(volatile unsigned short *)0xda4004=0x40
#define DisableDMode() *(volatile unsigned short *)0xda4004=0x41

#define SPI_slow()  *(volatile unsigned short *)0xda4008=0x20
#define SPI_fast()  *(volatile unsigned short *)0xda4008=0x01   //14MHz/2

#ifdef __GNUC__
// Yuk.  The following monstrosity does a dummy read from the timer register, writes, then reads from
// the SPI register.  Doing it this way works around a timing issue with ADF writing when GCC optimisation is turned on.
//#define SPI(x) (*(volatile unsigned short *)0xDEE010,*(volatile unsigned char *)0xda4000=x,*(volatile unsigned char *)0xda4000)

#define SPI(x) (*(volatile unsigned char *)0xda4000=x,*(volatile unsigned char *)0xda4000)

#define SPIN (*(volatile unsigned short *)0xDEE010)	// Waste a few cycles to let the FPGA catch up

// A 16-bit register for platform-specific config.
// On read:
//   Bits 3:0 -> memory size.  (1<<memsize gives the size in megabytes.)
//   Bit 4 -> Turbo chipram supported
//   Bit 5 -> Reconfig supportred 
//   Bit 6 -> Action Replay supported
//   Bit 14 -> Scandoubler selectable in software

// On write:
//   Bits 1:0 -> Zorro II Fast ram memory config:  00-> off, 01->2mb, 10->4mb, 11->8mb
//   Bit 14 -> Scandoubler enable
//   Bit 15 -> Turbo chipram enable/disable

#define PLATFORM (*(volatile unsigned short *)0xDEE014)
#define PLATFORM_TURBOCHIP 4
#define PLATFORM_RECONFIG 5
#define PLATFORM_ACTIONREPLAY 6
#define PLATFORM_MENUBUTTON 13
#define PLATFORM_SCANDOUBLER 14

#define PLATFORM_TURBOCHIP_ENABLE 15

// Write to this register to reconfigure the FPGA on devices which support such operations.
#define RECONFIGURE (*(volatile unsigned short *)0xDEE016)


// static inline unsigned char SPI(unsigned char o)
//{	
//	volatile unsigned char *ptr = (volatile unsigned char *)0xda4000;
//	*ptr = o;
//	return *ptr;
//}
#else
#define SPI  *(unsigned char *)0xda4000=
#define SPIN
#endif
	
#define RDSPI  *(volatile unsigned char *)0xda4001
#define RS232  *(volatile unsigned char *)0xda8001=
 

#define RAMFUNC  // Used by ARM

//void USART_Init(unsigned long baudrate);
//void USART_Write(unsigned char c);
//
//void SPI_Init(void);
//unsigned char SPI(unsigned char outByte);
//void SPI_Wait4XferEnd(void);
//void EnableCard(void);
//void DisableCard(void);
//void EnableFpga(void);
//void DisableFpga(void);
//void EnableOsd(void);
//void DisableOsd(void);
unsigned long CheckButton(void);
void Timer_Init(void);
unsigned long GetTimer(unsigned long offset);
unsigned long CheckTimer(unsigned long t);
void WaitTimer(unsigned long time);
void ConfigFastRAM(unsigned short memory);
void Reconfigure();


