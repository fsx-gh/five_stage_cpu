`timescale 1ns / 1ps

module sign_extend_imm6(
    input wire [5:0] imm,         
      
    output reg [31:0] sign_extend_imm
    );
    
    always @(*) begin
        sign_extend_imm <= {{26{imm[5]}}, imm};
    end
endmodule
