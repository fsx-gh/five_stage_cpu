`timescale 1ns / 1ps
`include "define.v"

module sign_extend_imm20 (
    input wire [19:0] imm,         
      
    output reg [31:0] sign_extend_imm
);

    always @(*) begin
        sign_extend_imm <= {{12{imm[19]}}, imm};
    end
endmodule
