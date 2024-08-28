`include "defi.vh"
module decoder #( parameter DATA_WIDTH = 32) (
   instr_i      ,
   pc_i         ,
   rd_add_o     ,
   rs1_add_o    ,
   rs2_add_o    ,
   rs1_data_o   ,
   rs2_data_o   ,
   imm_o        ,
   reg_write_o  ,
   alu_sel1_o   ,
   alu_op_o     ,
   pc_sel_o     ,
   EX_zero_i    , 
   sel_to_reg_o ,
   jump_o       ,
   branch_o     ,
   EX_jump_i    ,
   EX_branch_i  ,
   mem_op_o     ,
   mem_rd_en_o  ,
   mem_wr_en_o  ,
   alu_sel2_o
 );
   input              [ 31:0]  instr_i      ;
   input              [ 31:0]  pc_i         ;
   input                       EX_zero_i    ;
   input                       EX_jump_i    ;
   input                       EX_branch_i  ;
   output reg                  mem_rd_en_o  ;
   output reg                  mem_wr_en_o  ;
   output reg                  reg_write_o  ;
   output reg         [ 3:0 ]  mem_op_o     ;
   output reg         [ 4:0 ]  rd_add_o     ;
   output reg         [ 4:0 ]  rs1_add_o    ;
   output reg         [ 4:0 ]  rs2_add_o    ;
   output reg         [ 31:0]  rs1_data_o   ;
   output reg         [ 31:0]  rs2_data_o   ;
   output reg         [ 31:0]  imm_o        ;
   output reg         [ 1:0 ]  alu_sel1_o   ;
   output reg         [ 1:0 ]  alu_sel2_o   ;
   output reg         [ 3:0 ]  alu_op_o     ;
   output reg                  pc_sel_o     ;
   output reg         [ 1:0 ]  sel_to_reg_o ;
   output reg                  jump_o       ;
   output reg                  branch_o     ;


   reg [6:0] opcode;
   reg [4:0] rd;
   reg [3:0] FUNCT3;
   reg [3:0] funct7;

   reg [31:0] IMM_I;
   reg [31:0] IMM_S;
   reg [31:0] IMM_B;
   reg [31:0] IMM_U;
   reg [31:0] IMM_J;

   always @(instr_i) begin
      opcode = instr_i[6:0];
      FUNCT3 = instr_i[14:12];
      funct7 = instr_i[30];
      IMM_I       = { {20{instr_i[31]}}, instr_i[31:20] }; 
      IMM_S       = { {20{instr_i[31]}}, instr_i[31:25], instr_i[11:7] }; 
      IMM_B       = { {20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0 }; 
      IMM_U       = {     instr_i[31:12], {12{1'b0}} };
      IMM_J       = { {12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:25], instr_i[24:21], 1'b0};
    end


    always @(EX_zero_i or EX_jump_i or EX_branch_i) begin
         pc_sel_o = (EX_zero_i & EX_jump_i & EX_branch_i);
    end
    always @(*) begin
       rd_add_o       =  instr_i[11:7]    ; 
       rs1_add_o      =  instr_i[19:15]   ;
       rs2_add_o      =  instr_i[24:20]   ;      

       imm_o        = 32'd0  ;
       alu_sel1_o   = 2'd0   ;
       alu_sel2_o   = 2'd0   ;
       alu_op_o     = 4'd0   ;
       mem_rd_en_o  = 1'd0   ;
       mem_wr_en_o  = 1'd0   ;
       sel_to_reg_o = 2'd0   ;
       jump_o       = 1'd0   ;
       branch_o     = 1'd0   ;
       pc_sel_o     = 1'b0   ;
			 mem_op_o     = `MEM_LW;

       case(opcode)
         `OPCODE_OP: begin
           reg_write_o  = 1'b1 ;
           sel_to_reg_o = 2'b01;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
           case(FUNCT3)
            `FUNCT3_ADD_SUB : alu_op_o  = (funct7) ? `ALU_SUB : `ALU_ADD ;
            `FUNCT3_SLL     : alu_op_o  = `ALU_SLL                       ;
            `FUNCT3_SLT     : alu_op_o  = `ALU_SLT                       ;
            `FUNCT3_SLTU    : alu_op_o  = `ALU_SLTU                      ;
            `FUNCT3_XOR     : alu_op_o  = `ALU_XOR                       ;
            `FUNCT3_SRL_SRA : alu_op_o  =  (funct7)? `ALU_SRA : `ALU_SRL ;
            `FUNCT3_OR      : alu_op_o  = `ALU_OR                        ;
            `FUNCT3_AND     : alu_op_o  = `ALU_AND                       ;
            default:          alu_op_o  = `ALU_ADD                       ;
        endcase
       end

       `OPCODE_BRANCH: begin
          branch_o            = 1'b1      ;
          imm_o               = IMM_B     ;
          rd_add_o            = 5'd0      ;
          case(FUNCT3)
          `FUNCT3_BEQ: begin
          branch_o            = 1'b0      ;
          alu_op_o            = `ALU_BEQ  ;
          end
          `FUNCT3_BNE: begin
          branch_o            = 1'b1      ;
          alu_op_o            = `ALU_BNE  ;
          end
          `FUNCT3_BLT: begin
          branch_o            = 1'b0      ;
          alu_op_o            = `ALU_BLT  ;
          end
          `FUNCT3_BGE: begin
          branch_o            =1'b 1      ;
          alu_op_o            = `ALU_BGE  ;
          end
          `FUNCT3_BLTU: begin
          branch_o            = 1'b0      ;
          alu_op_o            = `ALU_BLTU ;
          end
          `FUNCT3_BGEU: begin
          branch_o            = 1'b1      ;
          alu_op_o            = `ALU_BGEU ;
          end
          default: begin
          branch_o            =1'b0       ;
          alu_op_o            = `ALU_ADD  ;
          end
          endcase    
        end


       `OPCODE_LUI: begin
           reg_write_o  = (instr_i[11:7] == 0) ? 0:1   ;
           alu_sel1_o   = 2'b11                        ;
           alu_sel2_o   = 2'b11                        ;
           imm_o        = IMM_U                        ;
           alu_op_o     = `ALU_ADD                     ;
           rs1_add_o    = 5'd0                         ;
           rs2_add_o    = 5'd0                         ;
           sel_to_reg_o = 2'b11                        ;
       end
       
       
       `OPCODE_AUIPC: begin
           reg_write_o  = (instr_i[11:7] == 0) ? 0:1   ;
           alu_sel1_o   = 2'b10                        ;
           alu_sel2_o   = 2'b11                        ;
           imm_o        = IMM_U                        ;
           alu_op_o     = `ALU_ADD                     ;
           rs1_add_o    = 5'd0                         ;
           rs2_add_o    = 5'd0                         ;
           sel_to_reg_o = 2'b11                        ;
       end
       
       `OPCODE_JAL: begin
           reg_write_o  = (instr_i[11:7] == 0) ? 0:1 ;
           jump_o       = 1'b1                       ;
           alu_sel1_o   = 2'b10                      ;
           alu_sel2_o   = 2'b11                      ;
           imm_o        = IMM_J                      ; // Branch gen
           rs1_add_o    = 5'd0                       ;
           rs2_add_o    = 5'd0                       ;
           sel_to_reg_o = 2'b00                      ;
       end
       
       `OPCODE_JALR: begin
           reg_write_o  = (instr_i[11:7]  == 0) ? 0:1 ;
           jump_o       = 1'b1                        ;
           alu_sel1_o   = 2'b10                       ;
           alu_sel2_o   = 2'b11                       ;
           imm_o        = IMM_I                       ; // Branch gen
           rs2_add_o    = 5'd0                        ;
           sel_to_reg_o = 2'b00                       ;
       end
       
       
       `OPCODE_LOAD: begin
           reg_write_o  = (instr_i[11:7] == 0) ? 0:1 ;
           alu_sel1_o   = 2'b11                      ;
           alu_sel2_o   = 2'b11                      ;
           imm_o        = IMM_I                      ;
           mem_rd_en_o  = 1'b1                       ;
           reg_write_o  = 1'b1                       ;
           rs2_add_o    = 5'd0                       ;
           sel_to_reg_o = 2'b10                      ;
           case(FUNCT3)
               `FUNCT3_LW :  mem_op_o  = `MEM_LW  ;
               `FUNCT3_LB :  mem_op_o  = `MEM_LB  ;
               `FUNCT3_LH :  mem_op_o  = `MEM_LH  ;
               `FUNCT3_LBU:  mem_op_o  = `MEM_LB_U;
               `FUNCT3_LHU:  mem_op_o  = `MEM_LH_U;
           endcase
       end
       
       `OPCODE_STORE: begin
           alu_sel1_o  = 2'b11;
           alu_sel2_o  = 2'b11;
           imm_o       = IMM_S;
           mem_wr_en_o = 1'b1 ;
           case(FUNCT3)
               `FUNCT3_SB: mem_op_o = `MEM_SB;
               `FUNCT3_SH: mem_op_o = `MEM_SH;
               `FUNCT3_SW: mem_op_o = `MEM_SW;
           endcase
       end
        endcase   
    end 
endmodule
