module Adder(
    input  [31:0] A,
    output [31:0] C
);
assign C = A + 32'd4;
endmodule