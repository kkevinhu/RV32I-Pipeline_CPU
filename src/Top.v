`include "./src/Adder.v"
`include "./src/ALU.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/Imme_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/Mux.v"
`include "./src/Mux3.v"
`include "./src/Reg_D.v"
`include "./src/Reg_E.v"
`include "./src/Reg_M.v"
`include "./src/Reg_PC.v"
`include "./src/Reg_W.v"
`include "./src/RegFile.v"
`include "./src/SRAM.v"

module Top (
    input clk,
    input rst
);

wire       stall;
wire       next_pc_sel;
wire [3:0] F_im_w_en;
wire       D_rs1_data_sel;
wire       D_rs2_data_sel;
wire [1:0] E_rs1_data_sel;
wire [1:0] E_rs2_data_sel;
wire       E_jb_op1_sel;
wire       E_alu_op1_sel;
wire       E_alu_op2_sel;
wire [4:0] E_op_out;
wire [2:0] E_f3_out;
wire       E_f7_out;
wire [3:0] M_dm_w_en;
wire       W_wb_en;
wire [4:0] W_rd_index;
wire [2:0] W_f3_out;
wire       W_wb_data_sel;

wire [31:0] current_pc, D_pc, E_pc;
wire [31:0] inst, D_inst;
wire [31:0] rs1_data, rs2_data;
wire [31:0] D_rs1_data, D_rs2_data, D_ext_out;
wire [31:0] E_rs1_data, E_rs2_data, E_ext_out;
wire [31:0] E_newest_rs1, E_newest_rs2;
wire [31:0] E_alu_op1, E_alu_op2, E_jb_op1;
wire [31:0] E_alu_out, E_jb_out;
wire [31:0] M_alu_out;
wire [31:0] M_rs2_data;
wire [31:0] M_ld_data;
wire [31:0] W_alu_out;
wire [31:0] W_ld_data, W_ld_data_f;
wire [31:0] W_wb_data;

wire [23:0] D_out;
wire [4:0]  D_rs1_index, D_rs2_index;

Controller controller(
    .clk(clk),
    .rst(rst),
    .D_out(D_out),
    .b(E_alu_out[0]),
    .stall(stall),
    .next_pc_sel(next_pc_sel),
    .F_im_w_en(F_im_w_en),
    .D_rs1_data_sel(D_rs1_data_sel),
    .D_rs2_data_sel(D_rs2_data_sel),
    .E_rs1_data_sel(E_rs1_data_sel),
    .E_rs2_data_sel(E_rs2_data_sel),
    .E_alu_op1_sel(E_alu_op1_sel),
    .E_alu_op2_sel(E_alu_op2_sel),
    .E_jb_op1_sel(E_jb_op1_sel),
    .E_op_out(E_op_out),
    .E_f3_out(E_f3_out),
    .E_f7_out(E_f7_out),
    .M_dm_w_en(M_dm_w_en),
    .W_wb_en(W_wb_en),
    .W_rd_index(W_rd_index),
    .W_f3_out(W_f3_out),
    .W_wb_data_sel(W_wb_data_sel)
);

Reg_PC reg_pc(.clk(clk), .rst(rst), .branch(next_pc_sel), .stall(stall), .jb_pc(E_jb_out), .current_pc(current_pc));

SRAM im(.clk(clk), .w_en(4'b0000), .address(current_pc[15:0]), .write_data(), .read_data(inst));

Reg_D reg_D(
    .clk(clk), .rst(rst), 
    .stall(stall), .jb(next_pc_sel), 
    .pc_in(current_pc), .inst_in(inst), 
    .pc_out(D_pc), .inst_out(D_inst)
);

Decoder decoder(.inst(D_inst), .decoder_out(D_out), .dc_out_rs1_index(D_rs1_index), .dc_out_rs2_index(D_rs2_index));

Imme_Ext imme_ext(.inst(D_inst), .imme_ext_out(D_ext_out));

RegFile reg_file(
    .clk(clk), .wb_en(W_wb_en), .wb_data(W_wb_data), .rd_index(W_rd_index), .rs1_index(D_rs1_index), .rs2_index(D_rs2_index), 
    .rs1_data_out(rs1_data), .rs2_data_out(rs2_data)
);

Mux mux_rs1_DorW(.sel(D_rs1_data_sel), .A(rs1_data), .B(W_wb_data), .out(D_rs1_data));

Mux mux_rs2_DorW(.sel(D_rs2_data_sel), .A(rs2_data), .B(W_wb_data), .out(D_rs2_data));

Reg_E reg_E(
    .clk(clk), .rst(rst), 
    .stall(stall), .jb(next_pc_sel),
    .pc_in(D_pc), .rs1_data_in(D_rs1_data), .rs2_data_in(D_rs2_data), .sext_imme_in(D_ext_out),
    .pc_out(E_pc), .rs1_data_out(E_rs1_data), .rs2_data_out(E_rs2_data), .sext_imme_out(E_ext_out)
);

Mux3 mux_rs1_newest(.sel(E_rs1_data_sel), .A(W_wb_data), .B(M_alu_out), .C(E_rs1_data), .out(E_newest_rs1));

Mux3 mux_rs2_newest(.sel(E_rs2_data_sel), .A(W_wb_data), .B(M_alu_out), .C(E_rs2_data), .out(E_newest_rs2));

Mux mux_alu_op1(.sel(E_alu_op1_sel), .A(E_newest_rs1), .B(E_pc), .out(E_alu_op1));

Mux mux_alu_op2(.sel(E_alu_op2_sel), .A(E_newest_rs2), .B(E_ext_out), .out(E_alu_op2));

ALU alu(.opcode(E_op_out), .func3(E_f3_out), .func7(E_f7_out), .operand1(E_alu_op1), .operand2(E_alu_op2), .alu_out(E_alu_out));

Mux mux_jb_op1(.sel(E_jb_op1_sel), .A(E_newest_rs1), .B(E_pc), .out(E_jb_op1));

JB_Unit jb_unit(.operand1(E_jb_op1), .operand2(E_ext_out), .jb_out(E_jb_out));

Reg_M reg_M(
    .clk(clk), .rst(rst),
    .alu_out_in(E_alu_out), .rs2_data_in(E_newest_rs2),
    .alu_out_out(M_alu_out), .rs2_data_out(M_rs2_data)
);

SRAM dm(.clk(clk), .w_en(M_dm_w_en), .address(M_alu_out[15:0]), .write_data(M_rs2_data), .read_data(M_ld_data));

Reg_W reg_W(
    .clk(clk), .rst(rst),
    .alu_out_in(M_alu_out), .ld_data_in(M_ld_data),
    .alu_out_out(W_alu_out), .ld_data_out(W_ld_data)
);

LD_Filter ld_filter(.func3(W_f3_out), .ld_data(W_ld_data), .ld_data_f(W_ld_data_f));

Mux mux_wb_data(.sel(W_wb_data_sel), .A(W_alu_out), .B(W_ld_data_f), .out(W_wb_data));
endmodule