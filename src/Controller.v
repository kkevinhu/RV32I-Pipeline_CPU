`include "./include.v"

module Controller(
    input        clk,
    input        rst,
    input [23:0] D_out,
    input        b,
    output       stall,
    output       next_pc_sel,
    // Fetch
    output [3:0] F_im_w_en,
    // Decode
    output       D_rs1_data_sel,
    output       D_rs2_data_sel,
    // Execute
    output [1:0] E_rs1_data_sel,
    output [1:0] E_rs2_data_sel,
    output       E_alu_op1_sel,
    output       E_alu_op2_sel,
    output       E_jb_op1_sel,
    output [4:0] E_op_out,
    output [2:0] E_f3_out,
    output       E_f7_out,
    // Memory
    output reg [3:0] M_dm_w_en,
    // Write back
    output       W_wb_en,
    output [4:0] W_rd_index,
    output [2:0] W_f3_out,
    output       W_wb_data_sel
);

//------------------------------------------------------------------------------------------------------------------------------
// RIGSTER
//------------------------------------------------------------------------------------------------------------------------------
reg [4:0] E_op, M_op, W_op;
reg [2:0] E_f3, M_f3, W_f3;
reg [4:0] E_rd, M_rd, W_rd;
reg [4:0] E_rs1, E_rs2;
reg       E_f7;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        E_op <= 5'd0;
        E_f3 <= 3'd0;
        E_rd <= 5'd0;
        E_rs1 <= 5'd0;
        E_rs2 <= 5'd0;
        E_f7  <= 1'd0;
        M_op <= 5'd0;
        M_f3 <= 3'd0;
        M_rd <= 5'd0;
        W_op <= 5'd0;
        W_f3 <= 3'd0;
        W_rd <= 5'd0;
    end
    else if (stall) begin
        E_op  <= `NOP;
        E_rd  <= 5'd0;
        E_rs1 <= 5'd0;
        E_rs2 <= 5'd0;
        M_op <= E_op;
        M_f3 <= E_f3;
        M_rd <= E_rd;
        W_op <= M_op;
        W_f3 <= M_f3;
        W_rd <= M_rd;
    end
    else if (E_op == `JALR || E_op == `JAL || (b && E_op == `BRANCH)) begin
        E_op  <= `NOP;
        E_rd  <= 5'd0;
        E_rs1 <= 5'd0;
        E_rs2 <= 5'd0;
        M_op <= E_op;
        M_f3 <= E_f3;
        M_rd <= E_rd;
        W_op <= M_op;
        W_f3 <= M_f3;
        W_rd <= M_rd;
    end
    else begin
        E_op  <= D_out[4:0];
        E_rd  <= D_out[9:5];
        E_f3  <= D_out[12:10];
        E_rs1 <= D_out[17:13];
        E_rs2 <= D_out[22:18];
        E_f7  <= D_out[23];
        M_op <= E_op;
        M_f3 <= E_f3;
        M_rd <= E_rd;
        W_op <= M_op;
        W_f3 <= M_f3;
        W_rd <= M_rd;
    end
end

//------------------------------------------------------------------------------------------------------------------------------
// WIRE
//------------------------------------------------------------------------------------------------------------------------------
wire is_D_rs1_W_rd_overlap, is_D_use_rs1;
wire is_D_rs2_W_rd_overlap, is_D_use_rs2;
wire is_DE_overlap, is_D_rs1_E_rd_overlap, is_D_rs2_E_rd_overlap;

wire is_E_rs1_W_rd_overlap, is_E_rs1_M_rd_overlap, is_E_use_rs1;
wire is_E_rs2_W_rd_overlap, is_E_rs2_M_rd_overlap, is_E_use_rs2;

wire is_M_use_rd;
wire is_W_use_rd;

//------------------------------------------------------------------------------------------------------------------------------
// STALL
//------------------------------------------------------------------------------------------------------------------------------
assign stall                 = (E_op ==  `LOAD) & is_DE_overlap;
assign is_DE_overlap         = (is_D_rs1_E_rd_overlap | is_D_rs2_E_rd_overlap);
assign is_D_rs1_E_rd_overlap = is_D_use_rs1 & (D_out[17:13] == E_rd) & E_rd != 0;
assign is_D_rs2_E_rd_overlap = is_D_use_rs2 & (D_out[22:18] == E_rd) & E_rd != 0;

assign is_D_use_rs1          = (D_out[4:0] == `LUI    || D_out[4:0] == `AUIPC || D_out[4:0] == `JAL)    ? 1'b0 : 1'b1;
assign is_D_use_rs2          = (D_out[4:0] == `R_TYPE || D_out[4:0] == `STORE || D_out[4:0] == `BRANCH) ? 1'b1 : 1'b0;

assign is_M_use_rd = (M_op == `STORE || M_op == `BRANCH) ? 1'b0 : 1'b1;
assign is_W_use_rd = (W_op == `STORE || W_op == `BRANCH) ? 1'b0 : 1'b1;

//------------------------------------------------------------------------------------------------------------------------------
// FETCH
//------------------------------------------------------------------------------------------------------------------------------
assign F_im_w_en = 4'd0;

//------------------------------------------------------------------------------------------------------------------------------
// DECODE
//------------------------------------------------------------------------------------------------------------------------------
assign D_rs1_data_sel        = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
assign is_D_rs1_W_rd_overlap = is_D_use_rs1 & is_W_use_rd & (D_out[17:13] == W_rd) & W_rd != 0;

assign D_rs2_data_sel        = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;
assign is_D_rs2_W_rd_overlap = is_D_use_rs2 & is_W_use_rd & (D_out[22:18] == W_rd) & W_rd != 0;

//------------------------------------------------------------------------------------------------------------------------------
// EXECUTE
//------------------------------------------------------------------------------------------------------------------------------
assign E_op_out = E_op;
assign E_f3_out = E_f3;
assign E_f7_out = E_f7;

assign E_rs1_data_sel        = is_E_rs1_M_rd_overlap ? 2'd1 : is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2;
assign is_E_rs1_W_rd_overlap = is_E_use_rs1 & is_W_use_rd & (E_rs1 == W_rd) & W_rd != 0;
assign is_E_rs1_M_rd_overlap = is_E_use_rs1 & is_M_use_rd & (E_rs1 == M_rd) & M_rd != 0;
assign is_E_use_rs1          = (E_op == `LUI || E_op == `AUIPC || E_op == `JAL) ? 1'b0 : 1'b1;

assign E_rs2_data_sel        = is_E_rs2_M_rd_overlap ? 2'd1 : is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2;
assign is_E_rs2_W_rd_overlap = is_E_use_rs2 & is_W_use_rd & (E_rs2 == W_rd) & W_rd != 0;
assign is_E_rs2_M_rd_overlap = is_E_use_rs2 & is_M_use_rd & (E_rs2 == M_rd) & M_rd != 0;
assign is_E_use_rs2          = (E_op == `R_TYPE || E_op == `STORE || E_op == `BRANCH) ? 1'b1 : 1'b0;

assign next_pc_sel   = (E_op == `BRANCH) ? !b : (E_op == `JALR || E_op == `JAL) ? 1'b0 : 1'b1;
assign E_jb_op1_sel  = (E_op == `BRANCH || E_op == `JAL) ? 1'b1 : 1'b0;
assign E_alu_op1_sel = (E_op == `JALR || E_op == `JAL || E_op == `AUIPC) ? 1'b1 : 1'b0;
assign E_alu_op2_sel = (E_op == `R_TYPE || E_op == `JALR || E_op == `BRANCH || E_op == `JAL) ? 1'b0 : 1'b1;

//------------------------------------------------------------------------------------------------------------------------------
// MEMORY
//------------------------------------------------------------------------------------------------------------------------------
always @(*) begin
    case (M_op) 
        `STORE : begin
            case (M_f3)
                `BYTE : M_dm_w_en <= 4'b0001; 
                `HALF : M_dm_w_en <= 4'b0011;
                `WORD : M_dm_w_en <= 4'b1111;
            endcase
        end
        default : M_dm_w_en <= 4'd0;
    endcase
end

//------------------------------------------------------------------------------------------------------------------------------
// WRITE_BACK
//------------------------------------------------------------------------------------------------------------------------------
assign W_rd_index = W_rd;
assign W_f3_out   = W_f3;

assign W_wb_en = (W_op == `STORE || W_op == `BRANCH) ? 1'b0 : 1'b1;
assign W_wb_data_sel = (W_op == `LOAD) ? 1'b1 : 1'b0;

endmodule