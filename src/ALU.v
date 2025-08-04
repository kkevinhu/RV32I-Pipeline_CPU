module ALU (
    input      [4:0]  opcode,   //inst[6:2]
    input      [2:0]  func3,
    input             func7,
    input      [31:0] operand1,
    input      [31:0] operand2,
    output reg [31:0] alu_out
);

always @(*) begin
    case (opcode)
        5'b01100, 5'b00100 : begin         // R type & I type(immediate)
            case (func3)
                3'b000 : begin
                    if (opcode == 5'b01100)
                        alu_out <= (func7) ? (operand1 - operand2) : (operand1 + operand2);
                    else
                        alu_out <= operand1 + operand2;
                end
                3'b001 : alu_out <= operand1 << operand2[4:0]; 
                3'b010 : alu_out <= $signed(operand1)   < $signed(operand2);
                3'b011 : alu_out <= $unsigned(operand1) < $unsigned(operand2);
                3'b100 : alu_out <= operand1 ^ operand2;
                3'b101 : alu_out <= (func7) ? $signed(($signed(operand1) >>> operand2[4:0])) : (operand1 >> operand2[4:0]);
                3'b110 : alu_out <= operand1 | operand2;
                3'b111 : alu_out <= operand1 & operand2;                
            endcase
        end
        5'b00000, 5'b01000 : begin        // I type(load) & S type
            alu_out <= operand1 + operand2;
        end
        5'b11001, 5'b11011 : begin        // I type (jalr) & J type (jal)
            alu_out <= operand1 + 4;
        end
        5'b11000 : begin                 // B type
            case (func3)
                3'b000 : alu_out <= (operand1 == operand2); // beq
                3'b001 : alu_out <= (operand1 != operand2); // bne
                3'b100 : alu_out <= ($signed(operand1)   < $signed(operand2));  // blt
                3'b110 : alu_out <= ($unsigned(operand1) < $unsigned(operand2)); // bltu 
                3'b101 : alu_out <= ($signed(operand1) >= $signed(operand2)); // bge 
                3'b111 : alu_out <= ($unsigned(operand1) >= $unsigned(operand2)); // bgeu
            endcase
        end
        5'b01101 : begin                 // lui
            alu_out <= operand2;
        end
        5'b00101 : begin                // auipc
            alu_out <= operand1 + operand2;
        end
    endcase
end
endmodule

/* opcode
R : 01100
I : 00100 00000 11001
S : 01000 
B : 11000
U : 01101 00101
J : 11011
*/