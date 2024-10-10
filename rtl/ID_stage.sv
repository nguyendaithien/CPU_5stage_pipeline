module ID_stage #( parameter DATA_WIDTH = 32) (
  input             clk                  ,
  input             rst_n                ,
  input             stall                ,
  input             flush                ,
  input             EX_zero_i            ,
  input      [31:0] ID_instr_i           ,
  input      [31:0] WB_data_i            ,
  input             WB_regwrite_i        ,
  input      [4: 0] WB_rd_add_i          ,
  input      [4: 0] EX_rd_add_i          ,
  input      [31:0] ID_pc_i              ,
  input             EX_branch_i          ,
  input             EX_jump_i            ,
  input             ID_instr_c_illegal_i ,
  input      [31:0] ID_csr_data_i        ,
  input pkg::rf_wd_sel_e ID_rf_wdata_sel_i    ,
  
  output logic [4:0 ] ID_rs1_add_o      ,
  output logic [4:0 ] ID_rs2_add_o      ,
  output logic [4:0 ] ID_rd_add_o       ,
  output logic [31:0] ID_rs1_data_o     ,
  output logic [31:0] ID_rs2_data_o     ,
  output logic [31:0] ID_pc_o           ,
  output logic [31:0] ID_imm_o          ,
  output logic [3:0 ] ID_alu_op_o       ,
  output logic [1:0 ] ID_sel_to_reg_o   ,
  output logic [3:0 ] ID_mem_op_o       ,
  output logic [1:0 ] ID_alu_sel1_o     ,
  output logic [1:0 ] ID_alu_sel2_o     ,
  output logic        ID_regwrite_o     ,
  output logic        ID_jump_o         ,
  output logic        ID_RD_en_o        ,
  output logic        ID_WR_en_o        ,
  output logic        ID_branch_o       ,
  output logic        ID_pc_sel_o       ,
  output logic        ID_dret_insn_o    ,
  output logic        ID_ecall_insn_o   ,
  output logic        ID_illegal_insn_o ,
  output logic        ID_ebrk_insn_o    ,
  output logic        ID_mret_insn_o    ,
  output logic        ID_wfi_insn_o     ,
  output logic        ID_imm_i_type_o   ,
  output logic        ID_imm_s_type_o   ,
  output logic        ID_imm_b_type_o   ,
  output logic        ID_imm_u_type_o   ,
  output logic        ID_imm_j_type_o   ,
  output logic        ID_csr_access_o   ,
  output logic        ID_data_req_o     , 
  output  pkg::csr_op_e ID_csr_op_o     ,
  output  pkg::rf_wd_sel_e ID_rf_wdata_sel_o 
);
  import pkg::*;

  logic [31:0] rs1_data_temp;
  logic [31:0] rs2_data_temp;

  logic [31:0] match_1     ;
  logic [31:0] match_2     ;
  logic [4:0 ] rd_add      ;
  logic [4:0 ] rs1_add     ;
  logic [4:0 ] rs2_add     ;
  logic [31:0] rs1_data    ;
  logic [31:0] rs2_data    ;
  logic [31:0] imm         ;
  logic [3:0 ] mem_op      ;
  logic [1:0 ] alu_sel1    ;
  logic [1:0 ] alu_sel2    ;
  logic [3:0 ] alu_op      ;
  logic        pc_sel      ;
  logic [31:0] instr       ;
  logic        EX_zero     ;
  logic [1:0 ] sel_to_reg  ;
  logic        jump        ;
  logic        branch      ;
  logic        EX_jump     ;
  logic        EX_branch   ;
  logic        mem_rd_en   ;
  logic        mem_wr_en   ;

  logic [4:0 ] address_1   ;
  logic [4:0 ] address_3   ;
  logic [4:0 ] address_2   ;
  logic        reg_write   ;
  logic [31:0] read_data_1 ;
  logic [31:0] read_data_2 ;
  logic [31:0] read_data_3 ;

  logic        dret_insn      ; 
  logic        ecall_insn     ; 
  logic        illegal_insn   ; 
  logic        ebrk_insn      ; 
  logic        mret_insn      ; 
  logic        wfi_insn       ; 
  logic [31:0] imm_i_type     ; 
  logic [31:0] imm_s_type     ; 
  logic [31:0] imm_b_type     ; 
  logic [31:0] imm_u_type     ; 
  logic [31:0] imm_j_type     ; 
  logic        csr_access     ; 
  logic        data_req       ; 
  logic [1: 0] ID_data_type   ;

  pkg::rf_wd_sel_e rf_wdata_sel ;
  pkg::csr_op_e csr_op          ;

  logic [31:0] data_write_reg;
  assign data_write_reg = (ID_rf_wdata_sel_i == RF_WD_EX) ? WB_data_i : ID_csr_data_i ; 

  decoder #(.DATA_WIDTH(32)) decode (
       .instr_i           (ID_instr_i          ) 
      ,.rd_add_o          (rd_add              )
      ,.rs1_add_o         (rs1_add             )
      ,.rs2_add_o         (rs2_add             )
      ,.imm_o             (imm                 )
      ,.reg_write_o       (reg_write           )
      ,.alu_sel1_o        (alu_sel1            )
      ,.alu_sel2_o        (alu_sel2            )
      ,.alu_op_o          (alu_op              )
      ,.pc_sel_o          (pc_sel              )
      ,.EX_zero_i         (EX_zero_i           )
      ,.sel_to_reg_o      (sel_to_reg          )
      ,.jump_o            (jump                )
      ,.branch_o          (branch              )
      ,.EX_jump_i         (EX_jump_i           )
      ,.EX_branch_i       (EX_branch_i         )
      ,.mem_op_o          (mem_op              )
      ,.mem_rd_en_o       (mem_rd_en           )
      ,.mem_wr_en_o       (mem_wr_en           )
      ,.rf_wdata_sel_o    (rf_wdata_sel        )   
      ,.dret_insn_o       (dret_insn           )   
      ,.ecall_insn_o      (ecall_insn          )   
      ,.illegal_insn_o    (illegal_insn        )   
      ,.ebrk_insn_o       (ebrk_insn           )   
      ,.mret_insn_o       (mret_insn           )   
      ,.wfi_insn_o        (wfi_insn            )   
      ,.imm_i_type_o      (imm_i_type          )   
      ,.imm_s_type_o      (imm_s_type          )   
      ,.imm_b_type_o      (imm_b_type          )   
      ,.imm_u_type_o      (imm_u_type          )   
      ,.imm_j_type_o      (imm_j_type          )   
      ,.csr_access_o      (csr_access          )   
      ,.csr_op_o          (csr_op              )   
      ,.data_req_o        (data_req            )   
      ,.instr_c_illegal_i (ID_instr_c_illegal_i)   
      ,.data_type_o       (ID_data_type        )
    );

   register_file #(.DATA_WIDTH(32), .NUM_REG(32), .ADD_WIDTH(5)) reg_file(
    .clk        (clk           )
   ,.address_1  (rs1_add       )
   ,.address_2  (rs2_add       )
 	 ,.address_3  (WB_rd_add_i   )
   ,.data_write (data_write_reg)
   ,.reg_write  (WB_regwrite_i )
   ,.rst_n      (rst_n         )
   ,.read_data_1(read_data_1   )
   ,.read_data_2(read_data_2   )
   );

   always@(posedge clk) begin
       if(~rst_n) begin
           ID_rd_add_o        <= 0;
           ID_rs1_add_o       <= 0;
           ID_rs2_add_o       <= 0;
           ID_imm_o           <= 0;
       end
       else begin
           ID_rd_add_o        <= rd_add ;
           ID_rs1_add_o       <= rs1_add;
           ID_rs2_add_o       <= rs2_add;
           ID_imm_o           <= imm    ;
       end
   end
  always@(posedge clk) begin
    if((~rst_n) | (flush)) begin
      ID_pc_o               <= 32'd0      ;
      ID_alu_sel1_o         <= 2'd0       ;
      ID_alu_sel2_o         <= 2'd0       ;
      ID_alu_op_o           <= 4'd0       ;
      ID_branch_o           <= 1'b0       ;
      ID_branch_o           <= 1'b0       ;
      ID_WR_en_o            <= 1'b0       ;
      ID_RD_en_o            <= 1'b0       ;
      ID_regwrite_o         <= 1'b0       ;
      ID_sel_to_reg_o       <= 2'd0       ;
      ID_jump_o             <= 1'b0       ;
      ID_mem_op_o           <= 4'd0       ;
			ID_pc_sel_o           <= 1'b0       ;
      ID_rf_wdata_sel_o     <= RF_WD_EX   ; 
      ID_dret_insn_o        <= 1'b0       ; 
      ID_ecall_insn_o       <= 1'b0       ; 
      ID_illegal_insn_o     <= 1'b0       ; 
      ID_ebrk_insn_o        <= 1'b0       ; 
      ID_mret_insn_o        <= 1'b0       ; 
      ID_wfi_insn_o         <= 1'b0       ; 
      ID_imm_i_type_o       <= 1'b0       ; 
      ID_imm_s_type_o       <= 1'b0       ; 
      ID_imm_b_type_o       <= 1'b0       ; 
      ID_imm_u_type_o       <= 1'b0       ; 
      ID_imm_j_type_o       <= 1'b0       ; 
      ID_csr_access_o       <= 1'b0       ; 
      ID_csr_op_o           <= CSR_OP_READ; 
      ID_data_req_o         <= 1'b0       ; 
      end
    else begin
      if(stall) begin
        ID_pc_o             <= ID_pc_o          ;
        ID_alu_sel1_o       <= ID_alu_sel1_o    ;
        ID_alu_sel2_o       <= ID_alu_sel2_o    ;
        ID_alu_op_o         <= ID_alu_op_o      ;
        ID_branch_o         <= ID_branch_o      ;
        ID_branch_o         <= ID_branch_o      ;
        ID_sel_to_reg_o     <= ID_sel_to_reg_o  ;
        ID_mem_op_o         <= ID_mem_op_o      ;
        ID_jump_o           <= 1'b0             ;
        ID_RD_en_o          <= 1'b0             ;
        ID_WR_en_o          <= 1'b0             ;
        ID_regwrite_o       <= 1'b0             ;
				ID_pc_sel_o         <= 1'b0             ;
        ID_rf_wdata_sel_o   <= RF_WD_EX         ; 
        ID_dret_insn_o      <= ID_dret_insn_o   ; 
        ID_ecall_insn_o     <= ID_ecall_insn_o  ; 
        ID_illegal_insn_o   <= ID_illegal_insn_o; 
        ID_ebrk_insn_o      <= ID_ebrk_insn_o   ; 
        ID_mret_insn_o      <= ID_mret_insn_o   ; 
        ID_wfi_insn_o       <= ID_wfi_insn_o    ; 
        ID_imm_i_type_o     <= ID_imm_i_type_o  ; 
        ID_imm_s_type_o     <= ID_imm_s_type_o  ; 
        ID_imm_b_type_o     <= ID_imm_b_type_o  ; 
        ID_imm_u_type_o     <= ID_imm_u_type_o  ; 
        ID_imm_j_type_o     <= ID_imm_j_type_o  ; 
        ID_csr_access_o     <= ID_csr_access_o  ; 
        ID_csr_op_o         <= ID_csr_op_o      ; 
        ID_data_req_o       <= ID_data_req_o    ; 
        end
      else begin
        ID_pc_o             <= ID_pc_i     ;
        ID_alu_sel1_o       <= alu_sel1    ;
        ID_alu_sel2_o       <= alu_sel2    ;
        ID_alu_op_o         <= alu_op      ;
        ID_branch_o         <= branch      ;
        ID_WR_en_o          <= mem_wr_en   ;
        ID_RD_en_o          <= mem_rd_en   ;
        ID_regwrite_o       <= reg_write   ;
        ID_sel_to_reg_o     <= sel_to_reg  ;
        ID_jump_o           <= jump        ;
        ID_mem_op_o         <= mem_op      ;
				ID_pc_sel_o         <= pc_sel      ;
        ID_rf_wdata_sel_o   <= rf_wdata_sel; 
        ID_dret_insn_o      <= dret_insn   ; 
        ID_ecall_insn_o     <= ecall_insn  ; 
        ID_illegal_insn_o   <= illegal_insn; 
        ID_ebrk_insn_o      <= ebrk_insn   ; 
        ID_mret_insn_o      <= mret_insn   ; 
        ID_wfi_insn_o       <= wfi_insn    ; 
        ID_imm_i_type_o     <= imm_i_type  ; 
        ID_imm_s_type_o     <= imm_s_type  ; 
        ID_imm_b_type_o     <= imm_b_type  ; 
        ID_imm_u_type_o     <= imm_u_type  ; 
        ID_imm_j_type_o     <= imm_j_type  ; 
        ID_csr_access_o     <= csr_access  ; 
        ID_csr_op_o         <= csr_op      ; 
      end
    end  
  end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      rs1_data_temp <= 32'd0;
      rs2_data_temp <= 32'd0;
    end
    else begin
      rs1_data_temp <= read_data_1;
      rs2_data_temp <= read_data_2;
    end
  end

  assign match_1 = (WB_rd_add_i == ID_rs1_add_o) & |ID_rs1_add_o;
  assign match_2 = (WB_rd_add_i == ID_rs2_add_o) & |ID_rs2_add_o;

  always@(*) begin
    ID_rs1_data_o = (match_1 && WB_regwrite_i) ? WB_data_i : read_data_1;
    ID_rs2_data_o = (match_2 && WB_regwrite_i) ? WB_data_i : read_data_2;
  end
endmodule
