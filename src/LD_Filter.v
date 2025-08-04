module LD_Filter (
    input      [2:0]  func3,
    input      [31:0] ld_data,
    output reg [31:0] ld_data_f
);

always @(*) begin
    case (func3)
        3'b000 : ld_data_f <= {{24{ld_data[7]}} , ld_data[7:0]};
        3'b001 : ld_data_f <= {{16{ld_data[15]}}, ld_data[15:0]};
        3'b010 : ld_data_f <= ld_data;
        3'b100 : ld_data_f <= {24'b0, ld_data[7:0]};
        3'b101 : ld_data_f <= {16'b0, ld_data[15:0]};
    endcase
end
endmodule

/*
000 : lb
001 : lh
010 : lw
100 : lbu
101 : lhu
*/