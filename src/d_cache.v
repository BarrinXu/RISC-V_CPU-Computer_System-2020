module d_cache(
	input wire clk,
	input wire rdy,
	input wire rst,
	input wire ram_busy,
	input wire ram_ready,
	output reg ram_read,
	output reg[2:0] ram_length,
	output reg ram_signed,
	output reg[`MemAddrBus] ram_addr,
	input wire[`MemBus] ram_data,
	
	input wire buffer_busy,
	output reg buffer_write,
	output reg[2:0] buffer_length,
	output reg[`MemAddrBus] buffer_addr,
	output reg[`MemBus] buffer_data,
	
	input wire read,
	input wire write,
	output reg ready,
	input wire[2:0] length,
	input wire signed_,
	input wire[`MemAddrBus] addr,
	input wire[`MemBus] data_i,
	output reg[`MemBus] data_o
);

reg to_read,to_write;
always @(*) begin
	ready=0;
	data_o=0;
	to_read=0;
	to_write=0;
	if(rst) begin
	end
	else if(~rdy) begin
	end
	else if(read) begin
		if(ram_ready) begin
			ready=1;
			data_o=ram_data;
		end
		else
			to_read=1;
	end
	else if(write) begin
		if(!buffer_busy) begin
			ready=1;
			to_write=1;
		end
	end
end

reg delay_read;

always @(posedge clk) begin
	if(rdy) begin
		delay_read<=to_read;
		ram_length<=length;
		ram_addr<=addr;
		ram_signed<=signed_;
	end
end

always @(*) begin
    ram_read=delay_read&&!ram_busy;
end

always @(posedge clk) begin
	if(rst) begin
		buffer_write<=0;
		buffer_length<=0;
		buffer_addr<=0;
		buffer_data<=0;
	end
	else if(~rdy) begin
	end
	else if(to_write) begin
		buffer_write<=1;
		buffer_length<=length;
		buffer_addr<=addr;
		buffer_data<=data_i;
	end
	else
		buffer_write<=0;
end

endmodule