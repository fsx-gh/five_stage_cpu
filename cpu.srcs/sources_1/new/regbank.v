`timescale 1ns / 1ps
`include "define.v"

module regbank (
    input wire clk, we_REGSin,          
    input wire [4:0] rs1_REGSin, rs2_REGSin, rd_REGSin,
    input wire [31:0] data_REGSin,

    output reg [31:0] rs1_data_REGSout, rs2_data_REGSout    
);
 
    reg [31:0] regs [31:0];

    initial begin
        regs[0] <= 32'b0;

        regs[1] <= 32'd1; 
        regs[2] <= 32'd2;
        regs[3] <= 32'd3;
        regs[4] <= 32'd4;
        regs[5] <= 32'd5;
        regs[6] <= 32'd6;
        regs[7] <= 32'd7;
        regs[8] <= 32'd8;
    end


    always @(*) begin
        rs1_data_REGSout <= regs[rs1_REGSin];
        rs2_data_REGSout <= regs[rs2_REGSin];
    end

    always @(negedge clk) begin
        if ((we_REGSin !== 1'bx) && (we_REGSin == 1'b1) && (rd_REGSin != 5'b0)) begin
            regs[rd_REGSin] <= data_REGSin;
        end
    end
endmodule
