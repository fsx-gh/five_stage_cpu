`timescale 1ns / 1ps
`include "define.v"

module alu (
    input wire [9:0] alu_op, 
    input wire [31:0] dataIn1, dataIn2,
    
    output reg [31:0] alu_result
);

    always @(*) begin
        case(alu_op)
            `ALU_AND: alu_result <= dataIn1 & dataIn2;
            `ALU_OR:  alu_result <= dataIn1 | dataIn2;
            `ALU_XOR: alu_result <= dataIn1 ^ dataIn2;
            `ALU_SLL: alu_result <= dataIn1 << dataIn2;
            `ALU_SRA: alu_result <= ($signed(dataIn1)) >>> dataIn2;
            `ALU_SRL: alu_result <= dataIn1 >> dataIn2;
            `ALU_SLT: alu_result <= (dataIn1 < dataIn2)?32'd1:32'd0;
            
            `ALU_ADD: alu_result <= dataIn1 + dataIn2;
            `ALU_SUB: alu_result <= dataIn1 - dataIn2;
            default: alu_result <= 32'b0;
        endcase
    end
endmodule
