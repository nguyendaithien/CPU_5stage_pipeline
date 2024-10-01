`include "defi.vh"
module ALU #( parameter DATA_WIDTH = 32) (
	 alu_ctrl_i
	,alu_op2_i
	,alu_op1_i
	,alu_result_o
  ,zero_o
);	
    output reg  [31:0]     alu_result_o ;
    output reg             zero_o       ;
    input       [3:0 ]     alu_ctrl_i   ;
    input       [31:0]     alu_op1_i    ;
    input       [31:0]     alu_op2_i    ;

   
    always@* begin
        alu_result_o = 32'd0;
        case(alu_ctrl_i)
            `ALU_ADD  : alu_result_o = alu_op1_i + alu_op2_i                   ;
            `ALU_SUB  : alu_result_o = alu_op1_i - alu_op2_i                   ;
            `ALU_AND  : alu_result_o = alu_op1_i & alu_op2_i                   ;
            `ALU_OR   : alu_result_o = alu_op1_i | alu_op2_i                   ;
            `ALU_XOR  : alu_result_o = alu_op1_i ^ alu_op2_i                   ;
            `ALU_SLT  : alu_result_o = (alu_op1_i < alu_op2_i) ? 32'd1 : 32'd0 ;
            `ALU_SLTU : alu_result_o = (alu_op1_i < alu_op2_i) ? 32'd1 : 32'd0 ;
            `ALU_SLL  : alu_result_o = alu_op1_i << alu_op2_i[4 : 0]           ;
            `ALU_SRL  : alu_result_o = alu_op1_i >> alu_op2_i[4 : 0]           ;
            `ALU_SRA  : alu_result_o = $signed(alu_op1_i) >>> alu_op2_i[4 : 0] ;
            default: alu_result_o = 0;
        endcase
    end

    always@* begin
        zero_o = 1'b0;
        case(alu_ctrl_i) 
            `ALU_BEQ  : zero_o = (alu_op1_i ==  alu_op2_i)? 1'd1 : 1'd0                    ;
            `ALU_BNE  : zero_o = (alu_op1_i !=  alu_op2_i)? 1'd1 : 1'd0                    ;
            `ALU_BLT  : zero_o = ($signed(alu_op1_i) <   $signed(alu_op2_i)) ? 1'd1 : 1'd0 ;
            `ALU_BGE  : zero_o = (alu_op1_i <=  alu_op2_i)? 1'd1 : 1'd0                    ;
            `ALU_BLTU : zero_o = (alu_op1_i <   alu_op2_i)? 1'd1 : 1'd0                    ;
            `ALU_BGEU : zero_o = (alu_op1_i >=  alu_op2_i)? 1'd1 : 1'd0                    ;

        endcase
    end
    
endmodule
