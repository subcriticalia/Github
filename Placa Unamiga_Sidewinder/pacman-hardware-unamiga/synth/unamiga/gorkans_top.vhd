
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity multicore_top is
port(
 	-- Clocks
		clock_50_i			: in    std_logic;

		-- PS2
		ps2_clk_io			: inout std_logic								:= 'Z';
		ps2_data_io			: inout std_logic								:= 'Z';
		ps2_mouse_clk_io  : inout std_logic								:= 'Z';
		ps2_mouse_data_io : inout std_logic								:= 'Z';

		-- SD Card
		sd_cs_n_o			: out   std_logic								:= '1';
		sd_sclk_o			: out   std_logic								:= '0';
		sd_mosi_o			: out   std_logic								:= '0';
		sd_miso_i			: in    std_logic;

		-- Joystick
		joy1_up_i			: in    std_logic;
		joy1_down_i			: in    std_logic;
		joy1_left_i			: in    std_logic;
		joy1_right_i		: in    std_logic;
		joy1_p6_i			: in    std_logic;
		joy1_p7_o			: out   std_logic								:= '1';
		joy1_p9_i			: in    std_logic;
		joy2_up_i			: in    std_logic;
		joy2_down_i			: in    std_logic;
		joy2_left_i			: in    std_logic;
		joy2_right_i		: in    std_logic;
		joy2_p6_i			: in    std_logic;
		joy2_p7_o			: out   std_logic								:= '1';
		joy2_p9_i			: in    std_logic;

		-- Audio
		dac_l_o				: out   std_logic								:= '0';
		dac_r_o				: out   std_logic								:= '0';
		ear_i					: in    std_logic;
		mic_o					: out   std_logic								:= '0';

		-- VGA
		vga_r_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_g_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_b_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_hsync_n_o		: out   std_logic								:= '1';
		vga_vsync_n_o		: out   std_logic								:= '1';


		-- Debug
		leds_n_o				: out   std_logic_vector(7 downto 0)	:= (others => '1')
		
	);
end;



architecture RTL of multicore_top is


	--	only set one of these
	constant PENGO          : std_logic := '0'; -- set to 1 when using Pengo ROMs, 0 otherwise
	constant PACMAN         : std_logic := '1'; -- set to 1 for all other Pacman hardware games

	-- only set one of these when PACMAN is set
	constant MRTNT          : std_logic := '0'; -- set to 1 when using Mr TNT ROMs, 0 otherwise
	constant LIZWIZ         : std_logic := '0'; -- set to 1 when using Lizard Wizard ROMs, 0 otherwise
	constant MSPACMAN       : std_logic := '0'; -- set to 1 when using Ms Pacman ROMs, 0 otherwise

	constant dipsw1_pengo   : std_logic_vector( 7 downto 0) := "11100000";
--																					||||||||
--																					|||||||0 = bonus at 30K
--																					|||||||1 = bonus at 50K
--																					||||||0 = attract sound on
--																					||||||1 = attract sound off
--																					|||||0 = upright
--																					|||||1 = cocktail
--																					|||00 = 5 pengos
--																					|||01 = 4 pengos
--																					|||10 = 3 pengos
--																					|||11 = 2 pengos
--																					||0 = continuous play
--																					||1 = normal play
--																					00 = hardest
--																					01 = hard
--																					10 = medium
--																					11 = easy
	constant dipsw2_pengo   : std_logic_vector( 7 downto 0) := "11001100"; -- 1 coin/1 play

	constant dipsw1_pacman  : std_logic_vector( 7 downto 0) := "11001001";
--																					||||||||
--																					||||||00 = free play
--																					||||||01 = 1 coin / 1 play
--																					||||||10 = 1 coin / 2 play
--																					||||||11 = 2 coin / 1 play
--																					||||00 = 1 lives
--																					||||01 = 2 lives
--																					||||10 = 3 lives
--																					||||11 = 5 lives
--																					||00 = bonus pacman at 10K
--																					||01 = bonus pacman at 15K
--																					||10 = bonus pacman at 20K
--																					||11 = no bonus
--																					|0 = rack test
--																					|1 = play mode
--																					0 = freeze picture 
--																					1 = unfreeze picture 

	-- input registers
	signal in0_reg          : std_logic_vector( 7 downto 0) := (others => '1');
	signal in1_reg          : std_logic_vector( 7 downto 0) := (others => '1');
	signal dipsw1_reg       : std_logic_vector( 7 downto 0);
	signal dipsw2_reg       : std_logic_vector( 7 downto 0);
	signal decoder_ena_l    : std_logic;

	signal reset            : std_logic;
	signal clk              : std_logic;
	signal ena_6            : std_logic;
	signal ena_12           : std_logic;

	-- timing
	signal hcnt             : std_logic_vector( 8 downto 0) := "010000000"; -- 80
	signal vcnt             : std_logic_vector( 8 downto 0) := "011111000"; -- 0F8

	signal do_hsync         : boolean := true;
	signal hsync_o          : std_logic := '1';
	signal vsync_o          : std_logic := '1';
	signal hsync_i          : std_logic := '1';
	signal vsync_i          : std_logic := '1';
	signal comp_blank       : std_logic;

	-- scan doubler signals
	signal video_out        : std_logic_vector( 7 downto 0) := (others => '0');
	signal dummy            : std_logic_vector( 3 downto 0) := (others => '0');

	--
	signal audio            : std_logic_vector( 7 downto 0);
	signal audio_pwm        : std_logic;

	signal ps2_codeready		: std_logic := '1';                                 
	signal ps2_scancode		: std_logic_vector( 9 downto 0) := (others => '0'); 
	
	signal I_RESET				: std_logic := '0';
	
	-- SRAM
	signal sram_ce_n_s : std_logic := '1';

begin
	vsync_i <= not vsync_o;
	hsync_i <= not hsync_o;

	--
	-- clocks
	--
	u_clocks : entity work.PACMAN_CLOCKS
	port map (
		I_CLK_REF  => clock_50_i,
		I_RESET    => I_RESET,
		--
		O_CLK_REF  => open,
		--
		O_ENA_12   => ena_12,
		O_ENA_6    => ena_6,
		O_CLK      => clk,
		O_RESET    => reset
	);

	u_pacman : entity work.PACMAN_MACHINE
	generic map (
		PACMAN		=> PACMAN,
		PENGO       => PENGO,
		MRTNT 		=> MRTNT,
		LIZWIZ 		=> LIZWIZ,
		MSPACMAN		=> MSPACMAN
	)
	port map (
		clk        => clk,
		ena_6      => ena_6,
		reset		  => reset,
		video_r    => video_out( 7 downto 5), -- 3 bits
		video_g    => video_out( 4 downto 2), -- 3 bits
		video_b    => video_out( 1 downto 0), -- 2 bits
		hsync      => hsync_o,
		vsync      => vsync_o,
		comp_blank => comp_blank,
		audio      => audio,

		in0_reg    => in0_reg,
		in1_reg    => in1_reg,
		dipsw1_reg => dipsw1_reg,
		dipsw2_reg => dipsw2_reg
		

	);
	
	


	-- Pacman resolution 224x288
	u_scanconv : entity work.VGA_SCANCONV
	generic map (
		hA				=>  16,	-- h front porch
		hB				=>  92,	-- h sync
		hC				=>  46,	-- h back porch
		hres			=> 578,	-- visible video
		hpad			=>  18,	-- padding either side to reach standard VGA resolution (hres + 2*hpad = hD)

		vB				=>   2,	-- v sync
		vC				=>  32,	-- v back porch
		vres			=> 448,	-- visible video
		vpad			=>  16,	-- padding either side to reach standard VGA resolution (vres + vpad = vD)

		cstart      =>  38,  -- composite sync start
		clength     => 288   -- composite sync length
	)
	port map (
		I_VIDEO                => video_out,
		I_HSYNC                => hsync_i,
		I_VSYNC                => vsync_i,


		O_VIDEO( 7 downto  5)  => vga_r_o,
		O_VIDEO( 4 downto  2)  => vga_g_o,
		O_VIDEO( 1 downto  0)  => vga_b_o (2 downto 1),
		O_HSYNC                => vga_hsync_n_o,
		O_VSYNC                => vga_vsync_n_o,
		O_CMPBLK_N             => open,
		--
		CLK                    => ena_6,
		CLK_X4                 => clk
	);

	--
	-- Audio DAC
	--
	u_dac : entity work.dac
	generic map(
		msbi_g => 7
	)
	port  map(
		clk_i   => clk,
		res_i   => reset,
		dac_i   => audio,
		dac_o   => audio_pwm
	);

	dac_l_o <= audio_pwm;
	dac_r_o <= audio_pwm;

	-----------------------------------------------------------------------------
	-- Keyboard - active low buttons
	-----------------------------------------------------------------------------
	kbd_inst : entity work.Keyboard
	port map (
		Reset     => reset,
		Clock     => ena_6,
		PS2Clock  => ps2_clk_io,
		PS2Data   => ps2_data_io,
		CodeReady => ps2_codeready,
		ScanCode  => ps2_scancode
	);

-- ScanCode(9)          : 1 = Extended  0 = Regular
-- ScanCode(8)          : 1 = Break     0 = Make
-- ScanCode(7 downto 0) : Key Code

	dipsw1_reg <= dipsw1_pengo when PENGO = '1' else dipsw1_pacman ;
	dipsw2_reg <= dipsw2_pengo when PENGO = '1' else (others=>'1') ;
	


	process(ena_6)
	begin
		if rising_edge(ena_6) then
			if reset = '1' then
				in0_reg <= (others=>'1');
				in1_reg <=(others=>'1');
			--elsif (ps2_codeready = '1') then
			else
				if PENGO = '1' then
					case (ps2_scancode(7 downto 0)) is
											-- pengo closed is low
			--								in0_reg(6) <= '1';                 -- service
			--								in1_reg(4) <= '1';                 -- test
						when x"05" =>	in0_reg(4) <= ps2_scancode(8);     -- P1 coin "F1"
						when x"04" =>	in0_reg(5) <= ps2_scancode(8);     -- P2 coin "F3"

						when x"06" =>	in1_reg(5) <= ps2_scancode(8);     -- P1 start "F2"
						when x"0c" =>	in1_reg(6) <= ps2_scancode(8);     -- P2 start "F4"

						when x"43" =>	in0_reg(7) <= ps2_scancode(8);     -- P1 jump "I"
											in1_reg(7) <= ps2_scancode(8);     -- P2 jump "I"

						when x"75" =>	in0_reg(0) <= ps2_scancode(8);     -- P1 up arrow
											in1_reg(0) <= ps2_scancode(8);     -- P2 up arrow

						when x"72" =>	in0_reg(1) <= ps2_scancode(8);     -- P1 down arrow
											in1_reg(1) <= ps2_scancode(8);     -- P2 down arrow

						when x"6b" =>	in0_reg(2) <= ps2_scancode(8);     -- P1 left arrow
											in1_reg(2) <= ps2_scancode(8);     -- P2 left arrow

						when x"74" =>	in0_reg(3) <= ps2_scancode(8);     -- P1 right arrow
											in1_reg(3) <= ps2_scancode(8);     -- P2 right arrow

						when others => null;
				end case;
			
					--in0_reg(4) <= btn_n_i(1); -- coin
					--in1_reg(5) <= btn_n_i(3); --start p1
					--in1_reg(6) <= btn_n_i(4); --start p2
				 
					in0_reg(7) <= joy1_p6_i;     -- P1 jump "I"
					in0_reg(0) <= joy1_up_i;     -- P1 up arrow
					in0_reg(1) <= joy1_down_i;   -- P1 down arrow
					in0_reg(2) <= joy1_left_i;   -- P1 left arrow
					in0_reg(3) <= joy1_right_i;  -- P1 right arrow
					
					--in1_reg(7) <= joy2_p6_i;     -- P2 jump "I"
					--in1_reg(0) <= joy2_up_i;     -- P2 up arrow
					--in1_reg(1) <= joy2_down_i;   -- P2 down arrow
					--in1_reg(2) <= joy2_left_i;   -- P2 left arrow
					--in1_reg(3) <= joy2_right_i;  -- P2 right arrow
			
				elsif PACMAN = '1' then
					case (ps2_scancode(7 downto 0)) is
					--						-- pacman on is low
					--						in0_reg(7) <= '1';                 -- coin
					--						in0_reg(4) <= '1';                 -- test_l dipswitch (rack advance)
					--						in1_reg(7) <= '1';                 -- table
					--						in1_reg(4) <= '1';                 -- test
						when x"05" =>	in0_reg(5) <= ps2_scancode(8);     -- P1 coin "F1"
						when x"04" =>	in0_reg(6) <= ps2_scancode(8);     -- P2 coin "F3"

						when x"06" =>	in1_reg(5) <= ps2_scancode(8);     -- P1 start "F2"
						when x"0c" =>	in1_reg(6) <= ps2_scancode(8);     -- P2 start "F4"

						when x"43" =>	in0_reg(7)  <= ps2_scancode(8);       -- P1 jump "I"
											in1_reg(7)  <= ps2_scancode(8);       -- P2 jump "I"

						when x"75" =>	in0_reg(0) <= ps2_scancode(8);     -- P1 up arrow
											in1_reg(0) <= ps2_scancode(8);     -- P2 up arrow

						when x"72" =>	in0_reg(3) <= ps2_scancode(8);     -- P1 down arrow
											in1_reg(3) <= ps2_scancode(8);     -- P2 down arrow

						when x"6b" =>	in0_reg(1) <= ps2_scancode(8);     -- P1 left arrow
											in1_reg(1) <= ps2_scancode(8);     -- P2 left arrow

						when x"74" =>	in0_reg(2) <= ps2_scancode(8);     -- P1 right arrow
											in1_reg(2) <= ps2_scancode(8);     -- P2 right arrow

						when others => null;
					end case;
					
				--	in0_reg(5) <= btn_n_i(1); -- coin
				--	in1_reg(5) <= btn_n_i(3); --start p1
				--	in1_reg(6) <= btn_n_i(4); --start p2
				 
				--	p1_jump <= not joy1_p6_i;     -- P1 jump "I"
					in0_reg(0) <= joy1_up_i;     -- P1 up arrow
					in0_reg(3) <= joy1_down_i;   -- P1 down arrow
					in0_reg(1) <= joy1_left_i;   -- P1 left arrow
					in0_reg(2) <= joy1_right_i;  -- P1 right arrow
					
				--	p2_jump <= not joy2_p6_i;     -- P2 jump "I"
				--	in1_reg(0) <= joy2_up_i;     -- P2 up arrow
				--	in1_reg(3) <= joy2_down_i;   -- P2 down arrow
				--	in1_reg(1) <= joy2_left_i;   -- P2 left arrow
				--	in1_reg(2) <= joy2_right_i;  -- P2 right arrow
					
				end if;
			end if;
		end if;
	end process;
	


end RTL;
