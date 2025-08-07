module Mux3(
    input [1:0]  sel, 
    input [31:0] A, 
    input [31:0] B, 
    input [31:0] C,
    output reg [31:0] out
);

always @(*) begin
    case (sel)
        2'd0 : out <= A;
        2'd1 : out <= B;
        2'd2 : out <= C;
    endcase
end
endmodule