--	(c) 2012 d18c7db(a)hotmail
--
--	This program is free software; you can redistribute it and/or modify it under
--	the terms of the GNU General Public License version 3 or, at your option,
--	any later version as published by the Free Software Foundation.
--
--	This program is distributed in the hope that it will be useful,
--	but WITHOUT ANY WARRANTY; without even the implied warranty of
--	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- For full details, see the GNU General Public License at www.gnu.org/licenses

--------------------------------------------------------------------------------
-- Video scan converter
--
--	Horizonal Timing
-- _____________              ______________________              _____________________
-- VIDEO (last) |____________|         VIDEO        |____________|         VIDEO (next)
-- -hD----------|-hA-|hB|-hC-|----------hD----------|-hA-|hB|-hC-|----------hD---------
-- __________________|  |________________________________|  |__________________________
-- HSYNC             |__|              HSYNC             |__|              HSYNC

-- Vertical Timing
-- _____________              ______________________              _____________________
-- VIDEO (last)||____________||||||||||VIDEO|||||||||____________||||||||||VIDEO (next)
-- -vD----------|-vA-|vB|-vC-|----------vD----------|-vA-|vB|-vC-|----------vD---------
-- __________________|  |________________________________|  |__________________________
-- VSYNC             |__|              VSYNC             |__|              VSYNC

-- Scan converter input and output timings compared to standard VGA
--	Resolution   - Frame   | Pixel      | Front     | HSYNC      | Back       | Active      | HSYNC    | Front    | VSYNC    | Back     | Active    | VSYNC
--              - Rate    | Clock      | Porch hA  | Pulse hB   | Porch hC   | Video hD    | Polarity | Porch vA | Pulse vB | Porch vC | Video vD  | Polarity
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--  In  256x224 - 59.18Hz |  6.000 MHz | 38 pixels |  32 pixels |  58 pixels |  256 pixels | negative | 16 lines | 8 lines  | 16 lines | 224 lines | negative
--  Out 640x480 - 59.18Hz | 24.000 MHz |  2 pixels |  92 pixels |  34 pixels |  640 pixels | negative | 17 lines | 2 lines  | 29 lines | 480 lines | negative
--  VGA 640x480 - 59.94Hz | 25.175 MHz | 16 pixels |  96 pixels |  48 pixels |  640 pixels | negative | 10 lines | 2 lines  | 33 lines | 480 lines | negative

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

--pragma translate_off
	use ieee.std_logic_textio.all;
	use std.textio.all;
--pragma translate_on

--library UNISIM;
	--use UNISIM.Vcomponents.all;

--	This scan converter only stores the active portion of the video line in the memory buffer,
--	at first one would think they could rely on the composite blanking signal to identify when
--	the active video is on, but most game implementations seem to have a seriously misaligned
--	video relative to the composite sync where the video is delayed relative to the composite
--	sync by any number of pixel clocks from 8 to well over 20 depending on implementation.
--	Instead of trying to delay the composite sync to match the video we completely ignore it
--	and instead we use cstart and clength to mark the active video portion, effectively simulating
-- a properly aligned composite sync
entity VGA_SCANCONV is
	generic (
		hA				: integer range 0 to 1023 :=  16;	-- h front porch
		hB				: integer range 0 to 1023 :=  96;	-- h sync
		hC				: integer range 0 to 1023 :=  48;	-- h back porch
		hres			: integer range 0 to 1023 := 640;	-- visible video
		hpad			: integer range 0 to 1023 :=   0;	-- padding either side to reach standard VGA resolution (hres + 2*hpad = hD)

		vB				: integer range 0 to 1023 :=   2;	-- v sync
		vC				: integer range 0 to 1023 :=  33;	-- v back porch
		vres			: integer range 0 to 1023 := 480;	-- visible video
		vpad			: integer range 0 to 1023 :=   0;	-- padding either side to reach standard VGA resolution (vres + 2*vpad = vD)

		cstart		: integer range 0 to 1023 :=  48;	-- composite sync start
		clength		: integer range 0 to 1023 := 640		-- composite sync length
	
	);
	port (
		I_VIDEO				: in  std_logic_vector(7 downto 0);
		I_HSYNC				: in  std_logic;
		I_VSYNC				: in  std_logic;
		--
		O_VIDEO				: out std_logic_vector(7 downto 0);
		O_HSYNC				: out std_logic;
		O_VSYNC				: out std_logic;
		O_CMPBLK_N			: out std_logic;
		--
		CLK					: in  std_logic;
		CLK_X4				: in  std_logic
	);
end;

architecture RTL of VGA_SCANCONV is
	--
	-- input timing
	--
	signal ivsync_last_x4	: std_logic := '1';
	signal ihsync_last		: std_logic := '1';
	signal hpos_i				: std_logic_vector( 9 downto 0) := (others => '0');

	--
	-- output timing
	--
	signal ovsync_last	: std_logic := '0';
	signal hpos_o			: std_logic_vector(10 downto 0) := (others => '0');

	signal vcnt				: integer range 0 to 1023 := 0;
	signal hcnt				: integer range 0 to 1023 := 0;
	signal hcnti			: integer range 0 to 1023 := 0;

begin
	-- dual port line buffer, max line of 512 pixels
--u_ram : RAMB16_S18_S18
--	generic map (INIT_A => X"00000", INIT_B => X"00000", SIM_COLLISION_CHECK => "NONE")  -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL"
--	port map (
--		-- input
--		DOA					=> open,
--		DIA					=> I_VIDEO,
--		DOPA					=> open,
--		DIPA					=> "00",
--		ADDRA					=> hpos_i,
--		WEA					=> '1',
--		ENA					=> '1',
--		SSRA					=> '0',
--		CLKA					=> CLK,
--
--		-- output
--		DOB					=> O_VIDEO,
--		DIB					=> x"0000",
--		DOPB					=> open,
--		DIPB					=> "00",
--		ADDRB					=> hpos_o(10 downto 1),
--		WEB					=> '0',
--		ENB					=> '1',
--		SSRB					=> '0',
--		CLKB					=> CLK_X4
--	);
		
	u_ram: work.dpram 
	GENERIC MAP
	(
		widthad_a	=> 10
	)
	PORT MAP
	(
		clock_a		=> CLK,
		address_a	=> hpos_i,
		data_a		=> I_VIDEO,
		wren_a		=> '1',
		q_a			=> open,
		
		clock_b		=> CLK_X4,
		address_b	=> hpos_o(10 downto 1),
		data_b		=> (others=>'0'),
		wren_b		=> '0',
		q_b			=> O_VIDEO
		
	);
	

	-- horizontal counter for input video
	p_hcounter : process
	begin
		wait until rising_edge(CLK);
		ihsync_last <= I_HSYNC;

		-- trigger off rising hsync
		if I_HSYNC = '1' and ihsync_last = '0' then
			hcnti <= 0;
		else
			hcnti <= hcnti + 1;
		end if;
	end process;

	-- increment write position during active video
	p_ram_in : process
	begin
		wait until rising_edge(CLK);

		if (hcnti < cstart) or (hcnti > (cstart + clength)) then
			hpos_i <= (others => '0');
		else
			hpos_i <= hpos_i + 1;
		end if;
	end process;

	-- VGA H and V counters, synchronized to input frame V sync, then H sync
	p_out_ctrs : process
		variable trigger : boolean;
	begin
		wait until rising_edge(CLK_X4);
		ivsync_last_x4 <= I_VSYNC;

		if (I_VSYNC = '0') and (ivsync_last_x4 = '1') then
			trigger := true;
		elsif trigger and I_HSYNC = '0' then
			trigger := false;
			hcnt <= 0;
			vcnt <= 0;
		else
			hcnt <= hcnt + 1;
			if hcnt = (hA+hB+hC+hres+hpad+hpad-1) then
				hcnt <= 0;
				vcnt <= vcnt + 1;
			end if;
		end if;
	end process;

	-- generate hsync
	p_gen_hsync : process
	begin
		wait until rising_edge(CLK_X4);
		-- H sync timing
		if (hcnt < hB) then
			O_HSYNC <= '0';
		else
			O_HSYNC <= '1';
		end if;
	end process;

	-- generate vsync
	p_gen_vsync : process
	begin
		wait until rising_edge(CLK_X4);
		-- V sync timing
		if (vcnt < vB) then
			O_VSYNC <= '0';
		else
			O_VSYNC <= '1';
		end if;
	end process;

	-- generate active output video
	p_gen_active_vid : process
	begin
		wait until rising_edge(CLK_X4);
		-- visible video area doubled from the original game
		if ((hcnt >= (hB + hC + hpad)) and (hcnt < (hB + hC + hres + hpad))) and ((vcnt >= (vB + vC + vpad)) and (vcnt < (vB + vC + vres + vpad))) then
			hpos_o <= hpos_o + 1;
		else
			hpos_o <= (others => '0');
		end if;
	end process;

	-- generate blanking signal including additional borders to pad the input signal to standard VGA resolution
	p_gen_blank : process
	begin
		wait until rising_edge(CLK_X4);
		-- active video area 640x480 (VGA) after padding with blank borders
		if ((hcnt >= (hB + hC)) and (hcnt < (hB + hC + hres + 2*hpad))) and ((vcnt >= (vB + vC)) and (vcnt < (vB + vC + vres + 2*vpad))) then
			O_CMPBLK_N <= '1';
		else
			O_CMPBLK_N <= '0';
		end if;
	end process;

end architecture RTL;
