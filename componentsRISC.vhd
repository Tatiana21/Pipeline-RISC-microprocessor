library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------
package componentsRISC is
	
	component dregister is --tested
	port (DIN: in std_logic_vector(15 downto 0); 
		  clk, en, reset: in std_logic; 
		  DOUT: out std_logic_vector(15 downto 0));
	end component;
	
	component dregister_IF_ID_IR is --tested
	port (DIN: in std_logic_vector(15 downto 0); 
		  clk, en, reset: in std_logic; 
		  DOUT: out std_logic_vector(15 downto 0));
	end component;
	
	component dflipflop is --tested
	port (DIN: in std_logic; 
		  clk, en, reset: in std_logic; 
		  DOUT: out std_logic);
	end component;
	
	component dflipflop_2 is --tested
		port (DIN: in std_logic_vector(1 downto 0); 
			  clk, en, reset: in std_logic; 
			  DOUT: out std_logic_vector(1 downto 0));
		end component;
	

	component dflipflop_3 is --tested
	port (DIN: in std_logic_vector(2 downto 0); 
		  clk, en, reset: in std_logic; 
		  DOUT: out std_logic_vector(2 downto 0));
	end component;
	
	component mux2_16 is --tested
	port (IN1,IN0: in std_logic_vector(15 downto 0); 
		  s: in std_logic; 
		  OUTPUT: out std_logic_vector(15 downto 0));
	end component;
	
	component mux4_16 is --tested
	port (IN3,IN2,IN1,IN0: in std_logic_vector(15 downto 0); 
		  s: in std_logic_vector(1 downto 0); 
		  OUTPUT: out std_logic_vector(15 downto 0));
	end component;
	
	component mux8_16 is --tested
	port (IN7,IN6,IN5,IN4,IN3,IN2,IN1,IN0: in std_logic_vector(15 downto 0); 
		  s: in std_logic_vector(2 downto 0); 
		  OUTPUT: out std_logic_vector(15 downto 0));
	end component;
	
	component mux2_3 is --tested
	port (IN1,IN0: in std_logic_vector(2 downto 0); 
		  s: in std_logic; 
		  OUTPUT: out std_logic_vector(2 downto 0));
	end component;
	
	component mux4_3 is --tested
	port (IN3,IN2,IN1,IN0: in std_logic_vector(2 downto 0); 
		  s: in std_logic_vector(1 downto 0); 
		  OUTPUT: out std_logic_vector(2 downto 0));
	end component;
	
	component mux8_3 is --tested
	port (IN7,IN6,IN5,IN4,IN3,IN2,IN1,IN0: in std_logic_vector(2 downto 0); 
		  s: in std_logic_vector(2 downto 0); 
		  OUTPUT: out std_logic_vector(2 downto 0));
	end component;
	
	component priority is --tested
	port (INPUT: in std_logic_vector(8 downto 0); 
		  output: out std_logic_vector(2 downto 0); 
		  valid2: out std_logic);
	end component;

	component ir_decoder is
	port (s: in std_logic_vector(2 downto 0); 
		  IR: in std_logic_vector(15 downto 0); 
		  new_IR: out std_logic_vector(15 downto 0));
	end component;

	component register_file is
	port (
		   a1,a2,a3: in std_logic_vector(2 downto 0);   --a3 is the address where data to be written , a2 a1 to read the data
		   d3, d4: in std_logic_vector(15 downto 0);        -- d3 is the daata to write 
			wr, wr_7: in std_logic;                            
			d1, d2: out std_logic_vector(15 downto 0);
			reset: in std_logic;
			clk: in std_logic);
	end component;
	
	component LeftShift is 
	port (IN1: in std_logic_vector(8 downto 0); 
		  OUTPUT1: out std_logic_vector(15 downto 0));
	end component;
	
	component SgnExtd7 is 
	port (IN1: in std_logic_vector(8 downto 0); 
		  OUTPUT1: out std_logic_vector(15 downto 0));
	end component;
	
	component SgnExtd10 is 
	port (IN1: in std_logic_vector(5 downto 0); 
		  OUTPUT1: out std_logic_vector(15 downto 0));
	end component;

	component I_memory is --tested
    generic (data_width: integer:= 16; addr_width: integer := 16);
    port(din: in std_logic_vector(data_width-1 downto 0);
        dout: out std_logic_vector(data_width-1 downto 0);
        rbar: in std_logic;
        wbar: in std_logic;
        addrin: in std_logic_vector(addr_width-1 downto 0));
	end component;
	
	component D_memory is --tested
    generic (data_width: integer:= 16; addr_width: integer := 16);
    port(din: in std_logic_vector(data_width-1 downto 0);
        dout: out std_logic_vector(data_width-1 downto 0);
        rbar: in std_logic;
        wbar: in std_logic;
        addrin: in std_logic_vector(addr_width-1 downto 0));
	end component;
	
	component alu is 
	port( X,Y : in std_logic_vector(15 downto 0); 
		  op_code_bits : in std_logic_vector(3 downto 0); 
		  cz_bits : in std_logic_vector(1 downto 0);
		  OUTPUT_ALU : out std_logic_vector(15 downto 0);
		  carry_ALU,zero_ALU : out std_logic);
	end component;

	component alu_adder is
	port (D1,D2 : in std_logic_vector(15 downto 0);
		OUTPUT: out std_logic_vector(15 downto 0));
	end component;

	
end package;
---------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity dregister is                  -- no. of bits
  port (
    din  : in  std_logic_vector(15 downto 0);
    dout : out std_logic_vector(15 downto 0);
    en: in std_logic;
    reset: in std_logic;
    clk     : in  std_logic);
end dregister;

architecture behave of dregister is

begin  -- behave
process(clk,reset)
begin
if(reset = '1') then
  dout <= "0000000000000000";
  else if(clk'event and clk = '1') then
    if en = '1' then
      dout <= din;
    end if;
  end if;
end if;
end process;
end behave;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity dregister_IF_ID_IR is                  -- no. of bits
  port (
    din  : in  std_logic_vector(15 downto 0);
    dout : out std_logic_vector(15 downto 0);
    en: in std_logic;
    reset: in std_logic;
    clk     : in  std_logic);
end dregister_IF_ID_IR;

architecture behave of dregister_IF_ID_IR is

begin  -- behave
process(clk)
begin
if(reset = '1') then
  dout <= "1111000000000000";
  else if(clk'event and clk = '1') then
    if en = '1' then
      dout <= din;
    end if;
  end if;
end if;
end process;
end behave;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity dflipflop is                  -- no. of bits
  port (
    din  : in  std_logic;
    dout : out std_logic;
    en: in std_logic;
    reset: in std_logic;
    clk     : in std_logic);
end dflipflop;

architecture behave of dflipflop is

begin  -- behave
process(clk,reset)
begin
if (reset = '1') then
  dout <= '0';
  else if(clk'event and clk = '1') then
    if en = '1' then
      dout <= din;
    end if;
  end if;
end if;
end process;
end behave;
-----------------------------------------------------------
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity dflipflop_3 is                  -- no. of bits
  port (
    din  : in  std_logic_vector(2 downto 0);
    dout : out std_logic_vector(2 downto 0);
    en: in std_logic;
    reset: in std_logic;
    clk     : in std_logic);
end dflipflop_3;

architecture behave of dflipflop_3 is

begin  -- behave
process(clk,reset)
begin
if (reset = '1') then
  dout <= "000";
  else if(clk'event and clk = '1') then
    if en = '1' then
      dout <= din;
    end if;
  end if;
end if;
end process;
end behave;
-----------------------------------------------------------

-----------------------------------------------------------
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity dflipflop_2 is                  -- no. of bits
  port (
    din  : in  std_logic_vector(1 downto 0);
    dout : out std_logic_vector(1 downto 0);
    en: in std_logic;
    reset: in std_logic;
    clk     : in std_logic);
end dflipflop_2;

architecture behave of dflipflop_2 is

begin  -- behave
process(clk,reset)
begin
if (reset = '1') then
  dout <= "00";
  else if(clk'event and clk = '1') then
    if en = '1' then
      dout <= din;
    end if;
  end if;
end if;
end process;
end behave;

------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity mux2_16 is
	port (IN1,IN0: in std_logic_vector(15 downto 0); s: in std_logic; OUTPUT: out std_logic_vector(15 downto 0));
end mux2_16;
	
architecture behave_mux2_16 of mux2_16 is
begin
process(s, IN0, IN1)
begin
	if(s='0') then OUTPUT <= IN0;
	end if;
	if(s='1') then OUTPUT <= IN1;
	end if;
end process;
end behave_mux2_16;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity mux4_16 is
	port (IN3,IN2,IN1,IN0: in std_logic_vector(15 downto 0); s: in std_logic_vector(1 downto 0); OUTPUT: out std_logic_vector(15 downto 0));
end mux4_16;

architecture behave_mux4_16 of mux4_16 is
begin
process(s, IN0, IN1, IN2, IN3)
begin
	if(s="00") then OUTPUT <= IN0;
	end if;
	if(s="01") then OUTPUT <= IN1;
	end if;
	if(s="10") then OUTPUT <= IN2;
	end if;
	if(s="11") then OUTPUT <= IN3;
	end if;
end process;
end behave_mux4_16;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity mux8_16 is
	port (IN7,IN6,IN5,IN4,IN3,IN2,IN1,IN0: in std_logic_vector(15 downto 0); s: in std_logic_vector(2 downto 0); OUTPUT: out std_logic_vector(15 downto 0));
end mux8_16;

architecture behave_mux8_16 of mux8_16 is
begin
process(s, IN0, IN1, IN2, IN3, IN4, IN5, IN6, IN7)
begin
	if(s="000") then OUTPUT <= IN0;
	end if;
	if(s="001") then OUTPUT <= IN1;
	end if;
	if(s="010") then OUTPUT <= IN2;
	end if;
	if(s="011") then OUTPUT <= IN3;
	end if;
	if(s="100") then OUTPUT <= IN4;
	end if;
	if(s="101") then OUTPUT <= IN5;
	end if;
	if(s="110") then OUTPUT <= IN6;
	end if;
	if(s="111") then OUTPUT <= IN7;
	end if;
end process;
end behave_mux8_16;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;


entity mux2_3 is
	port (IN1,IN0: in std_logic_vector(2 downto 0); s: in std_logic; OUTPUT: out std_logic_vector(2 downto 0));
end mux2_3;

architecture behave_mux2_3 of mux2_3 is
begin
process(s, IN0, IN1)
begin
	if(s='0') then OUTPUT <= IN0;
	end if;
	if(s='1') then OUTPUT <= IN1;
	end if;
end process;
end behave_mux2_3;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity mux4_3 is
	port (IN3,IN2,IN1,IN0: in std_logic_vector(2 downto 0); s: in std_logic_vector(1 downto 0); OUTPUT: out std_logic_vector(2 downto 0));
end mux4_3;

architecture behave_mux4_3 of mux4_3 is
begin
process(s, IN0, IN1, IN2, IN3)
begin
	if(s="00") then OUTPUT <= IN0;
	end if;
	if(s="01") then OUTPUT <= IN1;
	end if;
	if(s="10") then OUTPUT <= IN2;
	end if;
	if(s="11") then OUTPUT <= IN3;
	end if;
end process;
end behave_mux4_3;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;


entity mux8_3 is
	port (IN7,IN6,IN5,IN4,IN3,IN2,IN1,IN0: in std_logic_vector(2 downto 0); s: in std_logic_vector(2 downto 0); OUTPUT: out std_logic_vector(2 downto 0));
end mux8_3;

architecture behave_mux8_3 of mux8_3 is
begin
process(s, IN0, IN1, IN2, IN3, IN4, IN5, IN6, IN7)
begin
	if(s="000") then OUTPUT <= IN0;
	end if;
	if(s="001") then OUTPUT <= IN1;
	end if;
	if(s="010") then OUTPUT <= IN2;
	end if;
	if(s="011") then OUTPUT <= IN3;
	end if;
	if(s="100") then OUTPUT <= IN4;
	end if;
	if(s="101") then OUTPUT <= IN5;
	end if;
	if(s="110") then OUTPUT <= IN6;
	end if;
	if(s="111") then OUTPUT <= IN7;
	end if;
end process;
end behave_mux8_3;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity priority is
	port (INPUT: in std_logic_vector(8 downto 0); output: out std_logic_vector(2 downto 0); valid2: out std_logic);
	end priority; 

architecture behave_priority of priority is

begin
process(INPUT)
variable temp : integer := 0;
begin
	if    (INPUT(0)='1') then OUTPUT <= "000";
	elsif (INPUT(1)='1') then OUTPUT <= "001";
	elsif (INPUT(2)='1') then OUTPUT <= "010";
	elsif (INPUT(3)='1') then OUTPUT <= "011";
	elsif (INPUT(4)='1') then OUTPUT <= "100";
	elsif (INPUT(5)='1') then OUTPUT <= "101";
	elsif (INPUT(6)='1') then OUTPUT <= "110";
	elsif (INPUT(7)='1') then OUTPUT <= "111";
	else OUTPUT <= "000";
	end if;
	temp := 0;
 	for i in INPUT'range loop
    	if INPUT(i) = '1' then temp := temp + 1; 
    	end if;
	end loop;
	--if ((INPUT(0)) + (INPUT(1)) + (INPUT(2)) + (INPUT(3)) 
	--	+ (INPUT(4)) + (INPUT(5)) + (INPUT(6)) + (INPUT(7)) > '1') then valid2 <= '1';   
	--end if;
	if(temp>1) then valid2 <= '1';
	else valid2 <= '0';

	end if;

end process;
end behave_priority;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity ir_decoder is
	port (s: in std_logic_vector(2 downto 0); IR: in std_logic_vector(15 downto 0); new_IR: out std_logic_vector(15 downto 0));
end ir_decoder;

architecture behave_ir_dec of ir_decoder is
signal temp: std_logic_vector(15 downto 0):="0000000000000000";
begin
process(s, IR, temp)
begin
	if(s="000") then temp(0) <= '1'; else temp(0) <= '0'; end if;
	if(s="001") then temp(1) <= '1'; else temp(1) <= '0'; end if;
	if(s="010") then temp(2) <= '1'; else temp(2) <= '0'; end if;
	if(s="011") then temp(3) <= '1'; else temp(3) <= '0'; end if;
	if(s="100") then temp(4) <= '1'; else temp(4) <= '0'; end if;
	if(s="101") then temp(5) <= '1'; else temp(5) <= '0'; end if;
	if(s="110") then temp(6) <= '1'; else temp(6) <= '0'; end if;
	if(s="111") then temp(7) <= '1'; else temp(7) <= '0';end if;
	temp(15 downto 8)  <= "00000000";
	new_IR <= IR xor temp;
end process;
end behave_ir_dec;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity register_file is
	port (
	a1,a2,a3: in std_logic_vector(2 downto 0);   --a3 is the address where data to be written , a2 a1 to read the data
	d3, d4: in std_logic_vector(15 downto 0);        -- d3 is the daata to write 
	wr, wr_7: in std_logic;                            
	d1, d2: out std_logic_vector(15 downto 0);
	reset: in std_logic;
	clk: in std_logic
	);
end entity register_file;

architecture behave_rf of register_file is
  type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
  signal registers : registerFile;
  
  function To_Integer(x: bit_vector) return integer is
      variable xu: unsigned(x'range);
   begin
      for I in x'range loop
         xu(I) := x(I);
      end loop;
      return(To_Integer(xu));
   end To_Integer;

   function to_bit_vector(x: std_logic_vector) return bit_vector is
      variable ret_val: bit_vector(1 to x'length);
      alias lx: std_logic_vector(1 to x'length) is x;
  begin
 	for I in 1 to x'length loop
		if(lx(I) = '1') then
			ret_val(I) := '1';
		else
			ret_val(I) := '0';
		end if;
	end loop;
	return(ret_val);
  end to_bit_vector;
  
begin
  regFile : process (clk,wr,a1,a2,a3,d3,reset) is
  begin      
	if (reset='1') then
		registers(7) <= "0000000000000000";
		registers(6) <= "0000000000000110";
		registers(5) <= "0000000000000000";
		registers(4) <= "0000000000000011";
		registers(3) <= "0000000000000111";
		registers(2) <= "0000000000000010";
		registers(1) <= "0000000000000001";
		registers(0) <= "0000000000000000";
	else
		if (clk'event and clk = '1') then
			if wr_7='1' then
				registers(7) <= d4; 
			end if;
			if wr='1' then
				registers(to_Integer(to_bit_vector(a3))) <= d3;  -- Write
			end if;
		end if;
		d1 <= registers(to_Integer(to_bit_vector(a1)));
		d2 <= registers(to_Integer(to_bit_vector(a2))); 
	end if;
  end process;
end behave_rf;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity LeftShift is 
	port (IN1: in std_logic_vector(8 downto 0); OUTPUT1: out std_logic_vector(15 downto 0));
end LeftShift;

architecture behave_LeftShift of LeftShift is
begin
process(IN1)
begin
	OUTPUT1(0) <= '0';
	OUTPUT1(1) <= '0';
	OUTPUT1(2) <= '0';
	OUTPUT1(3) <= '0';
	OUTPUT1(4) <= '0';
	OUTPUT1(5) <= '0';
	OUTPUT1(6) <= '0';
	OUTPUT1(7) <= IN1(0);
	OUTPUT1(8) <= IN1(1);
	OUTPUT1(9) <= IN1(2);
	OUTPUT1(10) <= IN1(3);
	OUTPUT1(11) <= IN1(4);
	OUTPUT1(12) <= IN1(5);
	OUTPUT1(13) <= IN1(6);
	OUTPUT1(14) <= IN1(7);
	OUTPUT1(15) <= IN1(8);
end process;
end behave_LeftShift;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity SgnExtd7 is 
	port (IN1: in std_logic_vector(8 downto 0); OUTPUT1: out std_logic_vector(15 downto 0));
end SgnExtd7;

architecture behave_SgnExtd7 of SgnExtd7 is
begin
process(IN1)
begin
	OUTPUT1(0) <= IN1(0);
	OUTPUT1(1) <= IN1(1);
	OUTPUT1(2) <= IN1(2);
	OUTPUT1(3) <= IN1(3);
	OUTPUT1(4) <= IN1(4);
	OUTPUT1(5) <= IN1(5);
	OUTPUT1(6) <= IN1(6);
	OUTPUT1(7) <= IN1(7);
	OUTPUT1(8) <= IN1(8);
	OUTPUT1(9) <= IN1(8);
	OUTPUT1(10) <= IN1(8);
	OUTPUT1(11) <= IN1(8);
	OUTPUT1(12) <= IN1(8);
	OUTPUT1(13) <= IN1(8);
	OUTPUT1(14) <= IN1(8);
	OUTPUT1(15) <= IN1(8);

end process;
end behave_SgnExtd7;
-----------------------------------------------------------

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity SgnExtd10 is 
	port (IN1: in std_logic_vector(5 downto 0); OUTPUT1: out std_logic_vector(15 downto 0));
end SgnExtd10;

architecture behave_SgnExtd10 of SgnExtd10 is
begin
process(IN1)
begin
	OUTPUT1(0) <= IN1(0);
	OUTPUT1(1) <= IN1(1);
	OUTPUT1(2) <= IN1(2);
	OUTPUT1(3) <= IN1(3);
	OUTPUT1(4) <= IN1(4);
	OUTPUT1(5) <= IN1(5);
	OUTPUT1(6) <= IN1(5);
	OUTPUT1(7) <= IN1(5);
	OUTPUT1(8) <= IN1(5);
	OUTPUT1(9) <= IN1(5);
	OUTPUT1(10) <= IN1(5);
	OUTPUT1(11) <= IN1(5);
	OUTPUT1(12) <= IN1(5);
	OUTPUT1(13) <= IN1(5);
	OUTPUT1(14) <= IN1(5);
	OUTPUT1(15) <= IN1(5);

end process;
end behave_SgnExtd10;
-----------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

entity I_memory is
   generic (data_width: integer:= 16; addr_width: integer := 16);
   port(din: in std_logic_vector(data_width-1 downto 0);
        dout: out std_logic_vector(data_width-1 downto 0);
        rbar: in std_logic;
        wbar: in std_logic;
        addrin: in std_logic_vector(addr_width-1 downto 0));
end entity;
architecture behave of I_memory is
constant RAM_DEPTH :integer := 2**addr_width;
  type I_memory is array (integer range <>)of std_logic_vector (data_width-1 downto 0);
  signal marray : I_memory (0 to RAM_DEPTH-1);
   
   function To_Integer(x: bit_vector) return integer is
      variable xu: unsigned(x'range);
   begin
      for I in x'range loop
         xu(I) := x(I);
      end loop;
      return(To_Integer(xu));
   end To_Integer;

   function to_bit_vector(x: std_logic_vector) return bit_vector is
      variable ret_val: bit_vector(1 to x'length);
      alias lx: std_logic_vector(1 to x'length) is x;
   begin
 	for I in 1 to x'length loop
		if(lx(I) = '1') then
			ret_val(I) := '1';
		else
			ret_val(I) := '0';
		end if;
	end loop;
	return(ret_val);
   end to_bit_vector;
begin


   --- there is only one state..
   process(rbar,wbar, addrin, din)
      variable addr_var: integer range 0 to (2**(addr_width-8))-1;
   begin
	
   marray(0) <= "0000001010011000"; --ADD R2 R3 to R4
   marray(1) <= "0000111110100000"; --ADD R5 R2 to T6
   marray(2) <= "0000011011011000"; 
   marray(3) <= "0000100101111000"; --ADD R4 R2 to R7
   marray(4) <= "0000000000000100";
   marray(5) <= "0000000000000101";
   marray(6) <= "0000111110101000";
   marray(7) <= "1000101000001000";
   marray(8) <= "0000001011011000";
   marray(9) <= "0100000100000001";
   marray(10) <= "0000001010011000";
   marray(11) <= "1001110101000000";
   marray(12) <= "0000001010011000";
   marray(13) <= "0000001010011000";
   marray(14) <= "0000111100110000";	
   marray(15) <= "0000100110110000";
   marray(16) <= "1000101000001000";
   marray(17) <= "0000001011011000";
   marray(18) <= "0100000100000001";
   marray(19) <= "0000001010011000"; --LW R0 R2 01H
   marray(20) <= "0000011010100000";
   marray(21) <= "0100000100000001";
   marray(22) <= "0010000111111000"; --ADD R1 R2 R3
   marray(23) <= "0000001010011000";
   marray(24) <= "0000101010010000";
	
      addr_var := To_Integer(to_bit_vector(addrin));
        if(rbar = '0') then
          dout <= marray(addr_var);
        elsif (wbar = '0') then
          marray(addr_var) <= din;
	      end if;        
   end process;

end behave;

-----------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

entity D_memory is
   generic (data_width: integer:= 16; addr_width: integer := 16);
   port(din: in std_logic_vector(data_width-1 downto 0);
        dout: out std_logic_vector(data_width-1 downto 0);
        rbar: in std_logic;
        wbar: in std_logic;
        addrin: in std_logic_vector(addr_width-1 downto 0));
end entity;
architecture behave of D_memory is
constant RAM_DEPTH :integer := 2**addr_width;
  type D_memory is array (integer range <>)of std_logic_vector (data_width-1 downto 0);
  signal marray : D_memory (0 to RAM_DEPTH-1);
   
   function To_Integer(x: bit_vector) return integer is
      variable xu: unsigned(x'range);
   begin
      for I in x'range loop
         xu(I) := x(I);
      end loop;
      return(To_Integer(xu));
   end To_Integer;

   function to_bit_vector(x: std_logic_vector) return bit_vector is
      variable ret_val: bit_vector(1 to x'length);
      alias lx: std_logic_vector(1 to x'length) is x;
   begin
 	for I in 1 to x'length loop
		if(lx(I) = '1') then
			ret_val(I) := '1';
		else
			ret_val(I) := '0';
		end if;
	end loop;
	return(ret_val);
   end to_bit_vector;
begin


   --- there is only one state..
   process(rbar,wbar, addrin, din)
      variable addr_var: integer range 0 to (2**(addr_width-8))-1;
   begin
	
	marray(0) <= "0000000000000100"; --LW R0 R2 01H
   marray(1) <= "0000001010011000";
   marray(2) <= "0000000000000010";
   marray(3) <= "0000000000000011"; --ADD R1 R2 R3
   marray(4) <= "0000000000000100";
   marray(5) <= "0000000000000101";
   marray(6) <= "0000001010011000";
   marray(7) <= "0000000000001000";
   marray(8) <= "1000010011100000";
   marray(9) <= "0000010000100000";
   marray(10) <= "0000010000000000";
   marray(11) <= "0000000000000100";
   marray(12) <= "0000000001000000";
   marray(13) <= "0000000000000100";
   marray(14) <= "0000000000000100";	
   marray(15) <= "0000000000000100";
	
      addr_var := To_Integer(to_bit_vector(addrin));
        if(rbar = '0') then
          dout <= marray(addr_var);
        elsif (wbar = '0') then
          marray(addr_var) <= din;
	      end if;        
   end process;

end behave;
-----------------------------------------------------------

library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-----------------------------------------------
entity alu is 
	port( X,Y : in std_logic_vector(15 downto 0); 
		  op_code_bits : in std_logic_vector(3 downto 0); 
		  cz_bits : in std_logic_vector(1 downto 0);
		  OUTPUT_ALU : out std_logic_vector(15 downto 0);
		  carry_ALU,zero_ALU : out std_logic);
end entity;

architecture behave of alu is 
	signal OUTPUT_ALU_TEMP : std_logic_vector(15 downto 0);
	signal A_temp, B_temp, result_temp: std_logic_vector(16 downto 0);
-----------------------------------------------			
begin 

	A_temp(16) <= X(15);
	A_temp(15 downto 0)<= X;
	B_temp(16) <= Y(15);
     B_temp(15 downto 0) <= Y;
	result_temp <= std_logic_vector(signed(A_temp) + signed(B_temp));
------------------------------
process(op_code_bits, X, Y, result_temp)
begin

if (op_code_bits = "0000") then               -- 00-ADD, modify Z and C
   if(X(15) = Y(15) and X(15) = not(result_temp(15))) then
     OUTPUT_ALU_TEMP(15) <= not(result_temp(15));
     OUTPUT_ALU_TEMP(14 downto 0) <= result_temp (14 downto 0);
     carry_ALU <= '1';
   else
     OUTPUT_ALU_TEMP <= result_temp(15 downto 0);
     carry_ALU <= '0';
   end if;
end if;

if(op_code_bits = "0010") then           -- 10-NAND, modify Z
	OUTPUT_ALU_TEMP<= X nand Y;
end if;

end process;
------------------------------
OUTPUT_ALU <= OUTPUT_ALU_TEMP;
zero_ALU  <= '1' when OUTPUT_ALU_TEMP = "0000000000000000" else '0';
end behave;

-----------------------------------------------------------------------------------------
library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-----------------------------------------------

entity alu_adder is
	port (D1,D2 : in std_logic_vector(15 downto 0);
		OUTPUT: out std_logic_vector(15 downto 0));
end entity;

architecture behave of alu_adder is
begin
process(D1,D2)
begin
OUTPUT <= std_logic_vector(signed(D1)+signed(D2));
end process;
end behave;
------------------------------------
library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-----------------------------------------------
entity top_level is port (
	a1,a2,a3: in std_logic_vector(2 downto 0);   --a3 is the address where data to be written , a2 a1 to read the data
	d3: in std_logic_vector(15 downto 0);        -- d3 is the daata to write 
	wr: in std_logic;                            
	d1, d2: out std_logic_vector(15 downto 0);     
	clk: in std_logic
	);
	--is port (DIN: in std_logic_vector(15 downto 0); clk, en: in std_logic; DOUT: out std_logic_vector(15 downto 0));
end entity;

architecture behave_top of top_level is

component register_file is port (
	a1,a2,a3: in std_logic_vector(2 downto 0);   --a3 is the address where data to be written , a2 a1 to read the data
	d3: in std_logic_vector(15 downto 0);        -- d3 is the daata to write 
	wr: in std_logic;                            
	d1, d2: out std_logic_vector(15 downto 0);     
	clk: in std_logic
	);
	--port (DIN: in std_logic_vector(15 downto 0); clk, en: in std_logic; DOUT: out std_logic_vector(15 downto 0));
	end component;

begin
comp: register_file port map (a1=>a1, a2=>a2, a3=>a3, d1=>d1, d2=>d2, d3=>d3, wr=>wr, clk=>clk);
--comp: dregister port map (DIN=>DIN, clk=>clk, en=>en, DOUT=>DOUT);
end behave_top;
