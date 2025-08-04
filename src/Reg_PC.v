module Reg_PC(
    input clk,
    input rst,
    input branch,
    input stall,
    input      [31:0] jb_pc,
    output reg [31:0] current_pc
);

always @(posedge clk) begin
    if (rst)
        current_pc <= 32'd0;
    else if (stall)
        current_pc <= current_pc;
    else if (!branch)
        current_pc <= jb_pc;
    else if (branch)
        current_pc <= current_pc + 4;
    else
        current_pc <= current_pc;
end

endmodule