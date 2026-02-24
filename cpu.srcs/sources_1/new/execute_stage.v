`timescale 1ns / 1ps
`include "define.v"

module execute_stage (
    input wire clk, stall_EXEin,
    input wire [4:0] rd_EXEin,
    input wire [9:0] alu_op_EXEin, 
    input wire [2:0] mem_size_EXEin,
    input wire alu_sel_EXEin, reg_sel_EXEin, beq_EXEin, bne_EXEin, blt_EXEin, bge_EXEin, bltu_EXEin, jmp_EXEin, ld_EXEin, st_EXEin, we_EXEin,
    input wire [31:0] pc_EXEin, rs1_data_EXEin, rs2_data_EXEin, imm_EXEin, pc_prediction_EXEin,
    input wire [6:0] opcode_EXEin,

    output reg [4:0] rd_EXEout,
    output reg [2:0] mem_size_EXEout,
    output reg [31:0] pc_EXEout, branch_target_EXEout, alu_result_EXEout, store_data_EXEout, DATA_DISPLAY, PC_DISPLAY,
    output reg ld_EXEout, st_EXEout, we_EXEout, reg_sel_EXEout,
    output reg jmp_signal_EXEout, flush_pipeline_EXEout, branch_taken_EXEout, alu_operating_EXEout,
    output reg [6:0] opcode_EXEout
);

    reg [6:0] opcode_EXE;
    reg [9:0] alu_op_EXE;
    reg beq_EXE, bne_EXE, bltu_EXE, blt_EXE, bge_EXE, alu_sel_EXE, st_EXE, jmp_EXE;
    reg [31:0] imm_EXE, pc_EXE, rs1_data_EXE, rs2_data_EXE,pc_prediction_EXE;

    wire branch_taken_EXE;
    assign branch_taken_EXE = (jmp_EXE  == 1'b1) ? 1:  
                              (beq_EXE  == 1'b1) ? (alu_result_EXE == 0) : 
                              (bne_EXE  == 1'b1) ? (alu_result_EXE != 0) :
                              (bltu_EXE == 1'b1) ? (alu_result_EXE[31] == 1) :
                              (blt_EXE  == 1'b1) ? (complement_subtraction_result_EXE[31] == 1) :
                              (bge_EXE  == 1'b1) ? (complement_subtraction_result_EXE[31] == 0) : 
                              1'b0;

    wire [31:0] branch_target_EXE, alu_result_EXE, complement_subtraction_result_EXE;
    assign branch_target_EXE = (!branch_taken_EXE) ? (pc_EXE + 4) :
                               (opcode_EXE == `JALR_TYPE) ? ((rs1_data_EXE + imm_EXE)&(~32'b1)) :
                               (pc_EXE + imm_EXE);
                               

    reg is_flush_EXE, alu_operating_EXE;
    initial begin
        is_flush_EXE <= 1'b0;
        alu_operating_EXE <= 1'b0;
    end

    wire alu_operating_MUL_DIVin;
    assign alu_operating_MUL_DIVin = alu_operating_EXE;

    always @(*) begin    
        alu_result_EXEout <= (alu_op_EXE == `ALU_MUL) ? result_MULTIPLIERout :
                             (alu_op_EXE == `ALU_DIV) ? quotient_SIGNEDDIVIDERout :
                             (alu_op_EXE == `ALU_REM) ? remainder_SIGNEDDIVIDERout :
                             alu_result_EXE;
        branch_target_EXEout <= branch_target_EXE;

        DATA_DISPLAY <= is_branch_ins ? branch_target_EXE :
                        st_EXE ? store_data_EXEout :
                        (alu_op_EXE == `ALU_MUL) ? result_MULTIPLIERout :
                        (alu_op_EXE == `ALU_DIV) ? quotient_SIGNEDDIVIDERout :
                        (alu_op_EXE == `ALU_REM) ? remainder_SIGNEDDIVIDERout :
                        alu_result_EXE;
    end

    wire is_branch_ins;
    assign is_branch_ins = beq_EXE || bne_EXE || blt_EXE || bge_EXE || bltu_EXE || jmp_EXE;
    always @(negedge clk) begin
        alu_operating_EXE <= (alu_op_EXE == `ALU_MUL && done_signal_MULTIPLIERout == 1'b0) || 
                             (alu_op_EXE == `ALU_DIV && done_signal_SIGNEDDIVIDERout == 1'b0) ||
                             (alu_op_EXE == `ALU_REM && done_signal_SIGNEDDIVIDERout == 1'b0);

        alu_operating_EXEout <= (alu_op_EXE == `ALU_MUL && done_signal_MULTIPLIERout == 1'b0) || 
                                (alu_op_EXE == `ALU_DIV && done_signal_SIGNEDDIVIDERout == 1'b0) ||
                                (alu_op_EXE == `ALU_REM && done_signal_SIGNEDDIVIDERout == 1'b0);

        branch_taken_EXEout <= branch_taken_EXE;
        jmp_signal_EXEout <= is_branch_ins;
        is_flush_EXE <= is_branch_ins && (branch_target_EXE != pc_prediction_EXE);
        flush_pipeline_EXEout <= is_branch_ins && (branch_target_EXE != pc_prediction_EXE);
    end
    reg [31:0] alu_input_a;
    reg [31:0] alu_input_b;
    
    always @(posedge clk) begin
        if (alu_operating_EXE == 1'b1) begin
            // do nothing for alu operating
        end
        else if (is_flush_EXE == 1'b1 || stall_EXEin == 1'b1) begin   
            PC_DISPLAY <= `NOP_PC;
            opcode_EXEout <= `NOP_TYPE;
            opcode_EXE <= `NOP_TYPE;
            pc_EXEout <= `NOP_PC;
            pc_EXE <= `NOP_PC;

            st_EXE <= 1'b0;
            rd_EXEout <= 5'b0;    
            ld_EXEout <= 1'b0;
            st_EXEout <= 1'b0;
            we_EXEout <= 1'b0;
            reg_sel_EXEout <= 1'b1;
            store_data_EXEout <= 32'b0;
            mem_size_EXEout <= `ONE_WORD;

            beq_EXE <= 1'b0; 
            bne_EXE <= 1'b0; 
            blt_EXE <= 1'b0; 
            bge_EXE <= 1'b0; 
            bltu_EXE <= 1'b0;
            jmp_EXE <= 1'b0;
            imm_EXE <= 32'b0;
            alu_op_EXE <= `ALU_ADD;

            alu_sel_EXE <= 1'b1;
            rs1_data_EXE <= 32'b0;
            rs2_data_EXE <= 32'b0;
        end
        else begin
            PC_DISPLAY <= pc_EXEin;
            opcode_EXEout <= opcode_EXEin;
            opcode_EXE <= opcode_EXEin;
            pc_EXEout <= pc_EXEin;
            ld_EXEout <= ld_EXEin; 
            st_EXEout <= st_EXEin; 
            we_EXEout <= we_EXEin;
            rd_EXEout <= rd_EXEin;
            reg_sel_EXEout <= reg_sel_EXEin;
            mem_size_EXEout <= mem_size_EXEin;
            store_data_EXEout <= rs2_data_EXEin;

            pc_EXE <= pc_EXEin;
            st_EXE <= st_EXEin;
            imm_EXE <= imm_EXEin;
            beq_EXE <= beq_EXEin; 
            bne_EXE <= bne_EXEin; 
            blt_EXE <= blt_EXEin; 
            bge_EXE <= bge_EXEin; 
            bltu_EXE <= bltu_EXEin;
            jmp_EXE <= jmp_EXEin;
            alu_op_EXE <= alu_op_EXEin;
            alu_sel_EXE <= alu_sel_EXEin;
            rs1_data_EXE <= rs1_data_EXEin;
            rs2_data_EXE <= rs2_data_EXEin;
            pc_prediction_EXE <= pc_prediction_EXEin;
            case(opcode_EXEin)
                `LUI_TYPE: begin
                    alu_input_a <= imm_EXEin;
                    alu_input_b <= 32'd12;
                end
                `JAL_TYPE: begin
                    alu_input_a <= pc_EXEin;
                    alu_input_b <= 32'd4;
                end
                `JALR_TYPE: begin
                    alu_input_a <= pc_EXEin;
                    alu_input_b <= 32'd4;
                end
                `AUIPC_TYPE: begin
                    alu_input_a <= pc_EXEin;
                    alu_input_b <= (imm_EXEin << 12);
                end
                default:begin
                    alu_input_a <= rs1_data_EXEin;
                    alu_input_b <= alu_sel_EXEin?rs2_data_EXEin:imm_EXEin;
                end
            endcase
        end
    end

    alu ALU (
        .alu_op(alu_op_EXE),
        .dataIn1(alu_input_a),
        .dataIn2(alu_input_b),
        .alu_result(alu_result_EXE)  
    );

    wire [31:0] rs1_data_complement_EXE, rs2_data_complement_EXE;
    complement COMPLEMENT_RS1_DATA (
        .in_COMPLEMENTin(rs1_data_EXE),
        .out_COMPLEMENTout(rs1_data_complement_EXE)
    );

    complement COMPLEMENT_RS2_DATA (
        .in_COMPLEMENTin(rs2_data_EXE),
        .out_COMPLEMENTout(rs2_data_complement_EXE)
    );

    alu COMPLEMENT_SUBSTRACTION (
        .alu_op(alu_op_EXE),
        .dataIn1(rs1_data_complement_EXE),
        .dataIn2(rs2_data_complement_EXE),
        .alu_result(complement_subtraction_result_EXE)  
    );

    wire [31:0] result_MULTIPLIERout, quotient_SIGNEDDIVIDERout,remainder_SIGNEDDIVIDERout;
    wire done_signal_MULTIPLIERout, done_signal_SIGNEDDIVIDERout;
    multiplier MULTIPLIER (
        .clk(clk),
        .opcode_MULin(alu_op_EXEin),
        .multiplier_MULin(rs1_data_EXEin),
        .multiplicand_MULin(rs2_data_EXEin),
        .result_MULTIPLIERout(result_MULTIPLIERout),
        .done_signal_MULTIPLIERout(done_signal_MULTIPLIERout),
        .alu_operating_MUL_DIVin(alu_operating_MUL_DIVin)
    );

    SignedDivider SIGNEDDIVIDER(
        .clk(clk),
        .opcode_DIVin(alu_op_EXEin),
        .dividend_DIVin(rs1_data_EXEin),
        .divisor_DIVin(rs2_data_EXEin),
        .quotient_SIGNEDDIVIDERout(quotient_SIGNEDDIVIDERout),
        .remainder_SIGNEDDIVIDERout(remainder_SIGNEDDIVIDERout),
        .done_signal_SIGNEDDIVIDERout(done_signal_SIGNEDDIVIDERout),
        .alu_operating_MUL_DIVin(alu_operating_MUL_DIVin)
    );
    
endmodule
