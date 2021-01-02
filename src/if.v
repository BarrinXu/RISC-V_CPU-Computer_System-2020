module IF(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire[`InstAddrBus] pc,
	input wire[`InstBus] mem_inst,
	input wire mem_success,
	input wire mem_busy,
	input wire[`InstAddrBus] mem_pc,

	output reg[`InstAddrBus] pc_o,
	output reg[`InstAddrBus] inst_o,
	
	output wire read_mem_flag,
	output reg[`InstAddrBus] read_mem_pc,
	
	output reg stall_if
	);
	
reg[`IcacheTagBus] tag[`IcacheIndexSize-1:0];
reg[`InstBus] data[`IcacheIndexSize-1:0];

assign read_mem_flag=(tag[read_mem_pc[`IcacheIndexBits]]!=read_mem_pc[`IcacheTagBits] &(~mem_success));	//why & ~mem_success -> maybe already get but not update in time???

integer i;

always @(posedge clk) begin
	if(rst) begin
		for(i=0; i<`IcacheIndexSize; i=i+1) begin
			tag[i][`IcacheValidBit]<=`InstInvalid;
		end
		read_mem_pc<=`ZeroWord;
	end
	else if(~rdy) begin
	end
	else begin
		if(mem_success) begin
			tag[mem_pc[`IcacheIndexBits]]<=mem_pc[`IcacheTagBits];
			data[mem_pc[`IcacheIndexBits]]<=mem_inst;
			//read_mem_pc<=pc+4;
		end
		else begin
			read_mem_pc<=pc;
		end
	end
end

always @(*) begin
	if(rst) begin
		stall_if=`NoStop;
		pc_o=`ZeroWord;
		inst_o=`ZeroWord;
	end
	else if(tag[pc[`IcacheIndexBits]]==pc[`IcacheTagBits]) begin
		stall_if=`NoStop;
		pc_o=pc;
		inst_o=data[pc[`IcacheIndexBits]];
	end
	else if(mem_success&&mem_pc==pc) begin
		stall_if=`NoStop;
		pc_o=pc;
		inst_o=mem_inst;
	end
	else begin
		stall_if=`Stop;
		pc_o=`ZeroWord;
		inst_o=`ZeroWord;
	end
end

endmodule