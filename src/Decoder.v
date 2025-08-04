module Decoder(
    input [31:0] inst,
    output [23:0] decoder_out,
    output [4:0] dc_out_rs1_index,
    output [4:0] dc_out_rs2_index
);

assign decoder_out = {inst[30], inst[24:2]};
assign dc_out_rs1_index = inst[19:15];
assign dc_out_rs2_index = inst[24:20];

endmodule