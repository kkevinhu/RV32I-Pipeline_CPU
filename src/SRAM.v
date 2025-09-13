module SRAM (
    input clk,
    input  [3:0]  w_en,
    input  [15:0] address,
    input  [31:0] write_data,
    output reg[31:0] read_data
);

reg [7:0] mem [0:65535];


always @(posedge clk) begin
    case (w_en)
        4'b0001 : begin // Store Byte
            mem[address] <= write_data[7:0];
        end 
        4'b0011 : begin // Store Halfword
            mem[address  ] <= write_data[7:0];
            mem[address+1] <= write_data[15:8];
        end 
        4'b1111 : begin // Store Word
            mem[address  ] <= write_data[7:0];
            mem[address+1] <= write_data[15:8];
            mem[address+2] <= write_data[23:16];
            mem[address+3] <= write_data[31:24];
        end
    endcase
end

always @(*) begin
    if (w_en == 4'b0000)
        read_data <= {mem[address+3], mem[address+2], mem[address+1], mem[address]};
end
endmodule