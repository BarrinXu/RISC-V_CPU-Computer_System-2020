module pc_reg(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire[`StallBus] stall_stmt,
	
	input wire ex_pre_fail,
	input wire[`InstAddrBus] ex_target,
	input pre_jmp,
	input wire[`InstAddrBus] pre_target,
	
	
	output reg[`InstAddrBus] pc,
	output reg jmp
	);
	
	always @(posedge clk) begin
		if(rst==`RstEnable) begin
			pc<=`ZeroWord;
			jmp<=1'b0;
		end
		else if(~rdy) begin
		end
		else if(stall_stmt[2]==`Stop) begin	//[2]meaning?
		end
		else if(ex_pre_fail) begin
			pc<=ex_target;
			jmp<=1'b0;
		end
		else if(stall_stmt[0]==`Stop) begin
		end
		else if(pre_jmp==1'b1) begin
			pc<=pre_target;
			jmp<=1'b1;
		end
		else begin
			pc<=pc+4;
			jmp<=1'b0;
		end
	end
endmodule