`timescale 1ns / 1ps
`include "define.v"

module SignedDivider (
    input wire clk, alu_operating_MUL_DIVin,            // 时钟信号
    input wire [9:0] opcode_DIVin,                      // 操作码
    input wire[31:0] dividend_DIVin,
    input wire[31:0] divisor_DIVin,
    
    output reg[31:0] quotient_SIGNEDDIVIDERout,
    output reg[31:0] remainder_SIGNEDDIVIDERout,
    output reg done_signal_SIGNEDDIVIDERout  
);

    reg [5:0] count;
    reg [31:00] reg_q;
    reg [31:00] reg_r;
    reg [31:00] reg_b;
    reg [31:00] reg_dividend,reg_divisor;
    wire [31:00] reg_r2;
    reg r_sign;
    wire [32:0] sub_add=r_sign?({reg_r,reg_q[31]}+{1'b0,reg_b}):
                                ({reg_r,reg_q[31]}-{1'b0,reg_b});
    assign reg_r2=r_sign?reg_r+reg_b:reg_r;
    
    always @(*)begin
        if(done_signal_SIGNEDDIVIDERout == 1'b1)begin
            remainder_SIGNEDDIVIDERout <= reg_dividend[31]?(~reg_r2+1):reg_r2;
            quotient_SIGNEDDIVIDERout <= (reg_divisor[31]^reg_dividend[31])?(~reg_q+1):reg_q;
        end
        else begin
            remainder_SIGNEDDIVIDERout <= 0;
            quotient_SIGNEDDIVIDERout <= 0;
        end
    end
    
    reg operating;
    initial begin
        operating <= 1'b0;
    end
    
    always @(posedge clk)begin
    if(!operating) begin
        if (alu_operating_MUL_DIVin) begin
            
        end
        else if(opcode_DIVin==`ALU_DIV || opcode_DIVin==`ALU_REM )begin
            reg_dividend <= dividend_DIVin;
            reg_divisor <= divisor_DIVin;
            reg_r<=32'b0;
            r_sign<=0;
            if(dividend_DIVin[31]==1) begin
                reg_q<=~dividend_DIVin+1;
            end
            else reg_q<=dividend_DIVin;
            if(divisor_DIVin[31]==1)begin
                reg_b<=~divisor_DIVin+1;
            end
            else reg_b<=divisor_DIVin;
            count<=0;
            operating<=1;
            done_signal_SIGNEDDIVIDERout<=0;
        end
        else begin
            done_signal_SIGNEDDIVIDERout <= 1'b1;
        end
    end 
    else begin
            reg_r<=sub_add[31:0];
            r_sign<=sub_add[32];
            reg_q<={reg_q[30:0],~sub_add[32]};
            count<=count+1;
            if(count==31)begin 
                operating<=0;
                done_signal_SIGNEDDIVIDERout<=1'b1;
            end
        end
    end    

endmodule
