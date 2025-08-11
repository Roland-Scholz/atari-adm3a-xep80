library ieee;
use ieee.std_logic_1164.all;
--use  IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

entity xep80 is
	port(
		n_reset		: in std_logic;
		clk		: in std_logic;
		csync		: out std_logic;
		video		: out std_logic;
		led0		: out std_logic;
		led1		: out std_logic;
		led2		: out std_logic
	);
end xep80;

architecture struct of xep80 is
	signal counter: std_logic_vector(2 downto 0);
	signal chardat: std_logic_vector(7 downto 0);
	signal chardatin: std_logic_vector(7 downto 0);
	signal daddress: std_logic_vector(10 downto 0);
	signal daddress_temp: std_logic_vector(10 downto 0);
	
	signal char: std_logic_vector(7 downto 0) := "01000001";
	
	signal clkcount: integer := 0;
	signal vline: std_logic_vector(8 downto 0);
	signal vsync: std_logic;
	signal hsync: std_logic;
	signal pixclk: std_logic;
	signal pllclk: std_logic;
	signal pllclk1: std_logic;
	signal visible: std_logic;
	signal vid: std_logic;
	signal border: std_logic;
	signal pixcnt: std_logic_vector(9 downto 0);
	signal vout: std_logic_vector(1 downto 0);

--	signal shortsync1: std_logic;
--	signal shortsync2: std_logic;
--	signal longsync1: std_logic;
--	signal longsync2: std_logic;
--	signal slsync: std_logic;

	constant SCALE : integer := 1;
	constant VIDEOCLK: real := 14500000.0 / real(SCALE);
	constant HPIXELS: integer := 640 / SCALE;

--	constant BORDERSTART: integer := integer(0.000013 * VIDEOCLK);

	constant FPORCH:		integer := integer(0.00000200 * VIDEOCLK);
	constant HSYNCEND:	integer := integer(0.00000500 * VIDEOCLK);
	constant BPORCH:		integer := integer(0.00001200 * VIDEOCLK);
	constant HSTART:		integer := integer(0.00001435 * VIDEOCLK);		--visible pic starts at 14uS
	constant BORDEREND:	integer := integer(0.00006000 * VIDEOCLK);
	constant	HEND:			integer := integer(0.00006400 * VIDEOCLK);			--pixels per line
	
	constant VSTART: integer := 72;
	constant VLINES: integer := 200;
	
	constant SYNC:  std_logic_vector(1 downto 0) := "00";
	constant BLACK: std_logic_vector(1 downto 0) := "01";
	constant GREY:  std_logic_vector(1 downto 0) := "10";
	constant WHITE: std_logic_vector(1 downto 0) := "11";

begin

	pixpll: entity work.pixpll
	port map (
		inclk0 => clk,
		c0	=> pllclk
	);
		
	charrom: entity work.charrom
	port map (
		address	=> char & vline(2 downto 0),
		clock		=> pixclk,
		q			=> chardat
	);
	
	dispram: entity work.dispram
	port map (
		address	=> daddress,
		clock		=> pixclk,
		q			=> char,
		data		=> chardatin,
		wren		=> '0'
	);

	
	
	led0 <= not counter(0);
	led1 <= not counter(1);
	led2 <= not counter(2);
	
	video <= vout(1);
	csync <= vout(0);


	vout <=	SYNC when vline < 8 or pixcnt < HSYNCEND else
				--GREY	when pixcnt > BPORCH+10 and visible = '0' and pixcnt < BORDEREND and vline > 60 and vline < 256 else
				WHITE when vid = '1' and visible = '1' else
				BLACK;
			 
	process (pllclk)
	begin
		if SCALE = 1 then
			pixclk <= pllclk;
		end if;
		if rising_edge(pllclk) then
			pllclk1 <= not pllclk1;
			if scale = 4 then
				if pllclk1 = '1' then
					pixclk <= not pixclk;
				end if;
			end if;
			if scale = 2 then
				pixclk <= not pixclk;
			end if;
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			clkcount <= clkcount + 1;
			if clkcount > 25000000/4 then
				clkcount <= 0;
				counter <= counter + 1;
			end if;	
		end if;
	end process;

	--
	-- 928 pixel per line @ 14.5Mhz = 64uS
	-- 1 pixel = 69ns
	--
	process (pixclk)
	begin
		if rising_edge(pixclk) then
		
			if pixcnt <  HEND-1 then
				pixcnt <= pixcnt + 1;
			else
				pixcnt <= (others => '0');
				vline <= vline + 1;
				
				daddress <= daddress_temp;
	
				if vline(2 downto 0) = 6 and vline >= VSTART then
					daddress_temp <= daddress_temp + 80;
				end if;
			end if;
		
			if vline = 311 then
				vline <= (others => '0');
				daddress_temp <= (others => '0');
			end if;
			
			if pixcnt >= HSTART and pixcnt < HSTART + HPIXELS and 
				vline  >= VSTART and vline  < VSTART + VLINES then				
				visible <= '1';
				vid <= chardat(7 - to_integer(unsigned(pixcnt(2 downto 0))));
				if pixcnt(2 downto 0) = 5 then
					daddress <= daddress + 1;
				end if;
			else
				visible <= '0';
			end if;
										
		end if;
	end process;
	
end;
