module if_id(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,
	
	input wire ex_pre_fail,
	
	input wire[`StallBus] stall_stmt,
	
	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst);
	
always @(posedge clk) begin
	if(rst==`RstEnable) begin
		id_pc<=`ZeroWord;
		id_inst<=`ZeroWord;
	end
	else if(~rdy) begin
	end
	else if(stall_stmt[2]==`Stop) begin
	end
	else if(ex_pre_fail) begin
		id_pc<=`ZeroWord;
		id_inst<=`ZeroWord;
	end
	else if(stall_stmt[1]==`NoStop) begin
		id_pc<=if_pc;
		id_inst<=if_inst;
	end
	else begin
		id_pc<=`ZeroWord;
		id_inst<=`ZeroWord;
	end
end

endmodule