module predictor(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire[`InstAddrBus] pc,
	output reg pre_jmp,
	output reg[`InstAddrBus] pre_target,
	
	input wire[`InstAddrBus] ex_pc,
	input wire ex_jmp_type,
	input wire[`InstAddrBus] ex_jmp_target,
	input wire ex_jmp
	);
	
	reg[`PreTagBus] tag[`PreIndexSize-1:0];
	reg[`InstBus] data[`PreIndexSize-1:0];
	reg[1:0] stmt[`PreIndexSize-1:0];

	integer i;
	
	always @(posedge clk) begin
		if(rst) begin
			for(i=0; i<`PreIndexSize; i=i+1) begin
				tag[i][`PreValidBit]<=`InstInvalid;
				stmt[i]<=2'b10;
			end
		end
		else if(~rdy) begin
		end
		else if(ex_jmp_type&&ex_jmp) begin
			tag[ex_pc[`PreIndexBits]]<=ex_pc[`PreTagBits];
			data[ex_pc[`PreIndexBits]]<=ex_jmp_target;
			if(stmt[ex_pc[`PreIndexBits]]<2'h3)
				stmt[ex_pc[`PreIndexBits]]<=stmt[ex_pc[`PreIndexBits]]+1;
		end
		else if(ex_jmp_type&&!ex_jmp) begin
			tag[ex_pc[`PreIndexBits]]<=ex_pc[`PreTagBits];
			data[ex_pc[`PreIndexBits]]<=ex_jmp_target;
			if(stmt[ex_pc[`PreIndexBits]]>2'h0)
				stmt[ex_pc[`PreIndexBits]]<=stmt[ex_pc[`PreIndexBits]]-1;
		end
	end
	
	always @(*) begin
		if(rst) begin
			pre_jmp=1'b0;
			pre_target=`ZeroWord;
		end
		else if(tag[pc[`PreIndexBits]]==pc[`PreTagBits]&&stmt[pc[`PreIndexBits]][1]==1'b1) begin
			pre_jmp=1'b1;
			pre_target=data[pc[`PreIndexBits]];
		end
		else begin
			pre_jmp=1'b0;
			pre_target=`ZeroWord;
		end
	end
	
endmodule