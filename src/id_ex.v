module id_ex(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire[`AluOpBus] id_aluop,
	input wire[`AluSelBus] id_alusel,
	input wire[`RegBus] id_reg1,
	input wire[`RegBus] id_reg2,
	input wire[`RegAddrBus] id_wd,
	input wire id_wreg,
	
	inout wire[`InstAddrBus] id_pc,
	input wire[`InstAddrBus] offset_i,
	input wire jmp_i,
	output reg jmp_o,
	
	input ex_pre_fail,
	
	
	input wire[`StallBus] stall_stmt,
	
	output reg[`AluOpBus] ex_aluop,
	output reg[`AluSelBus] ex_alusel,
	output reg[`RegBus] ex_reg1,
	output reg[`RegBus] ex_reg2,
	output reg[`RegAddrBus] ex_wd,
	output reg ex_wreg,
	output reg[`InstAddrBus] ex_pc,
	output reg[`InstAddrBus] offset_o
	);
	
always @(posedge clk) begin
	if(rst==`RstEnable) begin
		ex_aluop<=`EXE_NOP_OP;
		ex_alusel<=`EXE_SEL_NOP;
		ex_reg1<=`ZeroWord;
		ex_reg2<=`ZeroWord;
		ex_wd<=`NOPRegAddr;
		ex_wreg<=`WriteDisable;
		ex_pc<=`ZeroWord;
		offset_o<=`ZeroWord;
		jmp_o<=1'b0;
	end
	else if(~rdy) begin
	end
	else if(stall_stmt[3]==`Stop) begin
	end
	else if(ex_pre_fail) begin
		ex_aluop<=`EXE_NOP_OP;
		ex_alusel<=`EXE_SEL_NOP;
		ex_reg1<=`ZeroWord;
		ex_reg2<=`ZeroWord;
		ex_wd<=`NOPRegAddr;
		ex_wreg<=`WriteDisable;
		ex_pc<=`ZeroWord;
		offset_o<=`ZeroWord;
		jmp_o<=1'b0;
	end
	else if(stall_stmt[2]==`NoStop) begin
		ex_aluop<=id_aluop;
		ex_alusel<=id_alusel;
		ex_reg1<=id_reg1;
		ex_reg2<=id_reg2;
		ex_wd<=id_wd;
		ex_wreg<=id_wreg;
		ex_pc<=id_pc;
		offset_o<=offset_i;
		jmp_o<=jmp_i;
	end
	else begin
		ex_aluop<=`EXE_NOP_OP;
		ex_alusel<=`EXE_SEL_NOP;
		ex_reg1<=`ZeroWord;
		ex_reg2<=`ZeroWord;
		ex_wd<=`NOPRegAddr;
		ex_wreg<=`WriteDisable;
		ex_pc<=`ZeroWord;
		offset_o<=`ZeroWord;
		jmp_o<=1'b0;
	end
end
	
endmodule