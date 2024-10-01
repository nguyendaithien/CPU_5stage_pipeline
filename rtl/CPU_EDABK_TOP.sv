`include "defi.vh"
module CPU_EDABK_TOP #( parameter DATA_WIDTH = 32) (
   clk_i
  ,rst_n
  ,RD
  ,WR
  ,A_DMEM
  ,A_IMEM // address
  ,Instr_in
  ,D_in
  ,D_out
  ,DMEM_rst
  ,byte_mark
  ,boot_add
 );

   input              clk       ;
   input              rst_n     ;
   output  wire           RD        ;
   output  wire           WR        ;
   input       [31:0] boot_add  ;
   input       [31:0] Instr_in  ;
   input       [31:0] D_in      ;
   output wire [31:0] A_DMEM    ;
   output wire [31:0] A_IMEM    ;
   output wire [31:0] D_out     ;
   output wire [3:0 ] byte_mark ;
   output wire        DMEM_rst  ;


 
   wire [4:0 ] WB_rd_add         ;
   wire [31:0] WB_data_write_reg ;
   wire        WB_regwrite       ;
   // output of IF stage
   wire [31:0] IF_instr          ;
   wire [4:0 ] IMEM_add          ;
   wire [31:0] IF_pc             ;
   // OUTPUT ID stage
   wire [4:0 ] ID_rs1_add        ;
   wire [4:0 ] ID_rs2_add        ;
   wire [4:0 ] ID_rd_add         ;
   wire [31:0] ID_rs1_data       ;
   wire [31:0] ID_rs2_data       ;
   wire [31:0] ID_pc             ;
   wire [3:0 ] ID_alu_op         ;
   wire [31:0] ID_imm            ;
   wire [1:0 ] ID_sel_to_reg     ;
   wire        ID_regwrite       ;
   wire [3:0 ] ID_mem_op         ;
   wire        ID_jump           ;
   wire ID_RD                    ;
   wire ID_WR                    ;
   wire        ID_branch         ;
   wire [1:0 ] ID_alu_sel1       ;
   wire [1:0 ] ID_alu_sel2       ;
   wire        ID_pc_sel         ;
   // OUTPUT EX stage
   wire [31:0] EX_pc             ;
   wire [4:0 ] EX_rs1_add        ;
   wire [4:0 ] EX_rs2_add        ;
   wire [4:0 ] EX_rd_add         ;
   wire [1:0 ] EX_sel_to_reg     ;
   wire        EX_regwrite       ;
   wire        EX_RD             ;
   wire        EX_WR             ;
   wire [3:0 ] EX_mem_op         ;
   wire [31:0] EX_alu_result     ;
   wire        EX_zero           ;
   wire [31:0] EX_imm            ;
   wire [31:0] EX_pc_dest        ;
   wire [31:0] EX_rs2_data       ;
	 wire        EX_branch         ;
	 wire        EX_jump           ;
   // output of MEM stage
   wire [31:0] MEM_add           ;
   wire [3:0 ] DMEM_byte_mark    ;
   wire [31:0] DMEM_data_write   ;
   wire [31:0] MEM_data          ;
	 wire [31:0] DMEM_data_o       ;
   wire        MEM_regwrite      ;
   wire [31:0] MEM_alu_result    ;
   wire [4:0 ] MEM_rd_add        ;
   wire [1:0 ] MEM_sel_to_reg    ;
   wire        MEM_RD_mem        ;
   wire        MEM_WR_mem        ;
   wire [31:0] MEM_pc            ;
	 wire [1:0 ] forward_A         ;
	 wire [1:0 ] forward_B         ;
	 wire [31:0] MEM_imm           ;
	 wire        forward_dmem      ;

	 wire pc_sel = ((EX_branch &  EX_zero) | EX_jump);
	 assign RD        = MEM_RD_mem     ;
	 assign WR        = MEM_WR_mem     ;
	 assign byte_mark = DMEM_byte_mark ;

  IF_stage #( .DATA_WIDTH(32))  if_stage (
     .clk        (clk         )
    ,.rst_n      (rst_n       )
    ,.IF_instr_i (Instr_in    )
    ,.boot_add   (boot_add    )
    ,.flush      (IF_ID_flush )
    ,.pc_dest    (EX_pc_dest  )
    ,.IMEM_data_i(Instr_in    )
    ,.stall      (stall       )
    ,.pc_sel     (pc_sel      )
    ,.IF_pc_o    (IF_pc       )
    ,.IF_instr_o (IF_instr    )
    ,.IMEM_add_o (A_IMEM      )
  );


  ID_stage #( .DATA_WIDTH(32)) id_stage (
   .clk               (clk                     ) 
  ,.rst_n             (rst_n                   )
  ,.stall             (stall                   )
  ,.flush             (IF_ID_flush             )
  ,.ID_instr_i        (IF_instr                )
	,.EX_zero_i         (EX_zero                 )
	,.EX_branch_i       (EX_branch               )
	,.EX_jump_i         (EX_jump                 )
  ,.EX_ALU_result_i   (EX_alu_result           )
  ,.EX_rd_add_i       (EX_rd_add               )
  ,.WB_data_i         (WB_data_write_reg       )
  ,.WB_regwrite_i     (WB_regwrite             )
  ,.WB_rd_add_i       (WB_rd_add               )
  ,.ID_pc_i           (IF_pc                   )
  ,.ID_rs1_add_o      (ID_rs1_add              )
  ,.ID_rs2_add_o      (ID_rs2_add              )
  ,.ID_rd_add_o       (ID_rd_add               )
  ,.ID_rs1_data_o     (ID_rs1_data             )
  ,.ID_rs2_data_o     (ID_rs2_data             )
  ,.ID_pc_o           (ID_pc                   )
  ,.ID_imm_o          (ID_imm                  )
  ,.ID_alu_op_o       (ID_alu_op               )
  ,.ID_regwrite_o     (ID_regwrite             )
  ,.ID_mem_op_o       (ID_mem_op               )
  ,.ID_jump_o         (ID_jump                 )
  ,.ID_sel_to_reg_o   (ID_sel_to_reg           )
  ,.ID_RD_en_o        (ID_RD                   )
  ,.ID_WR_en_o        (ID_WR                   )
  ,.ID_branch_o       (ID_branch               )
  ,.ID_alu_sel1_o     (ID_alu_sel1             )
  ,.ID_alu_sel2_o     (ID_alu_sel2             )
  ,.ID_pc_sel_o       (ID_pc_sel               )
  ,.ID_rf_wdata_sel_o (ID_rf_wdata_sel         )             
  ,.ID_dret_insn_o    (ID_dret_insn            )             
  ,.ID_ecall_insn_o   (ID_ecall_insn           )             
  ,.ID_illegal_insn_o (ID_illegal_insn         )             
  ,.ID_ebrk_insn_o    (ID_ebrk_insn            )             
  ,.ID_mret_insn_o    (ID_mret_insn            )             
  ,.ID_wfi_insn_o     (ID_wfi_insn             )             
  ,.ID_imm_i_type_o   (ID_imm_i_type           )             
  ,.ID_imm_s_type_o   (ID_imm_s_type           )             
  ,.ID_imm_b_type_o   (ID_imm_b_type           )             
  ,.ID_imm_u_type_o   (ID_imm_u_type           )             
  ,.ID_imm_j_type_o   (ID_imm_j_type           )             
  ,.ID_csr_access_o   (ID_csr_access           )             
  ,.ID_csr_op_o       (ID_csr_op               )             
  ,.ID_data_req_o     (ID_data_req             )             

);


  EX_stage #( .DATA_WIDTH(32)) ex_stage (
     .clk             (clk               )                               
    ,.rst_n           (rst_n             )
    ,.EX_pc_i         (ID_pc             )
    ,.EX_rs1_add_i    (ID_rs1_add        )
    ,.EX_rs2_add_i    (ID_rs2_add        )
    ,.EX_rd_add_i     (ID_rd_add         )
    ,.EX_sel_to_reg_i (ID_sel_to_reg     )
    ,.EX_regwrite_i   (ID_regwrite       )
		,.EX_branch_i     (ID_branch         )
		,.EX_jump_i       (ID_jump           )
    ,.EX_RD_mem_i     (ID_RD             )
    ,.EX_WR_mem_i     (ID_WR             )
    ,.EX_mem_op_i     (ID_mem_op         )
    ,.EX_rs2_data_i   (ID_rs2_data       )
    ,.EX_rs1_data_i   (ID_rs1_data       )
    ,.EX_sel_alu1_i   (ID_alu_sel1       )
    ,.EX_sel_alu2_i   (ID_alu_sel2       )
    ,.EX_imm_i        (ID_imm            )
		,.EX_alu_op_i     (ID_alu_op         )
    ,.flush           (EX_flush          )
    ,.forwardA        (forward_A         )
    ,.forwardB        (forward_B         )
    ,.WB_data_i       (WB_data_write_reg )
    ,.EX_data_i       (EX_alu_result     )
    ,.hazard          (hazard            )
    ,.EX_rs2_data_o   (EX_rs2_data       )
    ,.EX_pc_o         (EX_pc             )
    ,.EX_rs1_add_o    (EX_rs1_add        )
    ,.EX_rs2_add_o    (EX_rs2_add        )
    ,.EX_rd_add_o     (EX_rd_add         )
    ,.EX_sel_to_reg_o (EX_sel_to_reg     )
    ,.EX_regwrite_o   (EX_regwrite       )
    ,.EX_RD_mem_o     (EX_RD             )
    ,.EX_WR_mem_o     (EX_WR             )
    ,.EX_mem_op_o     (EX_mem_op         )
    ,.EX_alu_result_o (EX_alu_result     )
    ,.EX_zero_o       (EX_zero           )
    ,.EX_imm_o        (EX_imm            )
    ,.EX_pc_dest      (EX_pc_dest        )
	  ,.EX_branch_o     (EX_branch         )
	  ,.EX_jump_o       (EX_jump           )
);

   MEM_stage #( .DATA_WIDTH(32)) mem_stage (
     .clk               (clk               )
    ,.rst_n             (rst_n             )
    ,.WB_data_i         (WB_data_write_reg )
    ,.forward           (forward_dmem      )
    ,.MEM_RD_mem_i      (EX_RD             )
    ,.MEM_WR_mem_i      (EX_WR             )
    ,.MEM_mem_op_i      (EX_mem_op         )
    ,.MEM_regwrite_i    (EX_regwrite       )
    ,.MEM_alu_result_i  (EX_alu_result     )
    ,.MEM_rs2_data_i    (EX_rs2_data       )
    ,.MEM_rd_add_i      (EX_rd_add         )
    ,.MEM_pc_i          (EX_pc             )
    ,.MEM_imm_i         (EX_imm            )
    ,.MEM_imm_o         (MEM_imm           )
    ,.MEM_pc_o          (MEM_pc            )
    ,.DMEM_add_o        (A_DMEM            )
    ,.DMEM_byte_mark_o  (DMEM_byte_mark    )
    ,.DMEM_data_write_o (D_out             )
    ,.MEM_data_o        (DMEM_data_o       )
    ,.MEM_regwrite_o    (MEM_regwrite      )
    ,.MEM_alu_result_o  (MEM_alu_result    )
    ,.MEM_rd_add_o      (MEM_rd_add        )
    ,.MEM_sel_to_reg_o  (MEM_sel_to_reg    )
    ,.MEM_sel_to_reg_i  (EX_sel_to_reg     )
    ,.MEM_RD_mem_o      (MEM_RD_mem        )
    ,.MEM_WR_mem_o      (MEM_WR_mem        )
    ,.DMEM_data_i       (D_in              ) // data from DMEM
    ,.DMEM_rst_o        (DMEM_rst          )
  );

  WB_stage #(.DATA_WIDTH(32))  wb_stage (
   .clk                   (clk               )
  ,.rst_n                 (rst_n             )
  ,.WB_rd_add_i           (MEM_rd_add        )
  ,.DMEM_data_i           (DMEM_data_o       )
  ,.WB_alu_result_i       (MEM_alu_result    )
  ,.WB_sel_to_reg_i       (MEM_sel_to_reg    )
  ,.WB_regwrite_i         (MEM_regwrite      )
  ,.WB_pc_i               (MEM_pc            )
  ,.WB_imm_i              (MEM_imm           )
  ,.WB_rd_add_o           (WB_rd_add         )
  ,.WB_data_write_reg_o   (WB_data_write_reg )
  ,.WB_regwrite_o         (WB_regwrite       )
  );


   CONTROL_HAZARD #( .DATA_WIDTH(32)) control_hazard (
   .clk(clk)
  ,.rst_n          (rst_n        )
  ,.stall_o        (stall        )
  ,.IF_ID_flush_o  (IF_ID_flush  )
  ,.EX_flush_o     (EX_flush     )
  ,.hazard         (hazard       )
  ,.forward_A_o    (forward_A    )
  ,.forward_B_o    (forward_B    )
  ,.forward_dmem   (forward_dmem )
  ,.ID_RD_mem_i    (ID_RD        )
  ,.ID_rs1_add_i   (ID_rs1_add   )
  ,.ID_rs2_add_i   (ID_rs2_add   )
  ,.ID_rd_add_i    (ID_rd_add    )
  ,.EX_rs1_add_i   (EX_rs1_add   )
  ,.EX_rs2_add_i   (EX_rs2_add   )
  ,.EX_rd_add_i    (EX_rd_add    )
  ,.MEM_rd_add_i   (MEM_rd_add   )
  ,.EX_regwrite_i  (EX_regwrite  )
  ,.MEM_regwrite_i (MEM_regwrite )
  ,.IF_instr_i     (IF_instr     )
  ,.ID_jump        (ID_jump      )
  ,.zero           (EX_zero      )
 );

 logic clk        ;
 logic core_sleep ;
 logic clk_gated  ;

 SLEEP_UNIT sleep_unit (
   .clk_i         ( clk        )
   ,.rst_n        ( rst_n      )
   ,.core_sleep_i ( core_sleep )
   ,.clk_gated_o  ( clk_gated  )
 );

///////// WIRE OF INPUT OF CONTROLLER ////////////////////
logic ID_illegal_insn       ; 
logic ID_ecall_insn         ; 
logic ID_mret_insn          ; 
logic ID_dret_insn          ; 
logic ID_wfi_insn           ; 
logic ID_ebrk_insn          ; 
logic ID_csr_pipe_flush     ; 
logic ID_instr_valid        ;   
logic ID_instr              ;   
logic ID_instr_compressed   ;   
logic ID_instr_is_compressed;   
logic ID_instr_bp_taken     ;   
logic ID_instr_fetch_err    ;   
logic ID_pc                 ;   

logic lsu_addr_last        ; 
logic load_err             ; 
logic store_err            ; 
logic mem_resp_intg_err    ; 
logic branch               ; 
logic jump                 ; 
logic instr_fetch_err_plus2; 
logic debug_ebreaku        ;  
logic debug_ebreakm        ;  
logic csr_mstatus_mie      ;  
logic priv_mode            ;  
logic irq_pending          ;  
logic irqs                 ;  
logic irq_nm_ext           ;  
logic debug_req            ;  
logic debug_single_step    ;  
logic debug_ebreakm        ;  
logic trigger_match        ;  




controller control_main (
   .clk                     (clk)     
  ,.rst_n                   (rst_n)     
      // from ID ;
  ,.illegal_insn_i          (ID_illegal_insn  )           
  ,.ecall_insn_i            (ID_ecall_insn    )  
  ,.mret_insn_i             (ID_mret_insn     ) 
  ,.dret_insn_i             (ID_dret_insn     ) 
  ,.wfi_insn_i              (ID_wfi_insn      ) 
  ,.ebrk_insn_i             (ID_ebrk_insn     ) 
  ,.csr_pipe_flush_i        (ID_csr_pipe_flush)     
  
  ,.instr_valid_i           (ID_instr_valid        )       
  ,.instr_i                 (ID_instr              )       
  ,.instr_compressed_i      (IF_instr_compressed   )       
  ,.instr_is_compressed_i   (IF_instr_is_compressed)       
  ,.instr_bp_taken_i        ( )          
  ,.instr_fetch_err_i       (ID_instr_fetch_err    )          
  ,.pc_i                    (ID_pc                 )
  // from LSU;
  ,.lsu_addr_last_i         (lsu_addr_last        )      
  ,.load_err_i              (load_err             )      
  ,.store_err_i             (store_err            )      
  ,.mem_resp_intg_err_i     (mem_resp_intg_err    )      
  ,.branch_i                (branch               )   
  ,.jump_i                  (jump                 )   
  ,.instr_fetch_err_plus2_i (instr_fetch_err_plus2)   
  ,.debug_ebreaku_i         (debug_ebreaku        )   
  ,.debug_ebreakm_i         (debug_ebreakm        )   
  ,.csr_mstatus_mie_i       (csr_mstatus_mie      )   
  ,.priv_mode_i             (priv_mode            )  
  ,.irq_pending_i           (irq_pending          )  
  ,.irqs_i                  (irqs                 )  
  ,.irq_nm_ext_i            (irq_nm_ext           )  
  ,.debug_req_i             (debug_req            )  
  ,.debug_single_step_i     (debug_single_step    )  
  ,.debug_ebreakm_i         (debug_ebreakm        )  
  ,.trigger_match_i         (trigger_match        )  

   //// OUTPUT //////////
  ,.instr_valid_clear_o     ()     
  ,.controller_run_o        ()     
  ,.instr_req_o             ()     
  ,.pc_set_o                ()     
  ,.pc_mux_o                ()     
  ,.exc_pc_mux_o            ()     
  ,.flush_o                 ()     
  ,.exc_cause_o             ()     
  ,.nmi_mode_o              ()     
  ,.debug_cause_o           ()     
  ,.csr_mtval_o             ()     
  ,.csr_mstatus_mie         ()     
  ,.csr_save_o              ()     
  ,.csr_restore_mret_o      ()     
  ,.csr_restore_dret_o      ()     
  ,.csr_save_cause_o        ()     
  ,.irq_pending_o           ()     
  ,.irqs_o                  ()     
  ,.nmi_mode_o              ()     
  ,.core_sleep_o            ()     
  ,.debug_mode_o            ()     
  ,.debug_mode_entering_o   ()     
// ORTHER;
  ,.ctrl_busy_o             ()  
  ,.exception_o             ()  
  ,.perf_jump_o             ()  
  ,.perf_branch_o           ()  
  ,.debug_csr_save_o        ()  
 );

 endmodule



