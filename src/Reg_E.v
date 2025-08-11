module Reg_E(
    input             clk,
    input             rst,
    input             stall,
    input             jb,
    input      [31:0] pc_in,
    input      [31:0] rs1_data_in,
    input      [31:0] rs2_data_in,
    input      [31:0] sext_imme_in,
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] sext_imme_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_out        <= 32'd0;
        rs1_data_out  <= 32'd0;
        rs2_data_out  <= 32'd0;
        sext_imme_out <= 32'd0;
    end
    else begin
        if (stall || !jb) begin
            pc_out        <= 32'd0;
            rs1_data_out  <= 32'd0;
            rs2_data_out  <= 32'd0;
            sext_imme_out <= 32'd0;
        end
        else begin
            pc_out        <= pc_in;
            rs1_data_out  <= rs1_data_in;
            rs2_data_out  <= rs2_data_in;
            sext_imme_out <= sext_imme_in;
        end
    end
end
endmodule