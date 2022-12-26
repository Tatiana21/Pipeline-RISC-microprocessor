library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsRISC.all;
--------------------------------------------------

entity combined is 
	port ( 
		clk : in std_logic;
		reset: in std_logic);
end entity;

architecture behave of combined is
	signal RF_a2_in,PE_out,
			ID_RR_Rd_in, 
			ID_RR_PE_out, ID_RR_ALU1_mux_out,ID_RR_ALU2_mux_out,ID_RR_T1_mux_out,ID_RR_T2_mux_out, ID_RR_RF_a2_out, ID_RR_RD_out,
			RR_EX_Rd_in,
			RR_EX_RD_out,
			EX_MEM_RD_out,
			MEM_WB_RD_out,
			ALU2_mux,ALU1_mux,T1_mux,T2_mux,PC_mux
			: std_logic_vector(2 downto 0) :="000";
	signal Rf_d3_mux,
			ID_RR_Rf_d3_mux_out,ID_RR_RF_a3_mux_out,
			RR_EX_Rf_d3_mux_out,
			EX_MEM_Rf_d3_mux_out,
			IR_mux,Rf_a3_mux: std_logic_vector(1 downto 0):="00";
	signal carry_ALU_out,zero_ALU_out,valid2_signal,
			IF_ID_PC_o_en,
			ID_RR_valid2_out,ID_RR_RegWrite_out,ID_RR_RegWrite_7_out,ID_RR_C_en_out,ID_RR_Z_en_out,ID_RR_mem_mux_out,ID_RR_MemWrite_out,ID_RR_MemRead_out,ID_RR_RF_a2_mux_out,ID_RR_FTB_out,
			RR_EX_valid2_out,RR_EX_RegWrite_out,RR_EX_RegWrite_7_out,RR_EX_C_en_out,RR_EX_Z_en_out,RR_EX_mem_mux_out,RR_EX_MemWrite_out,RR_EX_MemRead_out,
			EX_MEM_RegWrite_out,EX_MEM_RegWrite_7_out,EX_MEM_mem_mux_out,EX_MEM_MemWrite_out,EX_MEM_MemRead_out,EX_MEM_C_en_out,EX_MEM_Z_en_out,
			MEM_WB_RegWrite_out,MEM_WB_RegWrite_7_out, MEM_WB_carry_out,MEM_WB_zero_out,MEM_WB_C_en_out,MEM_WB_Z_en_out,
			C_en,Z_en,PC_en,IF_ID_en,FTB,DMEM_add_in_muxs,
			mem_data_in_mux,MemWrite,MemRead,RegWrite,RegWrite_7,BALU2_mux,Rf_a2_mux, RF_d4_mux_signal,
			Dummy_carry_out,ID_RR_C_en_out_mod,ID_RR_Z_en_out_mod,ID_RR_RegWrite_out_mod,C_en_mod,Z_en_mod,RegWrite_mod: std_logic:='0';
	signal  Palu_out,PC_in,PC_out,Palu_in,Imem_data_out,
			IF_ID_PC_out,IF_ID_IR_out,IF_ID_IR_in,IF_ID_PC_o_out,
			ID_RR_IR_out,ID_RR_PC_out,ID_RR_PC_o_out,ID_RR_Balu_out,
			RR_EX_ALU1_in,RR_EX_ALU2_in,RR_EX_T1_in,RR_EX_T2_in,
			RR_EX_ALU1_out,RR_EX_ALU2_out,RR_EX_T1_out,RR_EX_T2_out, RR_EX_IR_out,RR_EX_PC_out,RR_EX_PC_o_out,
			Balu_out,Balu2_mux_out,
			SE10_out,SE7_out,LS7_out,ALU2_mux_IN7,RR_SE10_out, ID_LS7_out,
			RF_d2_out,RF_d1_out,RF_d3_in,RF_d4_out,
			ALU_out,EX_LS7_out,DMem_add_in,
			DMEM_Data_in,DMEM_Data_out,
			EX_MEM_ALUout,EX_MEM_IR_out,EX_MEM_PC_out,EX_MEM_T1_out,EX_MEM_T2_out,EX_MEM_PC_o_out,
			Mem_WB_RF_D3_in,Mem_WB_RF_D3_out,Mem_WB_PC_o_out,
			MEM_WB_IR_out,Dec_out,
			RF_d1_out_mux_in,RF_d2_out_mux_in
			: std_logic_vector(15 downto 0):="0000000000000000";
	signal MemWrite_bar,MemRead_bar: std_logic:='1';

	signal carry,zero,eq_T1_T2_signal,EX_MEM_carry_out,EX_MEM_zero_out: std_logic:='0';
	signal IF_ID_Rs1,IF_ID_Rs2,ID_RR_Rs1,ID_RR_Rs2: std_logic_vector(2 downto 0):="000";

	component control_pipe is
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
	end component;
	
begin
	----------------------------IF----------------------------------------
		PC_mux_comp: mux8_16
		port map(
			IN7=>"0000000000000000",
			IN6=> ID_RR_Balu_out,
			IN5=> Mem_WB_RF_D3_in,
			IN4=> ALU_out,
			IN3=> ID_LS7_out,
			IN2=> RF_d2_out,
			IN1=> Balu_out,
			IN0=> Palu_out, 
			s=> PC_mux,
			OUTPUT=> PC_in);

		PC: dregister
		port map(
			DIN=>PC_in,
			clk=> clk,
			reset=> reset,
			en=>PC_en,
			DOUT=>PC_out);
		
		Palu: alu_adder
		port map(
			D1=>PC_out,
			D2=>"0000000000000001",
			OUTPUT=> Palu_out);

		IMEM: I_memory   
	    generic map (data_width=> 16, addr_width=> 16)
	    port map(
	    	din=> PC_out,
	        dout=> Imem_data_out,
	        rbar=> '0',
	        wbar=> '1',
	        addrin=> PC_out );

	    IR_mux_comp: mux4_16
		port map(
			IN3=> "0000000000000000",
			IN2=> "1111000000000000",
			IN1=> Dec_out,
			IN0=> Imem_data_out, 
			s=> IR_mux,
			OUTPUT=> IF_ID_IR_in);

	----------------------------IF/ID-------------------------------------
		IF_ID_IR: dregister_IF_ID_IR
		port map(
			DIN=>IF_ID_IR_in,
			clk=> clk,
			reset=> reset,
			en=> IF_ID_en,
			DOUT=>IF_ID_IR_out);

		IF_ID_PCplus1: dregister
		port map(
			DIN=>Palu_out,
			clk=> clk,
			reset=> reset,
			en=>IF_ID_en,
			DOUT=>IF_ID_PC_out);

		IF_ID_PC_o_en <= '0' when ((IF_ID_IR_out(15 downto 12)="0110" or IF_ID_IR_out(15 downto 12)="0111") and valid2_signal='1') else IF_ID_en; 

		IF_ID_PC_original: dregister
		port map(
			DIN=>PC_out,
			clk=> clk,
			reset=> reset,
			en=>IF_ID_PC_o_en,
			DOUT=>IF_ID_PC_o_out);

	------------------------------ID--------------------------------------

		PE: priority   
		port map (
			INPUT=>IF_ID_IR_out(8 downto 0), 
			output=> PE_out,
			valid2=> valid2_signal);

		IR_dec: ir_decoder 
		port map (
			s=> PE_out,
			IR=> IF_ID_IR_out, 
			new_IR=> Dec_out);

		SE7: SgnExtd7
		port map(
			IN1 => IF_ID_IR_out(8 downto 0),
			OUTPUT1 => SE7_out);
		
		SE10: SgnExtd10
		port map(
			IN1 => IF_ID_IR_out(5 downto 0),
			OUTPUT1 => SE10_out);
		
		Balu2_mux_comp: mux2_16 
		port map (
			IN1=> SE10_out,
			IN0=> SE7_out, 
			s=> Balu2_mux,
			OUTPUT=> Balu2_mux_out);

		Balu: alu_adder
		port map(
			D1=>IF_ID_PC_o_out,
			D2=>Balu2_mux_out,
			OUTPUT=> Balu_out);

		RF_a2_mux_comp: mux2_3  
		port map (
			IN1=> PE_out,
			IN0=> IF_ID_IR_out(8 downto 6), 
			s=> RF_a2_mux,
			OUTPUT=> RF_a2_in);

		RF_a3_mux_comp: mux4_3
		port map(
			IN3=> PE_out,
			IN2=> IF_ID_IR_out(11 downto 9),
			IN1=> IF_ID_IR_out(8 downto 6),
			IN0=> IF_ID_IR_out(5 downto 3), 
			s=> RF_a3_mux,
			OUTPUT=> ID_RR_Rd_in);

		ID_LS7: LeftShift
		port map(
			IN1 => IF_ID_IR_out(8 downto 0),
			OUTPUT1 => ID_LS7_out);

	-----------------------------ID/RR------------------------------------

		ID_RR_IR: dregister
		port map(
			DIN=>IF_ID_IR_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>ID_RR_IR_out);

		ID_RR_PE: dflipflop_3
		port map(
			DIN=>PE_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>ID_RR_PE_out);

		ID_RR_PC: dregister
		port map(
			DIN=>IF_ID_PC_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>ID_RR_PC_out);

		ID_RR_PC_o: dregister
		port map(
			DIN=>IF_ID_PC_o_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>ID_RR_PC_o_out);

		ID_RR_Balu: dregister
		port map(
			DIN=>Balu_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>ID_RR_Balu_out);

		ID_RR_RF_a2: dflipflop_3
		port map(
			DIN=> RF_a2_in,
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_RF_a2_out);

		ID_RR_Rd: dflipflop_3
		port map(
			DIN=> ID_RR_Rd_in, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_RD_out);

		ID_RR_ALU1_mux: dflipflop_3
		port map(
			DIN=> ALU1_mux, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_ALU1_mux_out);

		ID_RR_ALU2_mux: dflipflop_3
		port map(
			DIN=> ALU2_mux, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_ALU2_mux_out);

		ID_RR_T1_mux: dflipflop_3
		port map(
			DIN=> T1_mux, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_T1_mux_out);

		ID_RR_T2_mux: dflipflop_3
		port map(
			DIN=> T2_mux, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_T2_mux_out);

		--Carry_en_process_IF_ID: process (RR_EX_C_en_out,IF_ID_IR_out,carry_ALU_out)
		--begin
		--if ((RR_EX_C_en_out = '1') and (IF_ID_IR_out(15 downto 12)="0000") and (IF_ID_IR_out(1 downto 0)="10") and (carry_ALU_out='0')) then C_en_mod <= '0' ;
		--	elsif ((RR_EX_C_en_out = '1') and (IF_ID_IR_out(15 downto 12)="0000") and (IF_ID_IR_out(1 downto 0)="10") and (carry_ALU_out='1')) then C_en_mod <= '1' ;
		--	else C_en_mod <= C_en;
		--end if;
		--if (RR_EX_C_en_out = '1' and IF_ID_IR_out(15 downto 12)="0000" and IF_ID_IR_out(1 downto 0)="10" and carry_ALU_out='0') then Z_en_mod <= '0';
		--	elsif (RR_EX_C_en_out = '1' and IF_ID_IR_out(15 downto 12)="0000" and IF_ID_IR_out(1 downto 0)="10" and carry_ALU_out='1') then Z_en_mod <= '1' ;
		--	else Z_en_mod <=Z_en;
		--end if;
		--if  (RR_EX_C_en_out = '1' and IF_ID_IR_out(15 downto 12)="0000" and IF_ID_IR_out(1 downto 0)="10" and carry_ALU_out='0') then RegWrite_mod <= '0';
		--	elsif (RR_EX_C_en_out = '1' and IF_ID_IR_out(15 downto 12)="0000" and IF_ID_IR_out(1 downto 0)="10" and carry_ALU_out='1') then RegWrite_mod <= '1' ;
		--	else RegWrite_mod <=RegWrite;
		--end if;
		--end process;

		ID_RR_C_en: dflipflop
		port map(
			DIN=> C_en, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_C_en_out);

		ID_RR_Z_en: dflipflop
		port map(
			DIN=> Z_en, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_Z_en_out);

		ID_RR_RegWrite: dflipflop
		port map(
			DIN=> RegWrite, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_RegWrite_out);

		ID_RR_RegWrite_7: dflipflop
		port map(
			DIN=> RegWrite_7, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_RegWrite_7_out);

		ID_RR_MemWrite: dflipflop
		port map(
			DIN=> MemWrite, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_MemWrite_out);

		ID_RR_MemRead: dflipflop
		port map(
			DIN=> MemRead,
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_MemRead_out);

		ID_RR_mem_data_in_mux: dflipflop
		port map(
			DIN=> mem_data_in_mux, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_mem_mux_out);

		ID_RR_FTB_flop: dflipflop
		port map(
			DIN=> FTB,
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_FTB_out);

		ID_RR_valid2_flop: dflipflop
		port map(
			DIN=> valid2_signal, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_valid2_out);

		ID_RR_Rf_d3_mux_flop: dflipflop_2
		port map(
			DIN=> Rf_d3_mux, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> ID_RR_Rf_d3_mux_out);

	-------------------------------RR-------------------------------------

		RF: register_file  
		port map (
			a1=> ID_RR_IR_out(11 downto 9),   --a2 a1 to read the data
			a2=> ID_RR_RF_a2_out,
			a3=> MEM_WB_RD_out,   --a3 is the address where data to be written 
			d3=> Mem_WB_RF_D3_out,      -- d3 is the daata to write 
			d4=> RF_d4_out,
			wr=> MEM_WB_RegWrite_out,
			wr_7 => MEM_WB_RegWrite_7_out, 
			d1=> RF_d1_out_mux_in,
			d2=> RF_d2_out_mux_in,
			reset=> reset,
			clk=> clk);

		RF_d1_out<=RF_d1_out_mux_in when ID_RR_Rs1 /= "111" else ID_RR_PC_o_out;
		RF_d2_out<=RF_d2_out_mux_in when ID_RR_Rs2 /= "111" else ID_RR_PC_o_out;

		eq_T1_T2_signal <= '1' when RR_EX_T2_in = RR_EX_T1_in else '0';

		ALU_1_mux_comp: mux8_16 
		port map (
			IN7=> RF_d2_out,
			IN6=> Mem_WB_RF_D3_out,
			IN5=> Mem_WB_RF_D3_in,
			IN4=> ALU_out,
			IN3=> EX_LS7_out,
			IN2=> RR_EX_PC_out,
			IN1=> ALU_out,
			IN0=> RF_d1_out, 
			s=> ID_RR_ALU1_mux_out,
			OUTPUT=> RR_EX_ALU1_in);

		T1_mux_comp: mux8_16 
		port map (
			IN7=> "0000000000000000",
			IN6=> Mem_WB_RF_D3_out,
			IN5=> Mem_WB_RF_D3_in,
			IN4=> ALU_out,
			IN3=> EX_LS7_out,
			IN2=> RR_EX_PC_out,
			IN1=> ALU_out,
			IN0=> RF_d1_out, 
			s=> ID_RR_T1_mux_out,
			OUTPUT=> RR_EX_T1_in);

		ALU2_mux_IN7_mux: mux2_16
		port map (
			IN1 => "0000000000000000",
			IN0 => "0000000000000001",
			s=> ID_RR_FTB_out,
			OUTPUT=> ALU2_mux_IN7);

		RR_SE10: SgnExtd10
		port map(
			IN1 => ID_RR_IR_out(5 downto 0),
			OUTPUT1 => RR_SE10_out);

		ALU_2_mux_comp: mux8_16 
		port map (
			IN7=> ALU2_mux_IN7,
			IN6=> Mem_WB_RF_D3_out,
			IN5=> Mem_WB_RF_D3_in,
			IN4=> ALU_out,
			IN3=> EX_LS7_out,
			IN2=> RR_EX_PC_out,
			IN1=> RR_SE10_out,
			IN0=> RF_d2_out, 
			s=> ID_RR_ALU2_mux_out,
			OUTPUT=> RR_EX_ALU2_in);

		T2_mux_comp: mux8_16 
		port map (
			IN7=> "0000000000000000",
			IN6=> Mem_WB_RF_D3_out,
			IN5=> Mem_WB_RF_D3_in,
			IN4=> ALU_out,
			IN3=> EX_LS7_out,
			IN2=> RR_EX_PC_out,
			IN1=> "0000000000000000",
			IN0=> RF_d2_out,
			s=> ID_RR_T2_mux_out,
			OUTPUT=> RR_EX_T2_in);
	
	------------------------------RR/EX-----------------------------------
		RR_EX_IR: dregister
		port map(
			DIN=>ID_RR_IR_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_IR_out);

		RR_EX_PC: dregister
		port map(
			DIN=>ID_RR_PC_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_PC_out);

		RR_EX_PC_o: dregister
		port map(
			DIN=>ID_RR_PC_o_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_PC_o_out);

		RR_EX_ALU1: dregister
		port map(
			DIN=>RR_EX_ALU1_in,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_ALU1_out);

		RR_EX_ALU2: dregister
		port map(
			DIN=>RR_EX_ALU2_in,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_ALU2_out);

		RR_EX_T1: dregister
		port map(
			DIN=>RR_EX_T1_in,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_T1_out);

		RR_EX_T2: dregister
		port map(
			DIN=>RR_EX_T2_in,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_T2_out);

		--RR_EX_valid2_flop: dflipflop
		--port map(
		--	DIN=> ID_RR_valid2_out, 
		--	clk=> clk,
		--	reset=> reset,
		--	en=> '1',
		--	DOUT=> RR_EX_valid2_out);
		--Carry_en_process_ID_RR: process (RR_EX_C_en_out,ID_RR_IR_out,carry_ALU_out)
		--begin
		--if (RR_EX_C_en_out = '1' and ID_RR_IR_out(15 downto 12)="0000" and ID_RR_IR_out(1 downto 0)="10" and carry_ALU_out='0') then ID_RR_C_en_out_mod <= '0';
		--	elsif (RR_EX_C_en_out = '1' and ID_RR_IR_out(15 downto 12)="0000" and ID_RR_IR_out(1 downto 0)="10" and carry_ALU_out='1') then ID_RR_C_en_out_mod <= '1';
		--	else  ID_RR_C_en_out_mod <=ID_RR_C_en_out;
		--end if;

		--if  (RR_EX_C_en_out = '1' and ID_RR_IR_out(15 downto 12)="0000" and ID_RR_IR_out(1 downto 0)="10" and carry_ALU_out='0') then ID_RR_Z_en_out_mod <= '0';
		--	elsif (RR_EX_C_en_out = '1' and ID_RR_IR_out(15 downto 12)="0000" and ID_RR_IR_out(1 downto 0)="10" and carry_ALU_out='1') then ID_RR_Z_en_out_mod <= '1';
		--	else ID_RR_Z_en_out_mod <=ID_RR_Z_en_out;
		--end if;

		--if (RR_EX_C_en_out = '1' and ID_RR_IR_out(15 downto 12)="0000" and ID_RR_IR_out(1 downto 0)="10" and carry_ALU_out='0') then ID_RR_RegWrite_out_mod <= '0';
		--	elsif (RR_EX_C_en_out = '1' and ID_RR_IR_out(15 downto 12)="0000" and ID_RR_IR_out(1 downto 0)="10" and carry_ALU_out='1') then ID_RR_RegWrite_out_mod <= '1';
		--	else ID_RR_RegWrite_out_mod <= ID_RR_RegWrite_out;
		--end if;
		--end process;
			
		RR_EX_C_en_flop: dflipflop
		port map(
			DIN=> ID_RR_C_en_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_C_en_out);

		RR_EX_Z_en_flop: dflipflop
		port map(
			DIN=> ID_RR_Z_en_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_Z_en_out);

		RR_EX_RegWrite_flop: dflipflop
		port map(
			DIN=> ID_RR_RegWrite_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_RegWrite_out);

		RR_EX_RegWrite_7_flop: dflipflop
		port map(
			DIN=> ID_RR_RegWrite_7_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_RegWrite_7_out);

		--mem data mux
		RR_EX_mem_mux_flop: dflipflop
		port map(
			DIN=> ID_RR_mem_mux_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_mem_mux_out);

		RR_EX_MemWrite_flop: dflipflop
		port map(
			DIN=> ID_RR_MemWrite_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_MemWrite_out);

		RR_EX_MemRead_flop: dflipflop
		port map(
			DIN=> ID_RR_MemRead_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_MemRead_out);

		RR_EX_Rf_d3_mux_flop: dflipflop_2
		port map(
			DIN=> ID_RR_Rf_d3_mux_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> RR_EX_Rf_d3_mux_out);

		RR_EX_RD_flop: dflipflop_3
		port map(
			DIN=> ID_RR_RD_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>RR_EX_RD_out);
	
	------------------------------EX--------------------------------------

		ALU_main: alu   
		port map( 
			X=> RR_EX_ALU1_out,
			Y=> RR_EX_ALU2_out,
			op_code_bits => RR_EX_IR_out(15 downto 12),                 -- write opcode, ALU to be modified
			OUTPUT_ALU=> ALU_out,
			cz_bits=> RR_EX_IR_out(1 downto 0), 
			carry_ALU =>carry_ALU_out,
			zero_ALU=>zero_ALU_out);

		LS7_2:  LeftShift
		port map(
			IN1 => RR_EX_IR_out(8 downto 0),
			OUTPUT1 => EX_LS7_out);

		Dummy_carry_flop: dflipflop
		port map(
			DIN=>carry_ALU_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>Dummy_carry_out);

	-----------------------------------EX/MEM-----------------------------
		EX_MEM_IR: dregister
		port map(
			DIN=>RR_EX_IR_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_IR_out);

		EX_MEM_PC: dregister
		port map(
			DIN=>RR_EX_PC_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_PC_out);

		EX_MEM_PC_o: dregister
		port map(
			DIN=>RR_EX_PC_o_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_PC_o_out);

		EX_MEM_ALUout_reg: dregister
		port map(
			DIN=>ALU_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_ALUout);

		EX_MEM_T1: dregister
		port map(
			DIN=>RR_EX_T1_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_T1_out);

		EX_MEM_T2: dregister
		port map(
			DIN=>RR_EX_T2_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_T2_out);

		EX_MEM_carry_flop: dflipflop
		port map(
			DIN=>carry_ALU_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_carry_out);

		EX_MEM_zero_flop: dflipflop
		port map(
			DIN=>zero_ALU_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_zero_out);

		EX_MEM_C_en_flop: dflipflop
		port map(
			DIN=> RR_EX_C_en_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_C_en_out);

		EX_MEM_Z_en_flop: dflipflop
		port map(
			DIN=> RR_EX_Z_en_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_Z_en_out);

		EX_MEM_RegWrite_flop: dflipflop
		port map(
			DIN=> RR_EX_RegWrite_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_RegWrite_out);

		EX_MEM_RegWrite_7_flop: dflipflop
		port map(
			DIN=> RR_EX_RegWrite_7_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_RegWrite_7_out);

		EX_MEM_RD_flop: dflipflop_3
		port map(
			DIN=>RR_EX_RD_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>EX_MEM_RD_out);

		Ex_Mem_mem_mux_flop: dflipflop
		port map(
			DIN=> RR_EX_mem_mux_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_mem_mux_out);

		Ex_Mem_MemWrite_flop: dflipflop
		port map(
			DIN=> RR_EX_MemWrite_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_MemWrite_out);

		Ex_Mem_MemRead_flop: dflipflop
		port map(
			DIN=> RR_EX_MemRead_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_MemRead_out);

		EX_Mem_Rf_d3_mux_flop: dflipflop_2
		port map(
			DIN=> RR_EX_Rf_d3_mux_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> EX_MEM_Rf_d3_mux_out);
	
	------------------------------------------------Mem-------------------

		DMEM_Din_mux: mux2_16 
		port map (
			IN1=> EX_MEM_T2_out,
			IN0=> EX_MEM_T1_out, 
			s=> EX_MEM_mem_mux_out,
			OUTPUT=> DMEM_Data_in);

		MemWrite_bar<= (not EX_MEM_MemWrite_out);
		MemRead_bar<= (not EX_MEM_MemRead_out);

		DMEM_add_in_muxs <= '1' when (EX_MEM_MemRead_out='1' or EX_MEM_MemWrite_out='1') else '0';

		DMEM_Ain_mux: mux2_16 
		port map (
			IN1=> EX_MEM_ALUout,
			IN0=> "0000000000000000", 
			s=> DMEM_add_in_muxs,
			OUTPUT=> DMEM_add_in);	

		DMEM: D_memory   
	    generic map (data_width=> 16, addr_width=> 16)
	    port map(
	    	din=> DMEM_Data_in,
	        dout=> DMEM_Data_out,
	        rbar=> MemRead_bar,
	        wbar=> MemWrite_bar,
	        addrin=> DMEM_add_in);

	    LS7: LeftShift
		port map(
			IN1 => EX_MEM_IR_out(8 downto 0),
			OUTPUT1 => LS7_out);

	    RF_d3_mux_comp: mux4_16
		port map(
			IN3=> EX_MEM_PC_out,
			IN2=> LS7_out,
			IN1=> DMEM_Data_out,
			IN0=> EX_MEM_ALUout, 
			s=> EX_MEM_Rf_d3_mux_out,
			OUTPUT=> Mem_WB_RF_D3_in);

	--------------------------------MEM/WB--------------------------------
		Mem_WB_RF_D3: dregister
		port map(
			DIN=>Mem_WB_RF_D3_in,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>Mem_WB_RF_D3_out);

		Mem_WB_PC_o: dregister
		port map(
			DIN=>EX_MEM_PC_o_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>Mem_WB_PC_o_out);

		MEM_WB_carry_flop: dflipflop
		port map(
			DIN=>EX_MEM_carry_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>MEM_WB_carry_out);

		MEM_WB_zero_flop: dflipflop
		port map(
			DIN=>EX_MEM_zero_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>MEM_WB_zero_out);

		MEM_WB_RD_flop: dflipflop_3
		port map(
			DIN=>EX_MEM_RD_out,
			clk=> clk,
			reset=> reset,
			en=>'1',
			DOUT=>MEM_WB_RD_out);

		MEM_WB_C_en_flop: dflipflop
		port map(
			DIN=> EX_MEM_C_en_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> MEM_WB_C_en_out);

		MEM_WB_Z_en_flop: dflipflop
		port map(
			DIN=> EX_MEM_Z_en_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> MEM_WB_Z_en_out);

		MEM_WB_RegWrite_flop: dflipflop
		port map(
			DIN=> EX_MEM_RegWrite_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> MEM_WB_RegWrite_out);

		MEM_WB_RegWrite_7_flop: dflipflop
		port map(
			DIN=> EX_MEM_RegWrite_7_out, 
			clk=> clk,
			reset=> reset,
			en=> '1',
			DOUT=> MEM_WB_RegWrite_7_out);
	
	---------------------------------WB-----------------------------------
		C: dflipflop  
		port map (DIN=> MEM_WB_carry_out, 
			  clk=> clk,
			  reset=> reset,
			  en=> MEM_WB_C_en_out,
			  DOUT=> carry);
			  
		Z: dflipflop  
		port map (DIN=> MEM_WB_zero_out, 
			  clk=> clk,
			  reset=> reset,
			  en=> MEM_WB_Z_en_out,
			  DOUT=> zero);

		RF_d4_mux_signal <= '1' when MEM_WB_RD_out = "111" else '0';

		PC_o_mux_comp: mux2_16
		port map(
			IN1=> Mem_WB_RF_D3_out,
			IN0=> Mem_WB_PC_o_out,
			s=> RF_d4_mux_signal,
			OUTPUT=> RF_d4_out);

	---------------------------------------------------------------------
	control: control_pipe
	port map(
	clk => clk,
	carry => Dummy_carry_out,
	zero => zero,
	valid2 => valid2_signal,
	IF_ID_opcode_bits => IF_ID_IR_out(15 downto 12),
	cz_bits => IF_ID_IR_out(1 downto 0),
	eq_T1_T2 => eq_T1_T2_signal,
	reset => reset,
	IF_ID_Rs1 => IF_ID_Rs1,
	IF_ID_Rs2 => IF_ID_Rs2,
	ID_RR_Rs1 => ID_RR_Rs1,
	ID_RR_Rs2 => ID_RR_Rs2,

	ID_RR_opcode_bits => ID_RR_IR_out(15 downto 12),
	ID_RR_valid2 => ID_RR_valid2_out,
	ID_RR_RegWrite => ID_RR_RegWrite_out,
	ID_RR_Rd => ID_RR_Rd_out,
	ID_RR_Rd_in => ID_RR_Rd_in,

	
	RR_EX_opcode_bits => RR_EX_IR_out(15 downto 12),
	RR_EX_RegWrite => RR_EX_RegWrite_out,
	RR_EX_Rd => RR_EX_Rd_out,
	
	EX_MEM_opcode_bits => EX_MEM_IR_out(15 downto 12),
	EX_MEM_RegWrite => EX_MEM_RegWrite_out,
	EX_MEM_Rd => EX_MEM_Rd_out,
	MEM_WB_RegWrite => MEM_WB_RegWrite_out,
	MEM_WB_Rd => MEM_WB_Rd_out,

	PC_en => PC_en,
	IF_ID_en => IF_ID_en,
	C_en => C_en,
	Z_en => Z_en,
	RegWrite_out => RegWrite,
	RegWrite_7 => RegWrite_7,
	PC_mux => PC_mux,
	IR_mux => IR_mux,
	BALU2_mux => Balu2_mux,
	Rf_a2_mux => Rf_a2_mux,
	ALU2_mux => ALU2_mux,
	ALU1_mux => ALU1_mux,
	T1_mux => T1_mux,
	T2_mux => T2_mux,
	mem_data_in_mux => mem_data_in_mux,
	Rf_d3_mux => Rf_d3_mux,
	Rf_a3_mux => Rf_a3_mux,
	MemWrite => MemWrite,
	MemRead => MemRead,
	FTB => FTB);


	IF_ID_Rs1 <= IF_ID_IR_out(11 downto 9);
	IF_ID_Rs2 <= RF_a2_in;
	ID_RR_Rs1 <= ID_RR_IR_out(11 downto 9);
	ID_RR_Rs2 <= ID_RR_RF_a2_out;
end behave;
