library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

library altera;
use altera.altera_syn_attributes.all;


entity C3BoardToplevel is
port(
		clk_50 	: in 	std_logic;
		reset_button : in std_logic;
		led_out : out 	std_logic;

		-- SDRAM - chip 1
		sd1_addr : out std_logic_vector(11 downto 0);
		sd1_data : inout std_logic_vector(7 downto 0);
		sd1_ba : out std_logic_vector(1 downto 0);
		sdram1_clk : out std_logic;
		sd1_cke : out std_logic;
		sd1_dqm : out std_logic;
		sd1_cs : out std_logic;
		sd1_we : out std_logic;
		sd1_cas : out std_logic;
		sd1_ras : out std_logic;

		-- SDRAM - chip 2
		sd2_addr : out std_logic_vector(11 downto 0);
		sd2_data : inout std_logic_vector(7 downto 0);
		sd2_ba : out std_logic_vector(1 downto 0);
		sdram2_clk : out std_logic;
		sd2_cke : out std_logic;
		sd2_dqm : out std_logic;
		sd2_cs : out std_logic;
		sd2_we : out std_logic;
		sd2_cas : out std_logic;
		sd2_ras : out std_logic;
		
		-- VGA
		vga_red 		: out std_logic_vector(5 downto 0);
		vga_green 	: out std_logic_vector(5 downto 0);
		vga_blue 	: out std_logic_vector(5 downto 0);
		
		vga_hsync 	: buffer std_logic;
		vga_vsync 	: buffer std_logic;
		
		vga_scandbl : in std_logic;

		-- PS/2
		ps2k_clk : inout std_logic;
		ps2k_dat : inout std_logic;
		ps2m_clk : inout std_logic;
		ps2m_dat : inout std_logic;
		
		-- Audio
		aud_l : out std_logic;
		aud_r : out std_logic;
		
		-- RS232
		rs232_rxd : in std_logic;
		rs232_txd : buffer std_logic;
		midi_txd : out std_logic;

		-- SD card interface
		sd_cs : out std_logic;
		sd_miso : in std_logic;
		sd_mosi : out std_logic;
		sd_clk : out std_logic;
		
		-- Power and LEDs
		power_button : in std_logic;
		power_hold : out std_logic := '1';
		leds : out std_logic_vector(3 downto 0);
		
		-- Joystick ports
		joy1 : in std_logic_vector(6 downto 0); -- Fire3, Fire2, Fire 1, Right, Left, Down, Up
		joy2 : in std_logic_vector(6 downto 0); -- Fire3, Fire2, Fire 1, Right, Left, Down, Up

		-- Any remaining IOs yet to be assigned
		misc_ios_1 : out std_logic_vector(5 downto 0);
		misc_ios_21 : out std_logic_vector(1 downto 0);
		misc_ios_22 : out std_logic_vector(8 downto 0)
	);
end entity;

architecture RTL of C3BoardToplevel is
-- Assigns pin location to ports on an entity.
-- Declare the attribute or import its declaration from 
-- altera.altera_syn_attributes
attribute chip_pin : string;

-- Board features

attribute chip_pin of clk_50 : signal is "152";
attribute chip_pin of reset_button : signal is "181";
attribute chip_pin of led_out : signal is "233";

-- SDRAM (2 distinct 8-bit wide chips)

attribute chip_pin of sd1_addr : signal is "83,69,82,81,80,78,99,110,63,64,65,68";
attribute chip_pin of sd1_data : signal is "109,103,111,93,100,106,107,108";
attribute chip_pin of sd1_ba : signal is "70,71";
attribute chip_pin of sdram1_clk : signal is "117";
attribute chip_pin of sd1_cke : signal is "84";
attribute chip_pin of sd1_dqm : signal is "87";
attribute chip_pin of sd1_cs : signal is "72";
attribute chip_pin of sd1_we : signal is "88";
attribute chip_pin of sd1_cas : signal is "76";
attribute chip_pin of sd1_ras : signal is "73";

attribute chip_pin of sd2_addr : signal is "142,114,144,139,137,134,148,161,120,119,118,113";
attribute chip_pin of sd2_data : signal is "166,164,162,160,146,147,159,168";
attribute chip_pin of sd2_ba : signal is "126,127";
attribute chip_pin of sdram2_clk : signal is "186";
attribute chip_pin of sd2_cke : signal is "143";
attribute chip_pin of sd2_dqm : signal is "145";
attribute chip_pin of sd2_cs : signal is "128";
attribute chip_pin of sd2_we : signal is "133";
attribute chip_pin of sd2_cas : signal is "132";
attribute chip_pin of sd2_ras : signal is "131";


-- Video output via custom board

attribute chip_pin of vga_red : signal is "13, 9, 5, 240, 238, 236";
attribute chip_pin of vga_green : signal is "49, 45, 43, 39, 37, 18";
attribute chip_pin of vga_blue : signal is "52, 50, 46, 44, 41, 38";

attribute chip_pin of vga_hsync : signal is "51";
attribute chip_pin of vga_vsync : signal is "55";

-- Audio output via custom board

attribute chip_pin of aud_l : signal is "6";
attribute chip_pin of aud_r : signal is "22";

-- PS/2 sockets on custom board

attribute chip_pin of ps2k_clk : signal is "235";
attribute chip_pin of ps2k_dat : signal is "237";
attribute chip_pin of ps2m_clk : signal is "239";
attribute chip_pin of ps2m_dat : signal is "4";

-- RS232
attribute chip_pin of rs232_rxd : signal is "98";
attribute chip_pin of rs232_txd : signal is "112";

-- SD card interface
attribute chip_pin of sd_cs : signal is "185";
attribute chip_pin of sd_miso : signal is "196";
attribute chip_pin of sd_mosi : signal is "188";
attribute chip_pin of sd_clk : signal is "194";


-- Power and LEDs
attribute chip_pin of power_hold : signal is "171";
attribute chip_pin of power_button : signal is "94";

attribute chip_pin of leds : signal is "173, 169, 167, 135";

attribute chip_pin of vga_scandbl : signal is "231";

-- Free pins, not yet assigned

attribute chip_pin of misc_ios_1 : signal is "12,14,56,234,21,57";

attribute chip_pin of misc_ios_21 : signal is "226,232";
attribute chip_pin of misc_ios_22 : signal is "176,183,200,202,207,216,218,224,230";

attribute chip_pin of joy1 : signal is "201,223,221,219,217,214,203";
attribute chip_pin of joy2 : signal is "184,182,177,197,195,189,187";

-- Signals internal to the project

signal clk : std_logic;
signal reset_n : std_logic;  -- active low
signal counter : unsigned(34 downto 0);

signal debugvalue : std_logic_vector(15 downto 0);

signal currentX : unsigned(11 downto 0);
signal currentY : unsigned(11 downto 0);
signal end_of_pixel : std_logic;
signal end_of_line : std_logic;
signal end_of_frame : std_logic;

-- SDRAM - merged signals to make the two chips appear as a single 16-bit wide entity.
signal sdr_addr : std_logic_vector(11 downto 0);
signal sdr_dqm : std_logic_vector(1 downto 0);
signal sdr_we : std_logic;
signal sdr_cas : std_logic;
signal sdr_ras : std_logic;
signal sdr_cs : std_logic;
signal sdr_ba : std_logic_vector(1 downto 0);
-- signal sdr_clk : std_logic;
signal sdr_cke : std_logic;

signal ps2m_clk_in : std_logic;
signal ps2m_clk_out : std_logic;
signal ps2m_dat_in : std_logic;
signal ps2m_dat_out : std_logic;

signal ps2k_clk_in : std_logic;
signal ps2k_clk_out : std_logic;
signal ps2k_dat_in : std_logic;
signal ps2k_dat_out : std_logic;

signal power_led : unsigned(5 downto 0);
signal disk_led : unsigned(5 downto 0);
signal net_led : unsigned(5 downto 0);
signal odd_led : unsigned(5 downto 0);

signal rs232_txd_inv : std_logic; 

-- Minimig signals

signal clk7m : std_logic;
signal clk28m : std_logic;
signal pll_locked : std_logic;

-- LED signals
signal diskled : std_logic;
signal floppyled : std_logic;

begin

	midi_txd <= not rs232_txd;

	power_led(3 downto 0)<=(others =>'0');
	disk_led(5 downto 0)<=(others =>diskled);
	odd_led(5 downto 0)<=(others =>floppyled);
	net_led(5 downto 0)<=(others =>'0');

	ps2m_dat_in<=ps2m_dat;
	ps2m_dat <= '0' when ps2m_dat_out='0' else 'Z';
	ps2m_clk_in<=ps2m_clk;
	ps2m_clk <= '0' when ps2m_clk_out='0' else 'Z';

	ps2k_dat_in<=ps2k_dat;
	ps2k_dat <= '0' when ps2k_dat_out='0' else 'Z';
	ps2k_clk_in<=ps2k_clk;
	ps2k_clk <= '0' when ps2k_clk_out='0' else 'Z';

	sd1_addr <= sdr_addr;
	sd1_dqm <= sdr_dqm(0);
--	sd1_clk <= sdr_clk;
	sd1_we <= sdr_we;
	sd1_cas <= sdr_cas;
	sd1_ras <= sdr_ras;
	sd1_cs <= sdr_cs;
	sd1_ba <= sdr_ba;
	sd1_cke <= sdr_cke;

	sd2_addr <= sdr_addr;
	sd2_dqm <= sdr_dqm(1);
--	sd2_clk <= sdr_clk;
	sd2_we <= sdr_we;
	sd2_cas <= sdr_cas;
	sd2_ras <= sdr_ras;
	sd2_cs <= sdr_cs;
	sd2_ba <= sdr_ba;
	sd2_cke <= sdr_cke;

	mypll : entity work.PLL
		port map (
			inclk0 => clk_50,
			c0 => clk,
			c1 => sdram1_clk,
			c3 => clk28m,
			c4 => clk7m,
--			c2 => sd2_clk
			locked => pll_locked
		);
		
	mypll2 : entity work.PLL2
		port map (
			inclk0 => clk_50,
			c1 => sdram2_clk
		);

	myleds : entity work.statusleds_pwm
	port map(
		clk => clk,
		power_led => power_led,
		disk_led => disk_led,
		net_led => net_led,
		odd_led => odd_led,
		leds_out => leds
	);
	
	myreset : entity work.poweronreset
		port map(
			clk => clk,
			reset_button => reset_button and pll_locked,
			reset_out => reset_n,
			power_button => power_button,
			power_hold => power_hold		
		);
	

myFampiga: entity work.Fampiga
	generic map(
		sdram_rows => 12,
		sdram_cols => 10
	)
	port map(
		clk=>clk,
		clk7m=>clk7m,
		clk28m=>clk28m,
		reset_n=>reset_n,
		powerled_out=>power_led(5 downto 4),
		diskled_out=>diskled,
		oddled_out=>floppyled,

		-- SDRAM.  A separate shifted clock is provided by the toplevel
		sdr_addr => sdr_addr,
		sdr_data(15 downto 8) => sd2_data,
		sdr_data(7 downto 0) => sd1_data,
		sdr_ba => sdr_ba,
		sdr_cke => sdr_cke,
		sdr_dqm => sdr_dqm,
		sdr_cs => sdr_cs,
		sdr_we => sdr_we,
		sdr_cas => sdr_cas,
		sdr_ras => sdr_ras,
	
		-- VGA
		vga_r(7 downto 2) => vga_red,
		vga_g(7 downto 2) => vga_green,
		vga_b(7 downto 2) => vga_blue,

		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,

		vga_scandbl => vga_scandbl,
		
		-- PS/2
		ps2k_clk_in => ps2k_clk_in,
		ps2k_clk_out => ps2k_clk_out,
		ps2k_dat_in => ps2k_dat_in,
		ps2k_dat_out => ps2k_dat_out,
		ps2m_clk_in => ps2m_clk_in,
		ps2m_clk_out => ps2m_clk_out,
		ps2m_dat_in => ps2m_dat_in,
		ps2m_dat_out => ps2m_dat_out,
		
		-- Audio
		aud_l => aud_l,
		aud_r => aud_r,
		
		-- RS232
		rs232_rxd => rs232_rxd,
		rs232_txd => rs232_txd,

		-- SD card interface
		sd_cs => sd_cs,
		sd_miso => sd_miso,
		sd_mosi => sd_mosi,
		sd_clk => sd_clk,
		sd_ack => '1',

		-- Joystick
		joy1_n => joy1,
		joy2_n => joy2,
		joy3_n => (others =>'1'),
		joy4_n => (others =>'1')
	);
	
end rtl;
