`include "./include.v"

module LD_Filter (
    input      [2:0]  func3,
    input      [31:0] ld_data,
    output reg [31:0] ld_data_f
);

always @(*) begin
    case (func3)
        `BYTE : ld_data_f <= {{24{ld_data[7]}} , ld_data[7:0]};
        `HALF : ld_data_f <= {{16{ld_data[15]}}, ld_data[15:0]};
        `WORD : ld_data_f <= ld_data;
        `B_UN : ld_data_f <= {24'b0, ld_data[7:0]};
        `H_UN : ld_data_f <= {16'b0, ld_data[15:0]};
    endcase
end
endmodule