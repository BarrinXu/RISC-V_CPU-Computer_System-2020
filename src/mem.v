module mem(
	input wire rst,
	input wire rdy,
	
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus] wdata_i,
	
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,
	
	input wire load,
	input wire store,
	input wire[`MemAddrBus] addr,
	input wire[`MemBus] data,
	input wire[2:0] length,
	input wire signed_,
	
	input wire ram_ready,
	output reg[`MemAddrBus] ram_addr,
	input wire[`MemBus] ram_data_i,
	output reg[`MemBus] ram_data_o,
	output reg[2:0] ram_length,
	output reg ram_signed,
	output reg ram_read,
	output reg ram_write,
	
	
	output wire stall_mem
	);

assign stall_mem=(load||store)&&!ram_ready;

always @(*) begin
	wreg_o=wreg_i;
	wd_o=wd_i;
	ram_read=0;
	ram_write=0;
	ram_addr=0;
	ram_length=0;
	ram_signed=0;
	ram_data_o=0;
	if(rst) begin
		wreg_o=0;
		wd_o=0;
	end
	else if(~rdy) begin
	end
	else if(load) begin
		ram_read=1;
		ram_addr=addr;
		ram_length=length;
		ram_signed=signed_;
	end
	else if(store) begin
		ram_write=1;
		ram_addr=addr;
		ram_length=length;
		ram_data_o=data;
	end
end
	
always @(*) begin
	if(rst)
		wdata_o=0;
	else if(!load)
		wdata_o=wdata_i;
	else
		wdata_o=ram_data_i;
end

endmodule