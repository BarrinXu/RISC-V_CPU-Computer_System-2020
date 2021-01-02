module id(
	input wire rst,
	input wire rdy,
	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,
	input wire jmp_i,//whether the predictor let jump
	
	input wire[`RegBus] reg1_data_i,
	input wire[`RegBus] reg2_data_i,
	
	//ex_forwarding
	input wire ex_loading,
	input wire ex_wreg_i,
	input wire[`RegBus] ex_wdata_i,
	input wire[`RegAddrBus] ex_wd_i,
	//mem_forwarding
	input wire mem_wreg_i,
	input wire[`RegBus] mem_wdata_i,
	input wire[`RegAddrBus] mem_wd_i,
	
	output reg reg1_read_o,
	output reg reg2_read_o,
	output reg[`RegAddrBus] reg1_addr_o,
	output reg[`RegAddrBus] reg2_addr_o,
	
	output reg[`AluOpBus] aluop_o,
	output reg[`AluSelBus] alusel_o,
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	
	output reg[`InstAddrBus] pc_o,//now pc address
	output reg jmp_o,//whether the predictor let jump
	output reg[`RegBus] offset_o,
	
	output wire stall_id
	);
	
	
	
wire[6:0] op=inst_i[6:0];
wire[2:0] funct3=inst_i[14:12];
wire[6:0] funct7=inst_i[31:25];

reg[`RegBus] imm;

reg instvalid;
reg stall_reg1;
reg stall_reg2;


//step1 decode the instruction
always @(*) begin
	if(rst==`RstEnable) begin
		aluop_o=`EXE_NOP_OP;
		alusel_o=`EXE_SEL_NOP;
		wd_o=`NOPRegAddr;
		wreg_o=`WriteDisable;
		instvalid=`InstValid;
		reg1_read_o=1'b0;
		reg2_read_o=1'b0;
		reg1_addr_o=`NOPRegAddr;
		reg2_addr_o=`NOPRegAddr;
		imm=32'h0;
		pc_o=`ZeroWord;
		jmp_o=1'b0;
	end
	else begin
		aluop_o=`EXE_NOP_OP;
		alusel_o=`EXE_SEL_NOP;
		wd_o=inst_i[11:7];
		wreg_o=`WriteDisable;
		instvalid=`InstInvalid;
		reg1_read_o=1'b0;
		reg2_read_o=1'b0;
		reg1_addr_o=inst_i[19:15];
		reg2_addr_o=inst_i[24:20];
		imm=`ZeroWord;
		pc_o=pc_i;
		jmp_o=jmp_i;
		case(op)
			`EXE_LUI: begin
				wreg_o=`WriteEnable;
				aluop_o=`EXE_OR_OP;
				alusel_o=`EXE_SEL_LOGIC;
				reg1_read_o=1'b0;
				reg2_read_o=1'b0;
				imm={inst_i[31:12],12'h0};
				instvalid=`InstValid;
			end
			`EXE_AUIPC: begin
				wreg_o=`WriteEnable;
				aluop_o=`EXE_AUIPC_OP;
				alusel_o=`EXE_SEL_ARITH;
				reg1_read_o=1'b0;
				reg2_read_o=1'b0;
				imm={inst_i[31:12],12'h0};
				instvalid=`InstValid;
			end
			`EXE_JAL: begin
				wreg_o=`WriteEnable;
				aluop_o=`EXE_JAL_OP;
				alusel_o=`EXE_SEL_ARITH;//diff from yzh
				reg1_read_o=1'b0;
				reg2_read_o=1'b0;
				imm={{12{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],1'h0};
				instvalid=`InstValid;
			end
			`EXE_JALR: begin
				wreg_o=`WriteEnable;
				aluop_o=`EXE_JALR_OP;
				alusel_o=`EXE_SEL_ARITH;//diff from yzh
				reg1_read_o=1'b1;
				reg2_read_o=1'b0;
				imm={{21{inst_i[31]}},inst_i[30:20]};
				instvalid=`InstValid;
			end
			`EXE_BRANCH: begin
				case(funct3)
					`F3_BEQ: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_BEQ_OP;
						alusel_o=`EXE_SEL_NOP;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
						instvalid=`InstValid;
					end
					`F3_BNE: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_BNE_OP;
						alusel_o=`EXE_SEL_NOP;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
						instvalid=`InstValid;
					end
					`F3_BLT: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_BLT_OP;
						alusel_o=`EXE_SEL_NOP;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
						instvalid=`InstValid;
					end
					`F3_BGE: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_BGE_OP;
						alusel_o=`EXE_SEL_NOP;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
						instvalid=`InstValid;
					end
					`F3_BLTU: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_BLTU_OP;
						alusel_o=`EXE_SEL_NOP;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
						instvalid=`InstValid;
					end
					`F3_BGEU: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_BGEU_OP;
						alusel_o=`EXE_SEL_NOP;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
						instvalid=`InstValid;
					end
				endcase
			end
			`EXE_LOAD: begin
				case(funct3)
					`F3_LB: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_LB_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{21{inst_i[31]}},inst_i[30:20]};
						instvalid=`InstValid;
					end
					`F3_LH: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_LH_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{21{inst_i[31]}},inst_i[30:20]};
						instvalid=`InstValid;
					end
					`F3_LW: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_LW_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{21{inst_i[31]}},inst_i[30:20]};
						instvalid=`InstValid;
					end
					`F3_LBU: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_LBU_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{21{inst_i[31]}},inst_i[30:20]};
						instvalid=`InstValid;
					end
					`F3_LHU: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_LHU_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{21{inst_i[31]}},inst_i[30:20]};
						instvalid=`InstValid;
					end
				endcase
			end
			`EXE_STORE: begin
				case(funct3)
					`F3_SB: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_SB_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{21{inst_i[31]}},inst_i[30:25],inst_i[11:7]};
						instvalid=`InstValid;
					end
					`F3_SH: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_SH_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{21{inst_i[31]}},inst_i[30:25],inst_i[11:7]};
						instvalid=`InstValid;
					end
					`F3_SW: begin
						wreg_o=`WriteDisable;
						aluop_o=`EXE_SW_OP;
						alusel_o=`EXE_SEL_LD_ST;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						imm={{21{inst_i[31]}},inst_i[30:25],inst_i[11:7]};
						instvalid=`InstValid;
					end
				endcase
			end
			`EXE_OPI: begin
				case(funct3)
					`F3_ADDI: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_ADD_OP;
						alusel_o=`EXE_SEL_ARITH;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{20{inst_i[31]}},inst_i[31:20]};
						instvalid=`InstValid;
					end
					`F3_SLTI: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_SLT_OP;
						alusel_o=`EXE_SEL_ARITH;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{20{inst_i[31]}},inst_i[31:20]};
						instvalid=`InstValid;
					end
					`F3_SLTIU: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_SLTU_OP;
						alusel_o=`EXE_SEL_ARITH;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{20{inst_i[31]}},inst_i[31:20]};
						instvalid=`InstValid;
					end
					`F3_XORI: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_XOR_OP;
						alusel_o=`EXE_SEL_LOGIC;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{20{inst_i[31]}},inst_i[31:20]};
						instvalid=`InstValid;
					end
					`F3_ORI: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_OR_OP;
						alusel_o=`EXE_SEL_LOGIC;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{20{inst_i[31]}},inst_i[31:20]};
						instvalid=`InstValid;
					end
					`F3_ANDI: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_AND_OP;
						alusel_o=`EXE_SEL_LOGIC;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={{20{inst_i[31]}},inst_i[31:20]};
						instvalid=`InstValid;
					end
					`F3_SLLI: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_SLL_OP;
						alusel_o=`EXE_SEL_SHIFT;
						reg1_read_o=1'b1;
						reg2_read_o=1'b0;
						imm={27'h0,inst_i[24:20]};
						instvalid=`InstValid;
					end
					`F3_SRLI: begin
						case(funct7)
							`F7_SRLI: begin
								wreg_o=`WriteEnable;
								aluop_o=`EXE_SRL_OP;
								alusel_o=`EXE_SEL_SHIFT;
								reg1_read_o=1'b1;
								reg2_read_o=1'b0;
								imm={27'h0,inst_i[24:20]};
								instvalid=`InstValid;
							end
							`F7_SRAI: begin
								wreg_o=`WriteEnable;
								aluop_o=`EXE_SRA_OP;
								alusel_o=`EXE_SEL_SHIFT;
								reg1_read_o=1'b1;
								reg2_read_o=1'b0;
								imm={27'h0,inst_i[24:20]};
								instvalid=`InstValid;
							end
						endcase
					end
				endcase
			end
			`EXE_OP: begin
				case(funct3)
					`F3_ADD: begin
						case(funct7)
							`F7_ADD: begin
								wreg_o=`WriteEnable;
								aluop_o=`EXE_ADD_OP;
								alusel_o=`EXE_SEL_ARITH;
								reg1_read_o=1'b1;
								reg2_read_o=1'b1;
								instvalid=`InstValid;
							end
							`F7_SUB: begin
								wreg_o=`WriteEnable;
								aluop_o=`EXE_SUB_OP;
								alusel_o=`EXE_SEL_ARITH;
								reg1_read_o=1'b1;
								reg2_read_o=1'b1;
								instvalid=`InstValid;
							end
						endcase
					end
					`F3_SLT: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_SLT_OP;
						alusel_o=`EXE_SEL_ARITH;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						instvalid=`InstValid;
					end
					`F3_SLTU: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_SLTU_OP;
						alusel_o=`EXE_SEL_ARITH;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						instvalid=`InstValid;
					end
					`F3_XOR: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_XOR_OP;
						alusel_o=`EXE_SEL_LOGIC;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						instvalid=`InstValid;
					end
					`F3_OR: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_OR_OP;
						alusel_o=`EXE_SEL_LOGIC;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						instvalid=`InstValid;
					end
					`F3_AND: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_AND_OP;
						alusel_o=`EXE_SEL_LOGIC;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						instvalid=`InstValid;
					end
					`F3_SLL: begin
						wreg_o=`WriteEnable;
						aluop_o=`EXE_SLL_OP;
						alusel_o=`EXE_SEL_SHIFT;
						reg1_read_o=1'b1;
						reg2_read_o=1'b1;
						instvalid=`InstValid;
					end
					`F3_SRL: begin
						case(funct7)
							`F7_SRL: begin
								wreg_o=`WriteEnable;
								aluop_o=`EXE_SRL_OP;
								alusel_o=`EXE_SEL_SHIFT;
								reg1_read_o=1'b1;
								reg2_read_o=1'b1;
								instvalid=`InstValid;
							end
							`F7_SRA: begin
								wreg_o=`WriteEnable;
								aluop_o=`EXE_SRA_OP;
								alusel_o=`EXE_SEL_SHIFT;
								reg1_read_o=1'b1;
								reg2_read_o=1'b1;
								instvalid=`InstValid;
							end
						endcase
					end
				endcase
			end
			default: begin
				//unkonwn op
			end
		endcase
	end
end

//step2 get rs1
always @(*) begin
	stall_reg1=`NoStop;
	if(rst==`RstEnable)
		reg1_o=`ZeroWord;
	else if((reg1_read_o==1'b1)&&(ex_loading==1'b1)&&(ex_wd_i==reg1_addr_o)) begin
		reg1_o=`ZeroWord;
		stall_reg1=1'b1;
	end
	else if((reg1_read_o==1'b1)&&(ex_wreg_i==1'b1)&&(ex_wd_i==reg1_addr_o))
		reg1_o=ex_wdata_i;
	else if((reg1_read_o==1'b1)&&(mem_wreg_i==1'b1)&&(mem_wd_i==reg1_addr_o))
		reg1_o=mem_wdata_i;
	else if(reg1_read_o==1'b1)
		reg1_o=reg1_data_i;
	else if(reg1_read_o==1'b0)
		reg1_o=imm;
	else
		reg1_o=`ZeroWord;
end
//step3 get rs2
always @(*) begin
	stall_reg2=`NoStop;
	if(rst==`RstEnable)
		reg2_o=`ZeroWord;
	else if((reg2_read_o==1'b1)&&(ex_loading==1'b1)&&(ex_wd_i==reg2_addr_o)) begin
		reg2_o=`ZeroWord;
		stall_reg2=1'b1;
	end
	else if((reg2_read_o==1'b1)&&(ex_wreg_i==1'b1)&&(ex_wd_i==reg2_addr_o))
		reg2_o=ex_wdata_i;
	else if((reg2_read_o==1'b1)&&(mem_wreg_i==1'b1)&&(mem_wd_i==reg2_addr_o))
		reg2_o=mem_wdata_i;
	else if(reg2_read_o==1'b1)
		reg2_o=reg2_data_i;
	else if(reg2_read_o==1'b0)
		reg2_o=imm;
	else
		reg2_o=`ZeroWord;
end

always @(*) begin
	if(rst==`RstEnable)
		offset_o=`ZeroWord;
	else
		offset_o=imm;
end

assign stall_id=stall_reg1|stall_reg2;


	
endmodule