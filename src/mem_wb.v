module mem_wb(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire[`RegAddrBus] mem_wd,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,
	
	input wire[`StallBus] stall_stmt,
	
	output reg[`RegAddrBus] wb_wd,
	output reg wb_wreg,
	output reg[`RegBus] wb_wdata);
	
	always @(posedge clk) begin
		if(rst==`RstEnable) begin
			wb_wd<=`NOPRegAddr;
			wb_wreg<=`WriteDisable;
			wb_wdata<=`ZeroWord;
		end
		else if(~rdy) begin
		end
		else if(stall_stmt[4]==`Stop) begin
            wb_wd<=`NOPRegAddr;
			wb_wreg<=`WriteDisable;
			wb_wdata<=`ZeroWord;
		end
		else begin
			wb_wd<=mem_wd;
			wb_wreg<=mem_wreg;
			wb_wdata<=mem_wdata;
		end
	end
	
endmodule