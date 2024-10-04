`include "defi.vh"
module decoder #( parameter DATA_WIDTH = 32) (
   input                [ 31:0]  instr_i           ,
   input                         EX_zero_i         ,
   input                         EX_jump_i         ,
   input                         EX_branch_i       ,
   input  logic                  instr_c_illegal_i ,
   output logic                  mem_rd_en_o       ,
   output logic                  mem_wr_en_o       ,
   output logic                  reg_write_o       ,
   output logic         [ 3:0 ]  mem_op_o          ,
   output logic         [ 4:0 ]  rd_add_o          ,
   output logic         [ 4:0 ]  rs1_add_o         ,
   output logic         [ 4:0 ]  rs2_add_o         ,
   output logic         [ 31:0]  imm_o             ,
   output logic         [ 1:0 ]  alu_sel1_o        ,
   output logic         [ 1:0 ]  alu_sel2_o        ,
   output logic         [ 3:0 ]  alu_op_o          ,
   output logic                  pc_sel_o          ,
   output logic         [ 1:0 ]  sel_to_reg_o      ,
   output logic                  jump_o            ,
   output logic                  branch_o          ,
   output logic                  dret_insn_o       ,
   output logic                  ecall_insn_o      ,
   output logic                  illegal_insn_o    ,
   output logic                  ebrk_insn_o       ,
   output logic                  mret_insn_o       ,
   output logic                  wfi_insn_o        ,
   output logic         [31:0]   imm_i_type_o      ,
   output logic         [31:0]   imm_s_type_o      ,
   output logic         [31:0]   imm_b_type_o      ,
   output logic         [31:0]   imm_u_type_o      ,
   output logic         [31:0]   imm_j_type_o      ,
   output logic                  csr_access_o      ,    
   output logic                  data_req_o        ,
   output logic         [1:0]    data_type_o       ,  
   output pkg::csr_op_e          csr_op_o          ,    
   output pkg::rf_wd_sel_e       rf_wdata_sel_o   
 );
 import pkg::*;

   reg [4:0] rd;
   reg [2:0] FUNCT3;
   reg [3:0] funct7;
   reg [6:0] opcode;

   csr_op_e csr_op;

   logic csr_illegal;

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

   assign imm_i_type_o  = IMM_I ; 
   assign imm_s_type_o  = IMM_S ; 
   assign imm_b_type_o  = IMM_B ; 
   assign imm_u_type_o  = IMM_U ; 
   assign imm_j_type_o  = IMM_J ; 

  ///////////////////////
  // CSR operand check //
  ///////////////////////
  always_comb begin : csr_operand_check
    csr_op_o = csr_op;
    if ((csr_op == CSR_OP_SET || csr_op == CSR_OP_CLEAR) &&
        rs1_add_o == '0) begin
      csr_op_o = CSR_OP_READ;
    end
  end

    always @(EX_zero_i or EX_jump_i or EX_branch_i) begin
         pc_sel_o = ((EX_zero_i &  EX_branch_i) | EX_jump_i);
    end
    always @(*) begin
       rd_add_o       =  instr_i[11:7]    ; 
       rs1_add_o      =  instr_i[19:15]   ;
       rs2_add_o      =  instr_i[24:20]   ;      

       imm_o          = 32'd0      ;
       alu_sel1_o     = 2'd0       ;
       alu_sel2_o     = 2'd0       ;
       alu_op_o       = 4'd0       ;
       mem_rd_en_o    = 1'd0       ;
       mem_wr_en_o    = 1'd0       ;
       sel_to_reg_o   = 2'd0       ;
       jump_o         = 1'd0       ;
       branch_o       = 1'd0       ;
       pc_sel_o       = 1'b0       ;
			 mem_op_o       = `MEM_LW    ;
       reg_write_o    = 1'b0       ;
       dret_insn_o    = 1'b0       ;     
       ecall_insn_o   = 1'b0       ;     
       illegal_insn_o = 1'b0       ;     
       ebrk_insn_o    = 1'b0       ;     
       mret_insn_o    = 1'b0       ;     
       wfi_insn_o     = 1'b0       ;            
       csr_op         = CSR_OP_READ;
       data_type_o    = 2'b00      ;
       rf_wdata_sel_o = RF_WD_EX;  


       case(opcode)
         `OPCODE_OP: begin
           reg_write_o  = 1'b1 ;
           sel_to_reg_o = 2'b01;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
           rf_wdata_sel_o = RF_WD_EX;  
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
           reg_write_o  = 1'b0 ;
          case(FUNCT3)
          `FUNCT3_BEQ: begin
           alu_op_o            = `ALU_BEQ  ;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
          end
          `FUNCT3_BNE: begin
          alu_op_o            = `ALU_BNE  ;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
          end
          `FUNCT3_BLT: begin
          alu_op_o            = `ALU_BLT  ;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
          end
          `FUNCT3_BGE: begin
          alu_op_o            = `ALU_BGE  ;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
          end
          `FUNCT3_BLTU: begin
          alu_op_o            = `ALU_BLTU ;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
          end
          `FUNCT3_BGEU: begin
          alu_op_o            = `ALU_BGEU ;
           alu_sel1_o   = 2'b11;
           alu_sel2_o   = 2'b10;
          end
          default: begin
          branch_o            =1'b0       ;
          alu_op_o            = `ALU_ADD  ;
          end
          endcase    
        end

			 `OPCODE_OP_IMM: begin
			 		reg_write_o  = 1'b1;
          alu_sel1_o   = 2'b11                      ;
          alu_sel2_o   = 2'b11                      ;
					imm_o        = IMM_I                      ;
          sel_to_reg_o = 2'b01                      ;
          rf_wdata_sel_o = RF_WD_EX;  
				case(FUNCT3)
           `FUNCT3_ADDI        : alu_op_o = `ALU_ADD                       ;
					 `FUNCT3_ANDI        : alu_op_o = `ALU_AND                       ;
           `FUNCT3_ORI         : alu_op_o = `ALU_OR                        ;
           `FUNCT3_XORI        : alu_op_o = `ALU_XOR                       ;
           `FUNCT3_SLTI        : alu_op_o = `ALU_SLT                       ;
           `FUNCT3_SLTIU       : alu_op_o = `ALU_SLTU                      ;
           `FUNCT3_SRAI_SRLI   : alu_op_o = (funct7) ? `ALU_SRA : `ALU_SRL ;
           `FUNCT3_SLLI        : alu_op_o = `ALU_SLL                       ;
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
           rf_wdata_sel_o = RF_WD_EX;  
       end
       
       
       `OPCODE_AUIPC: begin
           reg_write_o  = (instr_i[11:7] == 0) ? 0:1   ;
           alu_sel1_o   = 2'b10                        ;
           alu_sel2_o   = 2'b11                        ;
           imm_o        = IMM_U                        ;
           alu_op_o     = `ALU_ADD                     ;
           rs1_add_o    = 5'd0                         ;
           rs2_add_o    = 5'd0                         ;
           sel_to_reg_o = 2'b01                        ;
           rf_wdata_sel_o = RF_WD_EX;  
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
           rf_wdata_sel_o = RF_WD_EX;  
       end
       
       `OPCODE_JALR: begin
          reg_write_o  = (instr_i[11:7]  == 0) ? 0:1 ;
          jump_o       = 1'b1                        ;
          alu_sel1_o   = 2'b10                       ;
          alu_sel2_o   = 2'b11                       ;
          imm_o        = IMM_I                       ; // Branch gen
          rs2_add_o    = 5'd0                        ;
          sel_to_reg_o = 2'b00                       ;
          rf_wdata_sel_o = RF_WD_EX;  
          if(instr_i[14:12] != 3'b0) begin
            illegal_insn_o = 1'b1;
          end
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
           rf_wdata_sel_o = RF_WD_EX;  
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
           rf_wdata_sel_o = RF_WD_EX;  
         unique case (instr_i[13:12])
          2'b00:   data_type_o    = 2'b10; // sb
          2'b01:   data_type_o    = 2'b01; // sh
          2'b10:   data_type_o    = 2'b00; // sw
          default: illegal_insn_o = 1'b1 ;
        endcase
           if(instr_i[14]) begin
             illegal_insn_o = 1'b1;
           end
           case(FUNCT3)
               `FUNCT3_SB: mem_op_o = `MEM_SB;
               `FUNCT3_SH: mem_op_o = `MEM_SH;
               `FUNCT3_SW: mem_op_o = `MEM_SW;
           endcase
       end
        OPCODE_SYSTEM: begin
               if (instr_i[14:12] == 3'b000) begin // non CSR related SYSTEM instructions
                 unique case (instr_i[31:20])
                   12'h000:  // ECALL // environment (system) call
                     ecall_insn_o = 1'b1;
                   12'h001:  // ebreak  debugger trap
                     ebrk_insn_o = 1'b1;
                   12'h302:  // mret
                     mret_insn_o = 1'b1;
                   12'h7b2:  // dret
                     dret_insn_o = 1'b1;
                   12'h105:  // wfi
                     wfi_insn_o = 1'b1;
                   default:
                     illegal_insn_o = 1'b1;
                 endcase
       
                 // rs1 and rd must be 0
                 if (rs1_add_o != 5'b0 || rd_add_o != 5'b0) begin
                   illegal_insn_o = 1'b1;
                 end
               end else begin
                 // instruction to read/modify CSR
                 csr_access_o     = 1'b1;
                 rf_wdata_sel_o   = RF_WD_CSR;
                 reg_write_o            = 1'b1;
       
                 if (~instr_i[14]) begin
                   reg_write_o         = 1'b1;
                 end
       
                 unique case (instr_i[13:12])
                   2'b01:   csr_op = CSR_OP_WRITE;
                   2'b10:   csr_op = CSR_OP_SET;
                   2'b11:   csr_op = CSR_OP_CLEAR;
                   default: csr_illegal = 1'b1;
                 endcase
       
                 illegal_insn_o = csr_illegal;
               end
       
             end
             default: begin
               illegal_insn_o = 1'b1;
             end
           endcase
         end
       
           always @(*) begin
           if (instr_c_illegal_i) begin
             illegal_insn_o = 1'b1;
           end else if (illegal_insn_o) begin
             reg_write_o  = 1'b0;
             data_req_o   = 1'b0;
             mem_rd_en_o  = 1'b0;
             mem_wr_en_o  = 1'b0;
             csr_access_o = 1'b0;
             end
           end
endmodule
