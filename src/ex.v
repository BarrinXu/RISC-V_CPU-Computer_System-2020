module ex(
	input wire rst,
	input wire rdy,
	input wire[`AluOpBus] aluop_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	
	input wire[`InstAddrBus] pc_i,
	input wire jmp_i,
	input wire[`RegBus] offset_i,
	
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,
	
	
	output reg[`RegBus] mem_addr_o,
	output reg loading,
	output reg storing,
	output reg[2:0] mem_length,
	output reg mem_signed,
	
	output reg pre_fail,
	output reg[`InstAddrBus] branch_target,
	output reg jmp_type,
	output reg[`InstAddrBus] jmp_target,
	output reg jmp_o
	
	);
	
reg[`RegBus] logicout;
reg[`RegBus] shiftout;
reg[`RegBus] arithout;

wire[`InstAddrBus] tmp;//for jalr
assign tmp=reg1_i+reg2_i;

always @(*) begin
	pre_fail=1'b0;
	branch_target=`ZeroWord;
	jmp_type=1'b0;
	jmp_target=pc_i+offset_i;
	jmp_o=1'b0;
	if(rst!=`RstEnable&&rdy) begin
		case(aluop_i)
			`EXE_JAL_OP: begin
				branch_target=pc_i+offset_i;
				jmp_type=1'b1;
				pre_fail=!jmp_i;
				jmp_o=1'b1;
			end
			`EXE_JALR_OP: begin
				branch_target={tmp[31:1],1'b0};
				pre_fail=1'b1;
			end
			`EXE_BEQ_OP: begin
				jmp_type=1'b1;
				if(reg1_i==reg2_i) begin
					branch_target=pc_i+offset_i;
					pre_fail=!jmp_i;
					jmp_o=1'b1;
				end
				else begin
					branch_target=pc_i+4;
					pre_fail=jmp_i;
				end
			end
			`EXE_BNE_OP: begin
				jmp_type=1'b1;
				if(reg1_i!=reg2_i) begin
					branch_target=pc_i+offset_i;
					pre_fail=!jmp_i;
					jmp_o=1'b1;
				end
				else begin
					branch_target=pc_i+4;
					pre_fail=jmp_i;
				end
			end
			`EXE_BLT_OP: begin
				jmp_type=1'b1;
				if($signed(reg1_i)<$signed(reg2_i)) begin
					branch_target=pc_i+offset_i;
					pre_fail=!jmp_i;
					jmp_o=1'b1;
				end
				else begin
					branch_target=pc_i+4;
					pre_fail=jmp_i;
				end
			end
			`EXE_BGE_OP: begin
				jmp_type=1'b1;
				if($signed(reg1_i)>=$signed(reg2_i)) begin
					branch_target=pc_i+offset_i;
					pre_fail=!jmp_i;
					jmp_o=1'b1;
				end
				else begin
					branch_target=pc_i+4;
					pre_fail=jmp_i;
				end
			end
			`EXE_BLTU_OP: begin
				jmp_type=1'b1;
				if(reg1_i<reg2_i) begin
					branch_target=pc_i+offset_i;
					pre_fail=!jmp_i;
					jmp_o=1'b1;
				end
				else begin
					branch_target=pc_i+4;
					pre_fail=jmp_i;
				end
			end
			`EXE_BGEU_OP: begin
				jmp_type=1'b1;
				if(reg1_i>=reg2_i) begin
					branch_target=pc_i+offset_i;
					pre_fail=!jmp_i;
					jmp_o=1'b1;
				end
				else begin
					branch_target=pc_i+4;
					pre_fail=jmp_i;
				end
			end
		endcase
	end
end


//logic
always @(*) begin
	logicout=`ZeroWord;
	if(rst!=`RstEnable&&rdy) begin
		case(aluop_i)
			`EXE_XOR_OP: begin
				logicout=reg1_i^reg2_i;
			end
			`EXE_OR_OP: begin
				logicout=reg1_i|reg2_i;
			end
			`EXE_AND_OP: begin
				logicout=reg1_i&reg2_i;
			end
			default: begin
				logicout=`ZeroWord;
			end
		endcase
	end
end

//shift
always @(*) begin
	shiftout=`ZeroWord;
	if(rst!=`RstEnable&&rdy) begin
		case(aluop_i)
			`EXE_SLL_OP: begin
				shiftout=reg1_i<<(reg2_i[4:0]);
			end
			`EXE_SRL_OP: begin
				shiftout=reg1_i>>(reg2_i[4:0]);
			end
			`EXE_SRA_OP: begin
				shiftout=(reg1_i>>(reg2_i[4:0]))|({32{reg1_i[31]}}<<(6'd32-{1'b0,reg2_i[4:0]}));
			end
		endcase
	end
end

//arith
always @(*) begin
	
	arithout=`ZeroWord;
	if(rst!=`RstEnable) begin
		case(aluop_i)
			`EXE_AUIPC_OP: begin
				arithout=pc_i+offset_i;
			end
			`EXE_JAL_OP, `EXE_JALR_OP: begin
				arithout=pc_i+4;
			end
			`EXE_ADD_OP: begin
				arithout=reg1_i+reg2_i;
			end
			`EXE_SUB_OP: begin
				arithout=reg1_i-reg2_i;
			end
			`EXE_SLT_OP: begin
				arithout=$signed(reg1_i)<$signed(reg2_i);
			end
			`EXE_SLTU_OP: begin
				arithout=reg1_i<reg2_i;
			end
		endcase
	end
end

always @(*) begin
	loading=0;
	storing=0;
	mem_addr_o=0;
	mem_signed=0;
	mem_length=0;
	if(!rst&&alusel_i==`EXE_SEL_LD_ST) begin
		mem_addr_o=reg1_i+offset_i;
		case(aluop_i)
			`EXE_LB_OP: begin
				loading=1;
				mem_length=1;
				mem_signed=1;
			end
			`EXE_LH_OP: begin
				loading=1;
				mem_length=2;
				mem_signed=1;
			end
			`EXE_LW_OP: begin
				loading=1;
				mem_length=4;
				mem_signed=1;
			end
			`EXE_LBU_OP: begin
				loading=1;
				mem_length=1;
				mem_signed=0;
			end
			`EXE_LHU_OP: begin
				loading=1;
				mem_length=2;
				mem_signed=0;
			end
			`EXE_SB_OP: begin
				storing=1;
				mem_length=1;
			end
			`EXE_SH_OP: begin
				storing=1;
				mem_length=2;
			end
			`EXE_SW_OP: begin
				storing=1;
				mem_length=4;
			end
		endcase
	end
end

always @(*) begin
	if(rst==`RstEnable||(wreg_i&&wd_i==`NOPRegAddr)) begin
		wd_o=`NOPRegAddr;
		wreg_o=1'b0;
		wdata_o=`ZeroWord;
	end
	else begin
		wd_o=wd_i;
		wreg_o=wreg_i;
		case(alusel_i)
			`EXE_SEL_LOGIC: begin
				wdata_o=logicout;
			end
			`EXE_SEL_SHIFT: begin
				wdata_o=shiftout;
			end
			`EXE_SEL_ARITH: begin
				wdata_o=arithout;
			end
			`EXE_SEL_LD_ST: begin
				wdata_o=reg2_i;
			end
			`EXE_SEL_NOP: begin
				wdata_o=`ZeroWord;
			end
			default: begin
				wdata_o=`ZeroWord;
			end
		endcase
	end
end
	
endmodule