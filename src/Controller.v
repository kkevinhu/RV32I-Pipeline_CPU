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
    output [3:0] M_dm_w_en,
    // Write back
    output       W_wb_en,
    output [4:0] W_rd_index,
    output [2:0] W_f3,
    output       W_wb_data_sel
);

reg [4:0] E_op, M_op, W_op;
reg [2:0] E_f3, M_f3, W_f3;
reg [4:0] E_rd, M_rd, W_rd;
reg [4:0] E_rs1, E_rs2;
reg       E_f7;

wire is_D_rsl_W_rd_overlap, is_D_use_rs1, is_W_use_rd;
wire is_D_rs2_W_rd_overlap, is_D_use_rs2;

assign F_im_w_en = 3'd0;
// assign 


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
        E_f3  <= D_out[12:10];
        E_rd  <= D_out[11:7];
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
endmodule 

// module Controller(
//     input [4:0]  opcode,
//     input [2:0]  func3,
//     input        func7,
//     input        b,
//     output reg       next_pc_sel,
//     output reg  [3:0] im_w_en,
//     output reg       wb_en,
//     output reg       jb_op1_sel,
//     output reg       alu_op1_sel,
//     output reg       alu_op2_sel,
//     output reg       wb_sel,
//     output reg [3:0] dm_w_en,
//     output     [4:0] opcode_,
//     output     [2:0] func3_,
//     output           func7_
// );

// assign opcode_ = opcode;
// assign func3_  = func3;
// assign func7_  = func7;

// always @(*) begin
//     case (opcode)
//         5'b01100 : begin        // R type
//             next_pc_sel <= 1;
//             im_w_en <= 0;
//             wb_en <= 1;
//             jb_op1_sel <= 1'bx;
//             alu_op1_sel <= 0;
//             alu_op2_sel <= 0;
//             wb_sel <= 0;
//             dm_w_en <= 0;
//         end
//         5'b00100 : begin        // immediate
//             next_pc_sel <= 1;
//             im_w_en <= 0;
//             wb_en <= 1;
//             jb_op1_sel <= 1'bx;
//             alu_op1_sel <= 0;
//             alu_op2_sel <= 1;
//             wb_sel <= 0;
//             dm_w_en <= 0;
//         end
//         5'b00000 : begin         // load
//             next_pc_sel <= 1;
//             im_w_en <= 0;
//             wb_en <= 1;
//             jb_op1_sel <= 1'bx;
//             alu_op1_sel <= 0;
//             alu_op2_sel <= 1;
//             wb_sel <= 1;
//             dm_w_en <= 0;
//         end
//         5'b11001 : begin       // jalr
//             next_pc_sel <= 0;
//             im_w_en <= 0;
//             wb_en <= 1;
//             jb_op1_sel <= 0;
//             alu_op1_sel <= 1;
//             alu_op2_sel <= 1'bx; 
//             wb_sel <= 0;
//             dm_w_en <= 0;
//         end
//         5'b01000 : begin       // store
//             next_pc_sel <= 1;
//             im_w_en <= 0;
//             wb_en <= 0;
//             jb_op1_sel <= 1'bx;
//             alu_op1_sel <= 0;
//             alu_op2_sel <= 1;
//             wb_sel <= 1'bx;
//             case (func3)
//                 3'b000 : dm_w_en <= 4'b0001; // sb
//                 3'b001 : dm_w_en <= 4'b0011; // sh
//                 3'b010 : dm_w_en <= 4'b1111; // sw
//             endcase
//         end
//         5'b11000 : begin      // branch
//             next_pc_sel <= !b; 
//             im_w_en <= 0;
//             wb_en <= 0;
//             jb_op1_sel <= 1'b1;
//             alu_op1_sel <= 0;
//             alu_op2_sel <= 0;
//             wb_sel <= 1'bx;
//             dm_w_en <= 0;
//         end
//         5'b01101 : begin      // lui
//             next_pc_sel <= 1;
//             im_w_en <= 0;
//             wb_en <= 1;
//             jb_op1_sel <= 1'bx;
//             alu_op1_sel <= 1'bx;
//             alu_op2_sel <= 1;
//             wb_sel <= 0;
//             dm_w_en <= 0;
//         end
//         5'b00101 : begin      // auipc
//             next_pc_sel <= 1;
//             im_w_en <= 0;
//             wb_en <= 1;
//             jb_op1_sel <= 1'bx;
//             alu_op1_sel <= 1;
//             alu_op2_sel <= 1;
//             wb_sel <= 0;
//             dm_w_en <= 0;
//         end
//         5'b11011 : begin      // jal
//             next_pc_sel <= 0;
//             im_w_en <= 0;
//             wb_en <= 1;
//             jb_op1_sel <= 1'b1;
//             alu_op1_sel <= 1;
//             alu_op2_sel <= 1'bx; 
//             wb_sel <= 0;
//             dm_w_en <= 0;
//         end
//     endcase
// end
// endmodule

/* opcode
R : 01100
I : 00100 00000 11001
S : 01000 
B : 11000
U : 01101 00101
J : 11011
*/