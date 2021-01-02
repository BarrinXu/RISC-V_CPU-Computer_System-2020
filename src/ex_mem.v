module ex_mem(
	input wire clk,
	input wire rst,
	input wire rdy,
	
	
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,
	
	input wire load_i,
	input wire store_i,
	input wire[`RegBus] mem_addr_i,
	input wire[`RegBus] mem_write_data_i,
	input wire[2:0] mem_length_i,
	input wire mem_signed_i,
	
	input wire[`StallBus] stall_stmt,
	
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata,
	
	output reg load_o,
	output reg store_o,
	output reg[`RegBus] mem_addr_o,
	output reg[`MemBus] mem_write_data_o,
	output reg[2:0] mem_length_o,
	output reg mem_signed_o
	);
	
always @(posedge clk) begin
	if(rst||(stall_stmt[3]&&!stall_stmt[4])) begin
		mem_wreg<=0;
		mem_wd<=0;
		mem_wdata<=0;
		load_o<=0;
		store_o<=0;
		mem_addr_o<=0;
		mem_write_data_o<=0;
		mem_length_o<=0;
		mem_signed_o<=0;
	end
	else if(~rdy) begin
	end
	else if(!stall_stmt[3]&&!stall_stmt[4]) begin
		mem_wreg<=ex_wreg;
		mem_wd<=ex_wd;
		mem_wdata<=ex_wdata;
		load_o<=load_i;
		store_o<=store_i;
		mem_addr_o<=mem_addr_i;
		mem_write_data_o<=mem_write_data_i;
		mem_length_o<=mem_length_i;
		mem_signed_o<=mem_signed_i;
	end
end
	
endmodule