module EX_stage #( parameter DATA_WIDTH = 32) (
   input               clk             ,
   input               rst_n           ,
   input      [4:0 ]   EX_rs1_add_i    ,
   input      [4:0 ]   EX_rs2_add_i    ,
   input      [4:0 ]   EX_rd_add_i     ,
   input      [1:0 ]   EX_sel_to_reg_i ,
   input               EX_regwrite_i   ,
   input               EX_RD_mem_i     ,
   input               EX_WR_mem_i     ,
   input      [1:0 ]   EX_sel_alu1_i   ,
   input      [1:0 ]   EX_sel_alu2_i   ,
   input      [3:0 ]   EX_mem_op_i     ,
   input      [31:0]   EX_rs2_data_i   ,
   input      [31:0]   EX_rs1_data_i   ,
   input      [31:0]   WB_data_i       ,
   input      [31:0]   EX_data_i       ,
   input      [31:0]   EX_pc_i         ,
   input               flush           ,
   input      [1:0 ]   forwardA        ,
   input      [1:0 ]   forwardB        ,
   input               hazard          ,
   input      [31:0]   EX_imm_i        ,
	 input      [3:0 ]   EX_alu_op_i     ,
   input      pkg::rf_wd_sel_e EX_rf_wdata_sel_i,  

   input EX_branch_i      ,
   input EX_jump_i        ,
   output reg EX_branch_o ,
   output reg EX_jump_o   ,
  
   output reg [31:0]   EX_pc_o         ,
   output reg [4:0 ]   EX_rs1_add_o    ,
   output reg [4:0 ]   EX_rs2_add_o    ,
   output reg [4:0 ]   EX_rd_add_o     ,
   output reg [1:0 ]   EX_sel_to_reg_o ,
   output reg          EX_regwrite_o   ,
   output reg          EX_RD_mem_o     ,
   output reg          EX_WR_mem_o     ,
   output reg [3:0 ]   EX_mem_op_o     ,
   output reg [31:0]   EX_alu_result_o ,
   output reg          EX_zero_o       ,
   output reg [31:0]   EX_imm_o        ,
   output wire [31:0]  EX_pc_dest     ,
   output reg [31:0]   EX_rs2_data_o  , 
   output  pkg::rf_wd_sel_e EX_rf_wdata_sel_o  
);
import pkg::*;

  

   wire [1:0 ] sel_to_alu_A ;
   wire [1:0 ] sel_to_alu_B ;
   wire [31:0] alu_result   ;
   wire        zero         ;

   reg [31:0] op_a_alu;
   reg [31:0] op_b_alu;


   assign sel_to_alu_A = (hazard) ?  forwardA : EX_sel_alu1_i  ; 
   assign sel_to_alu_B = (hazard) ?  forwardB : EX_sel_alu2_i  ; 

   ALU #(.DATA_WIDTH(32)) alu (
  	.alu_ctrl_i   (EX_alu_op_i)
  	,.alu_op2_i   (op_b_alu   )
  	,.alu_op1_i   (op_a_alu   )
  	,.alu_result_o(alu_result )
    ,.zero_o      (zero       )
    );	


    always@(posedge clk) begin
        if((~rst_n) || (flush)) begin 
          EX_RD_mem_o       <= 1'b0     ;
          EX_WR_mem_o       <= 1'b0     ;
          EX_mem_op_o       <= 3'd0     ;
          EX_sel_to_reg_o   <= 2'd0     ;
          EX_rd_add_o       <= 5'd0     ;
          EX_regwrite_o     <= 1'd0     ;
          EX_rs2_add_o      <= 5'd0     ;
          EX_rs1_add_o      <= 5'd0     ;
          EX_pc_o           <= 32'd0    ;
          EX_alu_result_o   <= 32'd0    ;
          EX_imm_o          <= 32'd0    ;
          EX_zero_o         <= 1'b0     ;
          EX_rs2_data_o     <= 32'd0    ;
          EX_branch_o       <= 1'b0     ;
          EX_jump_o         <= 1'b0     ;
          EX_rf_wdata_sel_o <= RF_WD_EX ;
        end
        else begin
          EX_RD_mem_o         <= EX_RD_mem_i       ;
          EX_WR_mem_o         <= EX_WR_mem_i       ;
          EX_mem_op_o         <= EX_mem_op_i       ;
          EX_sel_to_reg_o     <= EX_sel_to_reg_i   ;
          EX_regwrite_o       <= EX_regwrite_i     ;
          EX_rd_add_o         <= EX_rd_add_i       ;
          EX_rs2_add_o        <= EX_rs2_add_i      ;
          EX_rs1_add_o        <= EX_rs1_add_i      ;
          EX_pc_o             <= EX_pc_i           ;
          EX_alu_result_o     <= alu_result        ;
          EX_zero_o           <= zero              ;
          EX_rs2_data_o       <= EX_rs2_data_i     ;
          EX_branch_o         <= EX_branch_i       ;
          EX_jump_o           <= EX_jump_i         ;
          EX_imm_o            <= EX_imm_i          ;
          EX_rf_wdata_sel_o   <= EX_rf_wdata_sel_i ;
        end
    end

           assign EX_pc_dest = EX_pc_o + EX_imm_o  ; 

    always @* begin
        case(sel_to_alu_A) 
        2'b00: op_a_alu = WB_data_i     ;
        2'b01: op_a_alu = EX_data_i     ;
        2'b11: op_a_alu = EX_rs1_data_i ;
        default: op_a_alu = EX_pc_i     ;
      endcase
    end
    always @* begin
        case(sel_to_alu_B) 
        2'b00: op_b_alu = WB_data_i       ;
        2'b01: op_b_alu = EX_data_i       ;
        2'b11: op_b_alu = EX_imm_i        ;
        default: op_b_alu = EX_rs2_data_i ;
      endcase
    end
endmodule
