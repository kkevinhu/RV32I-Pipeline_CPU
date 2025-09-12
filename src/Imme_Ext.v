`include "./include.v"

module Imme_Ext(
    input  [31:0] inst,
    output reg[31:0] imme_ext_out
);

always @(*) begin
    case (inst[6:2])
        `IMME, `LOAD, `JALR : imme_ext_out <= {{20{inst[31]}}, inst[31:20]};
        `STORE : imme_ext_out <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
        `BRANCH : imme_ext_out <= {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        `LUI, `AUIPC : imme_ext_out <= {inst[31:12], 12'b0};
        `JAL :  imme_ext_out <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    endcase
end
endmodule