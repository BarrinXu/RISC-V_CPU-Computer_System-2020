// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

wire rst;
assign rst=rst_in;

wire rdy;
assign rdy=rdy_in;

wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;

wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;

wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;

wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;

wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;

wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;

wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

wire pre_jmp;
wire[`InstAddrBus] pre_target;
wire[`InstAddrBus] ex_pc;
wire ex_jmp_type;
wire[`InstAddrBus] ex_jmp_target;
wire ex_jmp;
wire[`StallBus] stall_stmt;
wire ex_pre_fail;
wire[`InstAddrBus] ex_target;
wire jmp;
wire [`InstBus] mem_inst;
wire mem_success;
wire[`InstAddrBus] mem_pc;
wire[`InstAddrBus] if_pc_o;
wire[`InstAddrBus] if_inst_o;
wire read_mem_flag;
wire[`InstAddrBus] read_mem_pc;
wire stall_if;
wire[`InstAddrBus] id_pc_o;
wire id_jmp_o;
wire[`RegBus] id_offset_o;
wire stall_id;
wire ex_jmp_i;
wire[`InstAddrBus] ex_offset_i;
wire[`RegBus] ex_mem_addr_o;
wire ex_loading_o;
wire ex_storing_o;
wire[2:0] ex_mem_length_o;
wire ex_mem_signed_o;
wire mem_load_i;
wire mem_store_i;
wire[`RegBus] mem_addr_i;
wire[`MemBus] mem_write_data_i;
wire[2:0] mem_length_i;
wire mem_signed_i;
wire mem_ram_ready;
wire[`MemAddrBus] mem_ram_addr;
wire[`MemBus] mem_ram_data_i;
wire[`MemBus] mem_ram_data_o;
wire[2:0] mem_ram_length;
wire mem_ram_signed;
wire mem_ram_read;
wire mem_ram_write;
wire stall_mem;
wire d_cache_ram_busy;
wire d_cache_ram_ready;
wire d_cache_ram_read;
wire[2:0] d_cache_ram_length;
wire d_cache_ram_signed;
wire[`MemAddrBus] d_cache_ram_addr;
wire[`MemBus] d_cache_ram_data;
wire d_cache_buffer_busy;
wire d_cache_buffer_write;
wire[2:0] d_cache_buffer_length;
wire[`MemAddrBus] d_cache_buffer_addr;
wire[`MemBus] d_cache_buffer_data;
wire if_mem_busy;
wire buffer_ram_busy;
wire buffer_ram_success;
wire buffer_ram_write;
wire[`MemAddrBus] buffer_ram_addr;
wire[`ByteBus] buffer_ram_data;

stall stall(
	.rst(rst), .rdy(rdy),
	.stall_if(stall_if), 
	.stall_id(stall_id),
	.stall_mem(stall_mem),
	.stall_stmt(stall_stmt)
);

mem_ctrl mem_ctrl0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.if_discard(ex_pre_fail),
	.if_read(read_mem_flag), .if_addr(read_mem_pc), .if_addr_o(mem_pc),
	.if_busy(if_mem_busy), .if_ready(mem_success), .if_data(mem_inst),
	.mem_read(d_cache_ram_read), .mem_r_addr(d_cache_ram_addr),
	.mem_r_length(d_cache_ram_length), .mem_r_signed(d_cache_ram_signed),
	.mem_r_busy(d_cache_ram_busy), .mem_r_ready(d_cache_ram_ready),
	.mem_r_data(d_cache_ram_data),
	.mem_write(buffer_ram_write),
	.mem_w_addr(buffer_ram_addr), .mem_w_data(buffer_ram_data),
	.mem_w_busy(buffer_ram_busy), .mem_w_success(buffer_ram_success),
	.ram_rw(mem_wr), .ram_addr(mem_a),
	.ram_w_data(mem_dout), .ram_r_data(mem_din)
);

buffer_write buffer_write0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.io_buffer_full(io_buffer_full),
	.write(d_cache_buffer_write), .busy(d_cache_buffer_busy),
	.length(d_cache_buffer_length), .addr(d_cache_buffer_addr),
	.data(d_cache_buffer_data),
	.ram_busy(buffer_ram_busy), .ram_success(buffer_ram_success),
	.ram_write(buffer_ram_write),
	.ram_addr(buffer_ram_addr), .ram_data(buffer_ram_data)
);

d_cache d_cache0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.ram_busy(d_cache_ram_busy), .ram_ready(d_cache_ram_ready),
	.ram_read(d_cache_ram_read),
	.ram_length(d_cache_ram_length), .ram_signed(d_cache_ram_signed),
	.ram_addr(d_cache_ram_addr), .ram_data(d_cache_ram_data),
	.buffer_busy(d_cache_buffer_busy), .buffer_write(d_cache_buffer_write),
	.buffer_length(d_cache_buffer_length),
	.buffer_addr(d_cache_buffer_addr), .buffer_data(d_cache_buffer_data),
	.read(mem_ram_read), .write(mem_ram_write), .ready(mem_ram_ready),
	.length(mem_ram_length), .signed_(mem_ram_signed),
	.addr(mem_ram_addr), .data_i(mem_ram_data_o), .data_o(mem_ram_data_i)
);

pc_reg pc_reg0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.stall_stmt(stall_stmt),
	.ex_pre_fail(ex_pre_fail), .ex_target(ex_target),
	.pre_jmp(pre_jmp), .pre_target(pre_target),
	.pc(pc), .jmp(jmp)
);

IF if0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.pc(pc), .mem_inst(mem_inst), .mem_success(mem_success), .mem_busy(if_mem_busy),
	.mem_pc(mem_pc),
	.pc_o(if_pc_o), .inst_o(if_inst_o),
	.read_mem_flag(read_mem_flag), .read_mem_pc(read_mem_pc),
	.stall_if(stall_if)
);

if_id if_id0(
	.rdy(rdy),
	.clk(clk_in), .rst(rst), .if_pc(if_pc_o), .if_inst(if_inst_o),
	.ex_pre_fail(ex_pre_fail),
	.stall_stmt(stall_stmt),
	.id_pc(id_pc_i), .id_inst(id_inst_i)
);

id id0(
	.rdy(rdy),
	.rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i), .jmp_i(jmp),
	.reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
	.ex_loading(ex_loading_o),
	.ex_wreg_i(ex_wreg_o), .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o), 
	.mem_wreg_i(mem_wreg_o), .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o), 
	.reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
	.reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
	.aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
	.reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
	.wd_o(id_wd_o), .wreg_o(id_wreg_o),
	.pc_o(id_pc_o), .jmp_o(id_jmp_o), .offset_o(id_offset_o),
	.stall_id(stall_id)
);

id_ex id_ex0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.id_aluop(id_aluop_o), .id_alusel(id_alusel_o), 
	.id_reg1(id_reg1_o), .id_reg2(id_reg2_o), 
	.id_wd(id_wd_o), .id_wreg(id_wreg_o), 
	.id_pc(id_pc_o), .offset_i(id_offset_o), .jmp_i(id_jmp_o), .jmp_o(ex_jmp_i),
	.ex_pre_fail(ex_pre_fail),
	.stall_stmt(stall_stmt),
	
	.ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i), 
	.ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i), 
	.ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i),
	.ex_pc(ex_pc), .offset_o(ex_offset_i)
);


ex ex0(//aluop_o not link!!!
	.rst(rst),  .rdy(rdy),
	.aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i), 
	.reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i), 
	.wd_i(ex_wd_i), .wreg_i(ex_wreg_i), 
	.pc_i(ex_pc), .jmp_i(ex_jmp_i), .offset_i(ex_offset_i),
	.wd_o(ex_wd_o), .wreg_o(ex_wreg_o), .wdata_o(ex_wdata_o),
	.mem_addr_o(ex_mem_addr_o), .loading(ex_loading_o), .storing(ex_storing_o),
	.mem_length(ex_mem_length_o), .mem_signed(ex_mem_signed_o), 
	.pre_fail(ex_pre_fail), .branch_target(ex_target),
	.jmp_type(ex_jmp_type), .jmp_target(ex_jmp_target), .jmp_o(ex_jmp)
);

ex_mem ex_mem0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o), .ex_wdata(ex_wdata_o),
	.load_i(ex_loading_o), .store_i(ex_storing_o), 
	.mem_addr_i(ex_mem_addr_o), .mem_write_data_i(ex_wdata_o),
	.mem_length_i(ex_mem_length_o), .mem_signed_i(ex_mem_signed_o),
	.stall_stmt(stall_stmt),
	.mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i), .mem_wdata(mem_wdata_i),
	.load_o(mem_load_i), .store_o(mem_store_i),
	.mem_addr_o(mem_addr_i), .mem_write_data_o(mem_write_data_i),
	.mem_length_o(mem_length_i), .mem_signed_o(mem_signed_i)
);

mem mem0(
	.rst(rst), .rdy(rdy),
	.wd_i(mem_wd_i), .wreg_i(mem_wreg_i), .wdata_i(mem_wdata_i), 
	.wd_o(mem_wd_o), .wreg_o(mem_wreg_o), .wdata_o(mem_wdata_o),
	.load(mem_load_i), .store(mem_store_i),
	.addr(mem_addr_i), .data(mem_write_data_i),
	.length(mem_length_i), .signed_(mem_signed_i),
	.ram_ready(mem_ram_ready), .ram_addr(mem_ram_addr),
	.ram_data_i(mem_ram_data_i), .ram_data_o(mem_ram_data_o),
	.ram_length(mem_ram_length), .ram_signed(mem_ram_signed),
	.ram_read(mem_ram_read), .ram_write(mem_ram_write),
	.stall_mem(stall_mem)
);

mem_wb mem_wb0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o), .mem_wdata(mem_wdata_o), 
	.stall_stmt(stall_stmt),
	.wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i), .wb_wdata(wb_wdata_i)
);

regfile regfile0(	//why not regfile0?
	.clk(clk_in), .rst(rst), .we(wb_wreg_i), .waddr(wb_wd_i), .wdata(wb_wdata_i),  .rdy(rdy),
	.re1(reg1_read), .raddr1(reg1_addr), .rdata1(reg1_data), 
	.re2(reg2_read), .raddr2(reg2_addr), .rdata2(reg2_data)
);

predictor predictor0(
	.clk(clk_in), .rst(rst), .rdy(rdy),
	.pc(pc), .pre_jmp(pre_jmp), .pre_target(pre_target),
	.ex_pc(ex_pc), .ex_jmp_type(ex_jmp_type), .ex_jmp_target(ex_jmp_target), .ex_jmp(ex_jmp)
);
	
endmodule