module buffer_write(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire io_buffer_full,
	
	input wire write,
	output wire busy,
	input wire[2:0] length,
	input wire[`MemAddrBus] addr,
	input wire[`MemBus] data,
	
	input wire ram_busy,
	input wire ram_success,
	output wire ram_write,
	output wire[`MemAddrBus] ram_addr,
	output wire[`ByteBus] ram_data
	
);

wire[`ByteBus] write_data[3:0];
assign write_data[0]=data[7:0];
assign write_data[1]=data[15:8];
assign write_data[2]=data[23:16];
assign write_data[3]=data[31:24];

reg working;
reg[2:0] cur;

assign ram_addr=addr+cur;
assign ram_data=write_data[cur];

assign busy=write||working;
assign ram_write=busy&&!ram_busy&&!io_buffer_full;

always @(posedge clk) begin
	if(rst) begin
		cur<=0;
		working<=0;
	end
	else if(~rdy) begin
	end
	else if(write) begin
		if(cur+ram_success==length) begin
			cur<=0;
			working<=0;
		end
		else begin
			cur<=cur+ram_success;
			working<=1;
		end
	end
	else if(ram_write) begin
		if(cur+ram_success==length) begin
			cur<=0;
			working<=0;
		end
		else
			cur<=cur+ram_success;
	end
end


endmodule