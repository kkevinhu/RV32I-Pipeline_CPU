module Imme_Ext(
    input  [31:0] inst,
    output reg[31:0] imme_ext_out
);

always @(*) begin
    case (inst[6:2])
        5'b00100, 5'b00000, 5'b11001 : imme_ext_out <= {{20{inst[31]}}, inst[31:20]};
        5'b01000 :                     imme_ext_out <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
        5'b11000 :                     imme_ext_out <= {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        5'b01101, 5'b00101 :           imme_ext_out <= {inst[31:12], 12'b0};
        5'b11011 :                     imme_ext_out <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    endcase
end
endmodule

/*
R : 01100
I : 00100 00000 11001
S : 01000 
B : 11000
U : 01101 00101
J : 11011
*/