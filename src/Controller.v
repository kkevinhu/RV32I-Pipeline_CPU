module Controller(
    input        clk,
    input        rst,
    input [23:0] D_out,
    input        b,
    output       stall,
    output reg   next_pc_sel,
    // Fetch
    output [3:0] F_im_w_en,
    // Decode
    output       D_rs1_data_sel,
    output       D_rs2_data_sel,
    // Execute
    output [1:0] E_rs1_data_sel,
    output [1:0] E_rs2_data_sel,
    output reg   E_alu_op1_sel,
    output reg   E_alu_op2_sel,
    output reg   E_jb_op1_sel,
    output [4:0] E_op_out,
    output [2:0] E_f3_out,
    output       E_f7_out,
    // Memory
    output reg [3:0] M_dm_w_en,
    // Write back
    output reg   W_wb_en,
    output [4:0] W_rd_index,
    output [2:0] W_f3_out,
    output reg   W_wb_data_sel
);

reg [4:0] E_op, M_op, W_op;
reg [2:0] E_f3, M_f3, W_f3;
reg [4:0] E_rd, M_rd, W_rd;
reg [4:0] E_rs1, E_rs2;
reg       E_f7;

wire is_D_rs1_W_rd_overlap, is_D_use_rs1;
wire is_D_rs2_W_rd_overlap, is_D_use_rs2;

wire is_E_rs1_W_rd_overlap, is_E_rs1_M_rd_overlap, is_E_use_rs1;
wire is_E_rs2_W_rd_overlap, is_E_rs2_M_rd_overlap, is_E_use_rs2;

wire is_M_use_rd;
wire is_W_use_rd;

wire is_DE_overlap, is_D_rs1_E_rd_overlap, is_D_rs2_E_rd_overlap;

assign stall                 = (E_op ==  5'b00000) & is_DE_overlap;
assign is_DE_overlap         = (is_D_rs1_E_rd_overlap | is_D_rs2_E_rd_overlap);
assign is_D_rs1_E_rd_overlap = is_D_use_rs1 & (D_out[17:13] == E_rd) & E_rd != 0;
assign is_D_rs2_E_rd_overlap = is_D_use_rs2 & (D_out[22:18] == E_rd) & E_rd != 0;

assign is_D_use_rs1          = (D_out[4:0] == 5'b01101 || D_out[4:0] == 5'b00101 || D_out[4:0] == 5'b11011) ? 1'b0 : 1'b1;
assign is_D_use_rs2          = (D_out[4:0] == 5'b01100 || D_out[4:0] == 5'b01000 || D_out[4:0] == 5'b11000) ? 1'b1 : 1'b0;
assign is_M_use_rd = (M_op == 5'b01000 || M_op == 5'b11000) ? 1'b0 : 1'b1;
assign is_W_use_rd = (W_op == 5'b01000 || W_op == 5'b11000) ? 1'b0 : 1'b1;

assign F_im_w_en = 4'd0;

assign D_rs1_data_sel        = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
assign is_D_rs1_W_rd_overlap = is_D_use_rs1 & is_W_use_rd & (D_out[17:13] == W_rd) & W_rd != 0;

assign D_rs2_data_sel        = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;
assign is_D_rs2_W_rd_overlap = is_D_use_rs2 & is_W_use_rd & (D_out[22:18] == W_rd) & W_rd != 0;

assign E_op_out = E_op;
assign E_f3_out = E_f3;
assign E_f7_out = E_f7;

assign E_rs1_data_sel        = is_E_rs1_M_rd_overlap ? 2'd1 : is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2;
assign is_E_rs1_W_rd_overlap = is_E_use_rs1 & is_W_use_rd & (E_rs1 == W_rd) & W_rd != 0;
assign is_E_rs1_M_rd_overlap = is_E_use_rs1 & is_M_use_rd & (E_rs1 == M_rd) & M_rd != 0;
assign is_E_use_rs1          = (E_op == 5'b01101 || E_op == 5'b00101 || E_op == 5'b11011) ? 1'b0 : 1'b1;

assign E_rs2_data_sel        = is_E_rs2_M_rd_overlap ? 2'd1 : is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2;
assign is_E_rs2_W_rd_overlap = is_E_use_rs2 & is_W_use_rd & (E_rs2 == W_rd) & W_rd != 0;
assign is_E_rs2_M_rd_overlap = is_E_use_rs2 & is_M_use_rd & (E_rs2 == M_rd) & M_rd != 0;
assign is_E_use_rs2          = (E_op == 5'b01100 || E_op == 5'b01000 || E_op == 5'b11000) ? 1'b0 : 1'b1;

assign W_rd_index = W_rd;
assign W_f3_out   = W_f3;

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

always @(*) begin
    if (stall) begin
        E_op  <= 5'b00100;
        E_rd  <= 5'd0;
        E_rs1 <= 5'd0;
        E_rs2 <= 5'd0;
    end
end

always @(*) begin
    case (E_op) 
        5'b01100 : begin        // R type
            next_pc_sel   <= 1'b1;
            E_jb_op1_sel  <= 1'bx;
            E_alu_op1_sel <= 0;
            E_alu_op2_sel <= 0;
        end
        5'b00100 : begin        // immediate
            next_pc_sel   <= 1'b1;
            E_jb_op1_sel <= 1'bx;
            E_alu_op1_sel <= 0;
            E_alu_op2_sel <= 1;
        end
        5'b00000 : begin         // load
            next_pc_sel   <= 1'b1;
            E_jb_op1_sel <= 1'bx;
            E_alu_op1_sel <= 0;
            E_alu_op2_sel <= 1;
        end
        5'b11001 : begin       // jalr
            next_pc_sel   <= 1'b0;
            E_jb_op1_sel <= 0;
            E_alu_op1_sel <= 1;
            E_alu_op2_sel <= 1'bx; 
        end
        5'b01000 : begin       // store
            next_pc_sel   <= 1'b1;
            E_jb_op1_sel <= 1'bx;
            E_alu_op1_sel <= 0;
            E_alu_op2_sel <= 1;
        end
        5'b11000 : begin      // branch
            next_pc_sel   <= !b;
            E_jb_op1_sel <= 1'b1;
            E_alu_op1_sel <= 0;
            E_alu_op2_sel <= 0;
        end
        5'b01101 : begin      // lui
            next_pc_sel   <= 1'b1;
            E_jb_op1_sel <= 1'bx;
            E_alu_op1_sel <= 1'bx;
            E_alu_op2_sel <= 1;
        end
        5'b00101 : begin      // auipc
            next_pc_sel   <= 1'b1;
            E_jb_op1_sel <= 1'bx;
            E_alu_op1_sel <= 1;
            E_alu_op2_sel <= 1;
        end
        5'b11011 : begin      // jal
            next_pc_sel   <= 1'b0;
            E_jb_op1_sel <= 1'b1;
            E_alu_op1_sel <= 1;
            E_alu_op2_sel <= 1'bx; 
        end
    endcase
end

always @(*) begin
    case (M_op) 
        5'b01000 : begin
            case (M_f3)
                3'b000 : M_dm_w_en <= 4'b0001; // sb
                3'b001 : M_dm_w_en <= 4'b0011; // sh
                3'b010 : M_dm_w_en <= 4'b1111; // sw
            endcase
        end
        default : M_dm_w_en <= 4'd0;
    endcase
end

always @(*) begin
    case (W_op)
        5'b01100 : begin        // R type
            W_wb_en <= 1;
            W_wb_data_sel <= 0;
        end
        5'b00100 : begin        // immediate
            W_wb_en <= 1;
            W_wb_data_sel <= 0;
        end
        5'b00000 : begin         // load
            W_wb_en <= 1;
            W_wb_data_sel <= 1;
        end
        5'b11001 : begin       // jalr
            W_wb_en <= 1;
            W_wb_data_sel <= 0;
        end
        5'b01000 : begin       // store
            W_wb_en <= 0;
            W_wb_data_sel <= 1'bx;
        end
        5'b11000 : begin      // branch
            W_wb_en <= 0;
            W_wb_data_sel <= 1'bx;
        end
        5'b01101 : begin      // lui
            W_wb_en <= 1;
            W_wb_data_sel <= 0;
        end
        5'b00101 : begin      // auipc
            W_wb_en <= 1;
            W_wb_data_sel <= 0;
        end
        5'b11011 : begin      // jal
            W_wb_en <= 1;
            W_wb_data_sel <= 0;
        end
    endcase
end
endmodule 

/* opcode
R : 01100
I : 00100 00000 11001
S : 01000 
B : 11000
U : 01101 00101
J : 11011
*/