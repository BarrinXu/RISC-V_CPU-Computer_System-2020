module stall(
	input wire rst,
	input wire rdy,
	input wire stall_if,
	input wire stall_id,
	input wire stall_mem,
	output reg[`StallBus] stall_stmt
	);
	
	always @(*) begin
		if(rst==`RstEnable)
			stall_stmt=`Stall_All;
		else if(stall_mem==`Stop)
			stall_stmt=`Stall_Mem;
		else if(stall_id==`Stop)
			stall_stmt=`Stall_Id;
		else if(stall_if==`Stop)
			stall_stmt=`Stall_If;
		else
			stall_stmt=`NoStall;
	end
endmodule