module Mux(
    input sel,
    input  [31:0] A,
    input  [31:0] B,
    output reg [31:0] out
);
always @(*) begin
    case (sel)
        1'b0 : out <= A;
        1'b1 : out <= B;
    endcase
end
endmodule