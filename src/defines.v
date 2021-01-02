//全局的宏定义

`define Stop 1'b1
`define NoStop 1'b0
`define StallBus 5:0
`define NoStall 6'b000000
`define Stall_Jmp 6'b000011
`define Stall_If 6'b000011
`define Stall_Id 6'b000111
`define Stall_Ex 6'b001111
`define Stall_Mem 6'b011111
`define Stall_All 6'b111111

`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000

`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0

`define AluOpBus 4:0
`define AluSelBus 2:0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

//与具体指令有关的宏定义
`define EXE_LUI 7'b0110111
`define EXE_AUIPC 7'b0010111
`define EXE_JAL 7'b1101111
`define EXE_JALR 7'b1100111
`define EXE_BRANCH 7'b1100011
`define EXE_LOAD 7'b0000011
`define EXE_STORE 7'b0100011
`define EXE_OPI 7'b0010011
`define EXE_OP 7'b0110011
`define EXE_NOP 7'b0000000


`define F3_BEQ 3'b000
`define F3_BNE 3'b001
`define F3_BLT 3'b100
`define F3_BGE 3'b101
`define F3_BLTU 3'b110
`define F3_BGEU 3'b111

`define F3_LB 3'b000
`define F3_LH 3'b001
`define F3_LW 3'b010
`define F3_LBU 3'b100
`define F3_LHU 3'b101

`define F3_SB 3'b000
`define F3_SH 3'b001
`define F3_SW 3'b010

`define F3_ADDI 3'b000
`define F3_SLTI 3'b010
`define F3_SLTIU 3'b011
`define F3_XORI 3'b100
`define F3_ORI 3'b110
`define F3_ANDI 3'b111
`define F3_SLLI 3'b001
`define F3_SRLI 3'b101

`define F3_ADD 3'b000
`define F3_SUB 3'b000
`define F3_SLL 3'b001
`define F3_SLT 3'b010
`define F3_SLTU 3'b011
`define F3_XOR 3'b100
`define F3_SRL 3'b101
`define F3_SRA 3'b101
`define F3_OR 3'b110
`define F3_AND 3'b111

`define F7_SRLI 7'b0000000
`define F7_SRAI 7'b0100000

`define F7_ADD 7'b0000000
`define F7_SUB 7'b0100000

`define F7_SRL 7'b0000000
`define F7_SRA 7'b0100000

//AluOp
`define EXE_NOP_OP 5'h0
`define EXE_ADD_OP 5'h1
`define EXE_SUB_OP 5'h2
`define EXE_SLT_OP 5'h3
`define EXE_SLTU_OP 5'h4
`define EXE_XOR_OP 5'h5
`define EXE_OR_OP 5'h6
`define EXE_AND_OP 5'h7
`define EXE_SLL_OP 5'h8
`define EXE_SRL_OP 5'h9
`define EXE_SRA_OP 5'ha
`define EXE_AUIPC_OP 5'hb

`define EXE_JAL_OP 5'hc
`define EXE_JALR_OP 5'hd
`define EXE_BEQ_OP 5'he
`define EXE_BNE_OP 5'hf
`define EXE_BLT_OP 5'h10
`define EXE_BGE_OP 5'h11
`define EXE_BLTU_OP 5'h12
`define EXE_BGEU_OP 5'h13

`define EXE_LB_OP 5'h14
`define EXE_LH_OP 5'h15
`define EXE_LW_OP 5'h16
`define EXE_LBU_OP 5'h17
`define EXE_LHU_OP 5'h18
`define EXE_SB_OP 5'h19
`define EXE_SH_OP 5'h1a
`define EXE_SW_OP 5'h1b

//AluSel
`define EXE_SEL_NOP 3'b000
`define EXE_SEL_LOGIC 3'b001
`define EXE_SEL_SHIFT 3'b010
`define EXE_SEL_ARITH 3'b011
`define EXE_SEL_LD_ST 3'b101

//与指令存储器ROM有关的宏定义
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17

//Predictor
`define PreIndexSize 128
`define PreIndexBits 8:2
`define PreTagBus 8:0
`define PreTagBits 17:9
`define PreValidBit 8

//Icache
`define IcacheIndexBits 9:2
`define IcacheIndexSize 256
`define IcacheTagBus 7:0
`define IcacheTagBits 17:10
`define IcacheValidBit 7


//与通用寄存器Regfile有关的宏定义
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000

`define MemBus 31:0
`define MemAddrBus 31:0
`define ByteBus 7:0