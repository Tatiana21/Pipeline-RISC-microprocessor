library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_pipe is
port(
	clk: in std_logic;
	carry, zero: in std_logic;
	valid2: in std_logic;
	IF_ID_opcode_bits: in std_logic_vector(3 downto 0);
	cz_bits : in std_logic_vector(1 downto 0);
	eq_T1_T2 : in std_logic;
	reset: in std_logic;
	IF_ID_Rs1, IF_ID_Rs2: in std_logic_vector(2 downto 0);
	ID_RR_Rs1, ID_RR_Rs2: in std_logic_vector(2 downto 0);
	
	ID_RR_opcode_bits: in std_logic_vector(3 downto 0);
	ID_RR_valid2: in std_logic;
	ID_RR_RegWrite: in std_logic;
	ID_RR_Rd: in std_logic_vector(2 downto 0);
	ID_RR_Rd_in: in std_logic_vector(2 downto 0);

	RR_EX_opcode_bits: in std_logic_vector(3 downto 0);
	RR_EX_RegWrite: in std_logic;
	RR_EX_Rd: in std_logic_vector(2 downto 0);
	
	EX_MEM_opcode_bits: in std_logic_vector(3 downto 0);
	EX_MEM_RegWrite: in std_logic;
	EX_MEM_Rd: in std_logic_vector(2 downto 0);
	MEM_WB_RegWrite: in std_logic;
	MEM_WB_Rd: in std_logic_vector(2 downto 0);

	PC_en: out std_logic;
	IF_ID_en: out std_logic;
	C_en: out std_logic;
	Z_en: out std_logic;
	RegWrite_out: out std_logic;
	RegWrite_7: out std_logic;
	PC_mux: out std_logic_vector(2 downto 0);
	IR_mux: out std_logic_vector(1 downto 0);
	BALU2_mux: out std_logic;
	Rf_a2_mux: out std_logic;
	ALU2_mux: out std_logic_vector(2 downto 0);
	ALU1_mux: out std_logic_vector(2 downto 0);
	T1_mux: out std_logic_vector(2 downto 0);
	T2_mux: out std_logic_vector(2 downto 0);
	mem_data_in_mux: out std_logic;
	Rf_d3_mux: out std_logic_vector(1 downto 0);
	Rf_a3_mux: out std_logic_vector(1 downto 0);
	MemWrite: out std_logic;
	MemRead: out std_logic;
	FTB: out std_logic
);
end control_pipe;

architecture behave of control_pipe is
type op_code_store is (ADD, ADZ, ADC, ADI, NDU, NDC, NDZ, LHI, LW, SW, LM, SM, BEQ, JAL, JLR, NOP);
signal IF_ID_opcode, ID_RR_opcode,RR_EX_opcode,EX_MEM_opcode : op_code_store;
signal FTB_signal, RegWrite: std_logic := '1';		--default FTB is one , no loop back 
signal ALU1_muxs, ALU2_muxs, T1_muxs, T2_muxs: std_logic_vector(2 downto 0);
signal ALU1_muxf, ALU2_muxf, T1_muxf: std_logic;

begin
op_code_assign: process (IF_ID_opcode_bits,ID_RR_opcode_bits,RR_EX_opcode_bits,cz_bits,EX_MEM_opcode_bits,clk)
begin
if	(IF_ID_opcode_bits = "0000" and cz_bits ="00") then IF_ID_opcode <= add;
elsif	(IF_ID_opcode_bits = "0000" and cz_bits ="10") then IF_ID_opcode <= adc;
elsif	((IF_ID_opcode_bits = "0000") and (cz_bits ="01")) then IF_ID_opcode <= adz;
elsif	((IF_ID_opcode_bits = "0010") and (cz_bits ="00")) then IF_ID_opcode <= ndu;
elsif	((IF_ID_opcode_bits = "0010") and (cz_bits ="10")) then IF_ID_opcode <= ndc;
elsif	((IF_ID_opcode_bits = "0010") and (cz_bits ="01")) then IF_ID_opcode <= ndz;
elsif  (IF_ID_opcode_bits = "0001") then IF_ID_opcode <= adi;
elsif  (IF_ID_opcode_bits = "0011") then IF_ID_opcode <= lhi;
elsif  (IF_ID_opcode_bits = "0100") then IF_ID_opcode <= lw; 
elsif  (IF_ID_opcode_bits = "0101") then IF_ID_opcode <= sw;
elsif  (IF_ID_opcode_bits = "0110") then IF_ID_opcode <= lm;
elsif  (IF_ID_opcode_bits = "0111") then IF_ID_opcode <= sm;
elsif  (IF_ID_opcode_bits = "1100") then IF_ID_opcode <= beq;
elsif  (IF_ID_opcode_bits = "1000") then IF_ID_opcode <= jal;
elsif  (IF_ID_opcode_bits = "1001") then IF_ID_opcode <= jlr;
elsif  (IF_ID_opcode_bits = "1111") then IF_ID_opcode <= nop;
end if;

if	(ID_RR_opcode_bits = "0000" and cz_bits ="00") then ID_RR_opcode <= add;
elsif	(ID_RR_opcode_bits = "0000" and cz_bits ="10") then ID_RR_opcode <= adc;
elsif	((ID_RR_opcode_bits = "0000") and (cz_bits ="01")) then ID_RR_opcode <= adz;
elsif	((ID_RR_opcode_bits = "0010") and (cz_bits ="00")) then ID_RR_opcode <= ndu;
elsif	((ID_RR_opcode_bits = "0010") and (cz_bits ="10")) then ID_RR_opcode <= ndc;
elsif	((ID_RR_opcode_bits = "0010") and (cz_bits ="01")) then ID_RR_opcode <= ndz;
elsif  (ID_RR_opcode_bits = "0001") then ID_RR_opcode <= adi;
elsif  (ID_RR_opcode_bits = "0011") then ID_RR_opcode <= lhi;
elsif  (ID_RR_opcode_bits = "0100") then ID_RR_opcode <= lw; 
elsif  (ID_RR_opcode_bits = "0101") then ID_RR_opcode <= sw;
elsif  (ID_RR_opcode_bits = "0110") then ID_RR_opcode <= lm;
elsif  (ID_RR_opcode_bits = "0111") then ID_RR_opcode <= sm;
elsif  (ID_RR_opcode_bits = "1100") then ID_RR_opcode <= beq;
elsif  (ID_RR_opcode_bits = "1000") then ID_RR_opcode <= jal;
elsif  (ID_RR_opcode_bits = "1001") then ID_RR_opcode <= jlr;
elsif  (ID_RR_opcode_bits = "1111") then ID_RR_opcode <= nop;
end if;

if	(RR_EX_opcode_bits = "0000" and cz_bits ="00") then RR_EX_opcode <= add;
elsif	(RR_EX_opcode_bits = "0000" and cz_bits ="10") then RR_EX_opcode <= adc;
elsif	((RR_EX_opcode_bits = "0000") and (cz_bits ="01")) then RR_EX_opcode <= adz;
elsif	((RR_EX_opcode_bits = "0010") and (cz_bits ="00")) then RR_EX_opcode <= ndu;
elsif	((RR_EX_opcode_bits = "0010") and (cz_bits ="10")) then RR_EX_opcode <= ndc;
elsif	((RR_EX_opcode_bits = "0010") and (cz_bits ="01")) then RR_EX_opcode <= ndz;
elsif  (RR_EX_opcode_bits = "0001") then RR_EX_opcode <= adi;
elsif  (RR_EX_opcode_bits = "0011") then RR_EX_opcode <= lhi;
elsif  (RR_EX_opcode_bits = "0100") then RR_EX_opcode <= lw; 
elsif  (RR_EX_opcode_bits = "0101") then RR_EX_opcode <= sw;
elsif  (RR_EX_opcode_bits = "0110") then RR_EX_opcode <= lm;
elsif  (RR_EX_opcode_bits = "0111") then RR_EX_opcode <= sm;
elsif  (RR_EX_opcode_bits = "1100") then RR_EX_opcode <= beq;
elsif  (RR_EX_opcode_bits = "1000") then RR_EX_opcode <= jal;
elsif  (RR_EX_opcode_bits = "1001") then RR_EX_opcode <= jlr;
elsif  (RR_EX_opcode_bits = "1111") then RR_EX_opcode <= nop;
end if;

if	(EX_MEM_opcode_bits = "0000" and cz_bits ="00") then EX_MEM_opcode <= add;
elsif	(EX_MEM_opcode_bits = "0000" and cz_bits ="10") then EX_MEM_opcode <= adc;
elsif	((EX_MEM_opcode_bits = "0000") and (cz_bits ="01")) then EX_MEM_opcode <= adz;
elsif	((EX_MEM_opcode_bits = "0010") and (cz_bits ="00")) then EX_MEM_opcode <= ndu;
elsif	((EX_MEM_opcode_bits = "0010") and (cz_bits ="10")) then EX_MEM_opcode <= ndc;
elsif	((EX_MEM_opcode_bits = "0010") and (cz_bits ="01")) then EX_MEM_opcode <= ndz;
elsif  (EX_MEM_opcode_bits = "0001") then EX_MEM_opcode <= adi;
elsif  (EX_MEM_opcode_bits = "0011") then EX_MEM_opcode <= lhi;
elsif  (EX_MEM_opcode_bits = "0100") then EX_MEM_opcode <= lw; 
elsif  (EX_MEM_opcode_bits = "0101") then EX_MEM_opcode <= sw;
elsif  (EX_MEM_opcode_bits = "0110") then EX_MEM_opcode <= lm;
elsif  (EX_MEM_opcode_bits = "0111") then EX_MEM_opcode <= sm;
elsif  (EX_MEM_opcode_bits = "1100") then EX_MEM_opcode <= beq;
elsif  (EX_MEM_opcode_bits = "1000") then EX_MEM_opcode <= jal;
elsif  (EX_MEM_opcode_bits = "1001") then EX_MEM_opcode <= jlr;
elsif  (EX_MEM_opcode_bits = "1111") then EX_MEM_opcode <= nop;
end if;


end process op_code_assign;

------------------------------------------------------------------------------------
-- FTB process

FTB_process: process (ID_RR_opcode,ID_RR_valid2)
begin
if(((ID_RR_opcode = lm) or (ID_RR_opcode = sm)) and (ID_RR_valid2 = '1') ) then
	FTB_signal <='0';
	else FTB_signal <= '1';
	end if;

end process FTB_process;

-------------------------------------------------------------------------------------
-- signals for forwarding
forwarding_signals: process(IF_ID_opcode,FTB_signal)
	begin
	if (IF_ID_opcode=add or IF_ID_opcode=adc or IF_ID_opcode=adz or IF_ID_opcode=adi or IF_ID_opcode=ndu or IF_ID_opcode=ndc or IF_ID_opcode=ndz or IF_ID_opcode=lhi or IF_ID_opcode=beq or IF_ID_opcode=jal or IF_ID_opcode=jlr or (IF_ID_opcode=LM and FTB_signal='1') or (IF_ID_opcode=SM and FTB_signal='1')) then ALU1_muxf<='0'; 
	elsif (IF_ID_opcode=LW or IF_ID_opcode=SW) then ALU1_muxf<='1';
	end if;

	if (IF_ID_opcode=add or IF_ID_opcode=adc or IF_ID_opcode=adz or IF_ID_opcode=adi or IF_ID_opcode=ndu or IF_ID_opcode=ndc or IF_ID_opcode=ndz or IF_ID_opcode=lhi or IF_ID_opcode=beq or IF_ID_opcode=jal or IF_ID_opcode=jlr or (IF_ID_opcode=LM and FTB_signal='1') or (IF_ID_opcode=SM and FTB_signal='1') or IF_ID_opcode=LW or IF_ID_opcode=SW) then T1_muxf<='0'; 
	else T1_muxf <= '1';
	end if;

	if (IF_ID_opcode=add or IF_ID_opcode=adc or IF_ID_opcode=adz or IF_ID_opcode=ndu or IF_ID_opcode=ndc or IF_ID_opcode=ndz or IF_ID_opcode=lhi or IF_ID_opcode=beq or IF_ID_opcode=jal or IF_ID_opcode=jlr) then ALU2_muxf<='0'; 
	else ALU2_muxf<='1';
	end if;
end process forwarding_signals;

-------------------------------------------------------------------------------------

output_signals: process(carry,zero,valid2,cz_bits,eq_T1_T2,reset,IF_ID_Rs1,IF_ID_Rs2, ID_RR_Rs1,ID_RR_Rs2,
	ID_RR_valid2,ID_RR_RegWrite,ID_RR_Rd,ID_RR_opcode,
	RR_EX_RegWrite,RR_EX_Rd,RR_EX_opcode,
	EX_MEM_RegWrite,EX_MEM_Rd,EX_MEM_opcode,
	MEM_WB_RegWrite,MEM_WB_Rd,
	clk,
	IF_ID_opcode,FTB_signal,ALU1_muxf, ALU2_muxf, T1_muxf)
begin

IF_ID_en <= '1';


if(IF_ID_opcode=add) then
	PC_en <= '1';
	C_en <= '1';
	Z_en <= '1';
	RegWrite <= '1';
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=adc) then
	PC_en <= '1';
	C_en <= '1' and carry;
	Z_en <= '1' and carry;
	RegWrite <= '1' and carry;
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=adz) then
	PC_en <= '1';
	C_en <= '1' and zero;
	Z_en <= '1' and zero;
	RegWrite <= '1' and zero;
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;


if(IF_ID_opcode=adi) then
	PC_en <= '1';
	C_en <= '1';
	Z_en <= '1';
	RegWrite <= '1';
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "001";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "01";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=ndu) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '1';
	RegWrite <= '1';
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=ndc) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '1' and carry;
	RegWrite <= '1' and carry;
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=ndz) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '1' and zero;
	RegWrite <= '1' and zero;
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=adc) then
	PC_en <= '1';
	C_en <= '1' and carry;
	Z_en <= '1' and carry;
	RegWrite <= '1' and carry;
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';	
end if;

if(IF_ID_opcode=lhi) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "10";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=lw) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '1';
	RegWrite <= '1';
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "001";
	ALU1_muxs <= "111";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "01";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
	MemRead <='1';
	RegWrite_7 <= '1';	
end if;

if(IF_ID_opcode=sw) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "001";
	ALU1_muxs <= "111";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '1';
	MemRead <='0';
	RegWrite_7 <= '1';	
end if;



if(IF_ID_opcode=lm) then
	PC_en <= not valid2;
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "000";
	if (valid2='1') then IR_mux <= "01"; else IR_mux <= "00"; end if;
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "111";
	if (FTB_signal='0') then ALU1_muxs <= "001"; else ALU1_muxs <= "000"; end if;
	if (FTB_signal='0') then T1_muxs <= "001"; else T1_muxs <= "000"; end if;
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "01";
	Rf_a3_mux <= "11";
	MemWrite <= '0';
	MemRead <='1';
	RegWrite_7 <= '1';	
end if;


if(IF_ID_opcode=sm) then
	PC_en <= not valid2;
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	PC_mux <= "000";
	if (valid2='1') then IR_mux <= "01"; else IR_mux <= "00"; end if;
	BALU2_mux <= '0';
	Rf_a2_mux <= '1';
	ALU2_muxs <= "111";
	if (FTB_signal='0') then ALU1_muxs <= "001"; else ALU1_muxs <= "000"; end if;
	if (FTB_signal='0') then T1_muxs <= "001"; else T1_muxs <= "000"; end if;
	T2_muxs <= "000";
	mem_data_in_mux <= '1';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '1';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=beq) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	PC_mux <= "000"; 
	 IR_mux <= "00";
	BALU2_mux <= '1';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=jal) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "001";
	IR_mux <= "10";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "11";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';
end if;

if(IF_ID_opcode=jlr) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "010";
	IR_mux <= "10";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "11";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '1';	
end if;

if(IF_ID_opcode=nop or reset='1') then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	PC_mux <= "000";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_muxs <= "000";
	ALU1_muxs <= "000";
	T1_muxs <= "000";
	T2_muxs <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
	MemRead <='0';
	RegWrite_7 <= '0';
end if;

--Hazard conditions
--Make difference between ALU1 and T1

--Forwarding from WB stage
if ((EX_MEM_RegWrite='1') and (IF_ID_Rs1=EX_Mem_Rd)) then
	if(ALU1_muxf='0') then ALU1_muxs <= "110"; end if;
	if(T1_muxf='0') then T1_muxs <= "110"; end if;
end if;

if ((EX_MEM_RegWrite='1') and (IF_ID_Rs2=EX_Mem_Rd)) then
	if(ALU1_muxf='1') then ALU1_muxs <= "110"; end if;
	if(ALU2_muxf='0') then ALU2_muxs <= "110"; end if;
	 T2_muxs <= "110";
end if;

--Forwarding from MEM stage0
if ((RR_EX_RegWrite='1') and (IF_ID_Rs1=RR_EX_Rd)) then
	if(ALU1_muxf='0') then ALU1_muxs <= "101"; end if;
	if(T1_muxf='0') then T1_muxs <= "101"; end if;
end if;

if ((RR_EX_RegWrite='1') and (IF_ID_Rs2=RR_EX_Rd)) then
	if(ALU1_muxf='1') then ALU1_muxs <= "101"; end if;
	if(ALU2_muxf='0') then ALU2_muxs <= "101"; end if;
	T2_muxs <= "101";
end if;

--Forwarding from EX stage
if ((ID_RR_RegWrite='1') and (IF_ID_Rs1=ID_RR_Rd) and (ID_RR_opcode/=lw)) then
	if (ID_RR_opcode=jal or ID_RR_opcode=jlr) then 
		if(ALU1_muxf='0') then ALU1_muxs <= "010"; end if;
		if(T1_muxf='0') then T1_muxs <= "010"; end if;
	elsif (ID_RR_opcode=lhi) then 
		if(ALU1_muxf='0') then ALU1_muxs <= "011"; end if;
		if(T1_muxf='0') then T1_muxs <= "011"; end if;
	else
		if(ALU1_muxf='0') then ALU1_muxs <= "100"; end if;
		if(T1_muxf='0') then T1_muxs <= "100"; end if;
	end if;
end if;

if ((ID_RR_RegWrite='1') and (IF_ID_Rs2=ID_RR_Rd) and (ID_RR_opcode/=lw)) then
	if (ID_RR_opcode=jal or ID_RR_opcode=jlr) then        
		if(ALU1_muxf='1') then ALU1_muxs <= "010"; end if;
		 ALU2_muxs <= "010";
		 T2_muxs <= "010";
	elsif (ID_RR_opcode=lhi) then 
		if(ALU1_muxf='1') then ALU1_muxs <= "011"; end if;
		 ALU2_muxs <= "011";
		 T2_muxs <= "011";
	else
		if(ALU1_muxf='1') then ALU1_muxs <= "100"; end if;
		if(ALU2_muxf='0') then ALU2_muxs <= "100"; end if;
		 T2_muxs <= "100";
	end if;
end if;

if ((ID_RR_RegWrite='1') and (ID_RR_opcode=LW or (ID_RR_opcode=lm and ID_RR_VALID2='0'))) then
	if((IF_ID_Rs1=ID_RR_Rd and not(IF_ID_opcode=lhi or IF_ID_opcode=lw or IF_ID_opcode=jal or IF_ID_opcode=jlr))
		or (IF_ID_Rs2=ID_RR_Rd and not(IF_ID_opcode=adi or IF_ID_opcode=lhi or IF_ID_opcode=lm or IF_ID_opcode=jal
		or IF_ID_opcode=jlr))) then
		PC_en <= '0';
		IF_ID_en <= '0';
		RegWrite <= '0';
		MemWrite <= '0';
		C_en <= '0';
		Z_en <= '0';
		RegWrite_7 <= '0';
	end if;
end if;


if(IF_ID_opcode = JLR) then IR_mux <= "10"; end if;

if(ID_RR_opcode = JLR) then 
	IR_mux <= "10";
	PC_mux <= "010";
end if;

if((ID_RR_opcode = BEQ) and (eq_T1_T2 = '1')) then 
	RegWrite <= '0';
	MemWrite <='0';
	C_en <='0';
	Z_en <='0';
	RegWrite_7 <='0';
	PC_en <= '1';
	IR_mux <= "10";
	PC_mux <= "110";
end if;

--r7 one
if((ID_RR_Rd_in = "111") and (RegWrite = '1')) then
	IR_mux <= "10";
	if(IF_ID_opcode = LHI) then
		PC_mux <= "011";
	end if;
end if;

if((ID_RR_Rd = "111") and (ID_RR_RegWrite = '1')) then
	if not((ID_RR_opcode = LHI) or (ID_RR_opcode = JAL)) then
		IR_mux <= "10";
	end if;
end if;

if((RR_EX_Rd = "111") and (RR_EX_RegWrite = '1')) then
	if not(RR_EX_opcode = JLR) then
		IR_mux <= "10";
	end if;
	if (RR_EX_opcode = ADD or RR_EX_opcode = ADC or RR_EX_opcode = ADZ or RR_EX_opcode = ADI or RR_EX_opcode = NDU or RR_EX_opcode = NDC or RR_EX_opcode = NDZ)
		then
		PC_mux <= "100";
	end if;	
end if;

if((EX_Mem_Rd = "111") and (EX_MEM_RegWrite = '1')) then
	if not(EX_MEM_opcode = ADD or EX_MEM_opcode = ADC or EX_MEM_opcode = ADZ or EX_MEM_opcode = ADI or EX_MEM_opcode = NDU or EX_MEM_opcode = NDC or EX_MEM_opcode = NDZ)
		then
		IR_mux <= "10";
	end if;	

	if(EX_MEM_opcode = lw or EX_MEM_opcode = lm )
		then
		PC_mux <= "101";
	end if;
end if;



-----stalling for R7 register 
--if((RegWrite = '1') and (ID_EX_Rd_in='111')) then
--	PC_en <= '0';
--	IR_mux <= '10';
--end if;

--if((ID_EX_RegWrite = '1') and (ID_EX_Rd='111')) then
--	PC_en <= '0';
--	IR_mux <= '10';
--end if;

--if((EX_MEM_RegWrite = '1') and (EX_MEM_Rd='111')) then
--	PC_en <= '0';
--	IR_mux <= '10';
--	PC_mux<='10';
--end if;

end process output_signals;

T1_mux <= T1_muxs;
T2_mux <= T2_muxs;
ALU1_mux <= ALU1_muxs;
ALU2_mux <= ALU2_muxs;
FTB <= FTB_signal;
RegWrite_out <= RegWrite;
end behave;
