module mem_ctrl(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire if_discard,
	
	input wire if_read,
	input wire[`MemAddrBus] if_addr,
	output reg[`MemAddrBus] if_addr_o,
	output reg if_busy,
	output reg if_ready,
	output reg[`MemBus] if_data,
	
	input wire mem_read,
	input wire[`MemAddrBus] mem_r_addr,
	input wire[2:0] mem_r_length,
	input wire mem_r_signed,
	output reg mem_r_busy,
	output reg mem_r_ready,
	output reg[`MemBus] mem_r_data,
	
	input wire mem_write,
	input wire[`MemAddrBus] mem_w_addr,
	input wire[`ByteBus] mem_w_data,
	output reg mem_w_busy,
	output wire mem_w_success,
	
	output wire ram_rw,
	output reg[`MemAddrBus] ram_addr,
	output wire[`ByteBus] ram_w_data,
	input wire[`ByteBus] ram_r_data

);

reg[2:0] cur,cur_if;
reg[`ByteBus] if_ret[3:0],mem_ret[2:0];
reg[`MemAddrBus] if_addr_lst;
wire mem_read_working=mem_read&&!mem_r_ready;
wire if_working=if_read&&!if_ready;
wire mem_write_working=mem_write;
assign mem_w_success=mem_write_working;

assign ram_rw=mem_w_success;
assign ram_w_data=mem_w_data;

reg sp_if;
reg lst_if;
always @(*) begin
	if(mem_write_working) begin
		ram_addr=mem_w_addr;
	    //cur=0;
	    //cur_if=0;
	end
	else if(mem_read_working) begin
		ram_addr=mem_r_addr+cur;
		//cur_if=0;
	end
	else if(if_working) begin
	    //cur=0;
		ram_addr=if_addr+cur_if;
	end
	else begin
	   ram_addr=0;
	   //cur=0;	
	   //cur_if=0;
	end
end
//always @(posedge if_addr) begin
//    if(if_working)
//        cur_if<=0;
//end

always @(posedge clk) begin
    //if(ram_addr==32'h18c4) begin
    //    $display("!!!");    
    //end
	if(rst) begin
	    if_data<=0;
	    mem_r_data<=0;
	    if_addr_o<=0;
	    if_addr_lst<=0;
	    sp_if<=0;
	    lst_if<=0;
		if_ready<=0;
		mem_r_ready<=0;
		if_busy<=0;
		mem_r_busy<=0;
		mem_w_busy<=0;
		cur<=0;
		cur_if<=0;
	end
	else if(~rdy) begin
	end
	else if(mem_write_working) begin
	   if(if_discard) begin
           sp_if<=1;
	   end
	   if_ready<=0;
	   mem_r_ready<=0;
	   if_busy<=1;
	   mem_r_busy<=1;
	   mem_w_busy<=0;
	   cur_if<=0;
	   cur<=0;
	end
	else if(mem_read_working) begin
	    cur_if<=0;
	    if(if_discard) begin
            sp_if<=1;
	    end
		if(cur==0) begin
			if_ready<=0;
			mem_r_ready<=0;
			if_busy<=1;
			mem_r_busy<=0;
			mem_w_busy<=1;
			cur<=1;
		end
		else if(cur<mem_r_length) begin
			mem_ret[cur-1]<=ram_r_data;
			cur<=cur+1;
		end
		else begin
			mem_r_ready<=1;
			if_busy<=0;
			mem_w_busy<=0;
			cur<=0;
			case(mem_r_length)
				1:
					mem_r_data<={{24{mem_r_signed&&ram_r_data[7]}},ram_r_data};
				2:
					mem_r_data<={{16{mem_r_signed&&ram_r_data[7]}},ram_r_data,mem_ret[0]};
				4:
					mem_r_data<={ram_r_data,mem_ret[2],mem_ret[1],mem_ret[0]};
			endcase
		end
	end
	else if(if_working) begin
	    cur<=0;
		if(if_discard) begin
		    sp_if<=1;
			if_ready<=0;
			mem_r_ready<=0;
			if_busy<=0;
			mem_r_busy<=0;
			mem_w_busy<=0;
			cur_if<=0;
		end
		else if(cur_if==0) begin
			if_ready<=0;
			mem_r_ready<=0;
			if_busy<=0;
			mem_r_busy<=1;
			mem_w_busy<=1;
			if(sp_if)
			    sp_if<=0;
			else
			    cur_if<=1;
		end
		else if(!cur_if[2]) begin
			if_ret[cur_if-1]<=ram_r_data;
			cur_if<=cur_if+1;
		end
		else begin
			if_ready<=1;
			mem_r_busy<=0;
			mem_w_busy<=0;
			cur_if<=0;
			if_addr_o=if_addr;
			if_data<={ram_r_data,if_ret[2],if_ret[1],if_ret[0]};
		end
	end
	else begin
		if_ready<=0;
		mem_r_ready<=0;
		if_busy<=0;
		mem_r_busy<=0;
		mem_w_busy<=0;
		cur<=0;
		cur_if<=0;
		//really useful??
	end
end

endmodule