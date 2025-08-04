`include "./src/Adder.v"
`include "./src/ALU.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/Imme_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/Mux.v"
`include "./src/Reg_PC.v"
`include "./src/RegFile.v"
`include "./src/SRAM.v"

module Top (
    input clk,
    input rst
);

wire func7;
wire [2:0] func3;
wire [4:0] opcode, rs1_index, rs2_index, rd_index;

wire [31:0] pc_add_four;
wire [31:0] write_data, rs1_data, rs2_data, wb_data;
wire [31:0] alu_out, alu_op1, alu_op2;
wire [31:0] ld_data, ld_data_f;
wire [31:0] jb_op1, jb_out;
wire [31:0] current_pc, inst, imme;

wire       wb_en;
wire       next_pc_sel;
wire       jb_op1_sel;
wire       alu_op1_sel;
wire       alu_op2_sel;
wire       wb_sel;
wire [3:0] im_w_en;
wire [3:0] dm_r_en;
wire [3:0] dm_w_en;
wire [4:0] opcode_;
wire [2:0] func3_;
wire       func7_;

Controller controller(
    .opcode(opcode), .func3(func3), .func7(func7), .b(alu_out[0]),
    .next_pc_sel(next_pc_sel), .im_w_en(im_w_en), .wb_en(wb_en), .jb_op1_sel(jb_op1_sel),
    .alu_op1_sel(alu_op1_sel), .alu_op2_sel(alu_op2_sel), .wb_sel(wb_sel),
    .dm_w_en(dm_w_en),
    .opcode_(opcode_), .func3_(func3_), .func7_(func7_)
);

Adder adder(.A(current_pc), .C(pc_add_four));

Reg_PC reg_pc(.clk(clk), .rst(rst), .branch(next_pc_sel), .jb_pc(jb_out), .current_pc(current_pc));

SRAM im (.clk(clk), .w_en(4'b0000), .address(current_pc[15:0]), .write_data(write_data), .read_data(inst));

Decoder decoder(
    .inst(inst), .dc_out_opcode(opcode), .dc_out_func3(func3), .dc_out_func7(func7), 
    .dc_out_rs1_index(rs1_index), .dc_out_rs2_index(rs2_index), .dc_out_rd_index(rd_index)
);

Imme_Ext imme_ext(.inst(inst), .imme_ext_out(imme));

RegFile reg_file(
    .clk(clk), .wb_en(wb_en), .wb_data(wb_data), .rd_index(rd_index), .rs1_index(rs1_index), .rs2_index(rs2_index), 
    .rs1_data_out(rs1_data), .rs2_data_out(rs2_data)
);

Mux mux_alu_op1(.sel(alu_op1_sel), .A(rs1_data), .B(current_pc), .out(alu_op1));

Mux mux_alu_op2(.sel(alu_op2_sel), .A(rs2_data), .B(imme), .out(alu_op2));

ALU alu(.opcode(opcode_), .func3(func3_), .func7(func7_), .operand1(alu_op1), .operand2(alu_op2), .alu_out(alu_out));

Mux mux_jb_op1(.sel(jb_op1_sel), .A(rs1_data), .B(current_pc), .out(jb_op1));

JB_Unit jb_unit(.operand1(jb_op1), .operand2(imme), .jb_out(jb_out));

SRAM dm(.clk(clk), .w_en(dm_w_en), .address(alu_out[15:0]), .write_data(rs2_data), .read_data(ld_data));

LD_Filter ld_filter(.func3(func3_), .ld_data(ld_data), .ld_data_f(ld_data_f));

Mux mux_wb_data(.sel(wb_sel), .A(alu_out), .B(ld_data_f), .out(wb_data));

endmodule