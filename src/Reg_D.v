module Reg_D(
    input             clk,
    input             rst,
    input             stall,
    input             jb,
    input      [31:0] pc_in,
    input      [31:0] inst_in,
    output reg [31:0] pc_out,
    output reg [31:0] inst_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_out   <= 32'd0;
        inst_out <= 32'd0;
    end
    else begin
        if (stall) begin
            pc_out   <= pc_out;
            inst_out <= inst_out;
        end
        else if (!jb) begin
            pc_out   <= 32'd0;                    // If control hazard, it will execute NOP, so it doesn't matter what pc_out is ???
            inst_out <= 32'h00000013;
        end
        else begin
            pc_out   <= pc_in;
            inst_out <= inst_in;
        end
    end
end
endmodule