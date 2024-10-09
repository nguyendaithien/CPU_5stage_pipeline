`include "defi.vh"
module CPU_EDABK_TOP #( parameter DATA_WIDTH = 32) (
  input               clk            ,
  input               rst_n          ,
  input        [31:0] boot_add       ,
  input        [31:0] Instr_in       ,
  input        [31:0] D_in           ,
  input  logic        irq_software_i ,
  input  logic        irq_timer_i    ,
  input  logic        irq_external_i ,
  input  logic [14:0] irq_fast_i     ,
  input  logic        debug_req_i    ,      
  input  logic        irq_nm_i       ,      
  input  logic        data_gnt_i     ,      
  input  logic        data_rvalid_i  ,      
  input  logic        data_rdata_i   ,      
  input  logic        data_err_i     ,      
  input  logic        instr_gnt_i    ,      
  input  logic        instr_rvalid_i ,      
  input  logic        instr_rdata_i  ,      
  input  logic        instr_err_i    ,      
  input  logic        instr_fetch_err_plus2_i,
  input  logic        mem_resp_intg_err_i    ,
  output logic [31:0] A_DMEM         ,
  output logic        instr_req      ,
  output logic   data_req_o          ,
  output logic [31:0] A_IMEM         ,
  output logic [31:0] D_out          ,
  output logic        RD            ,
  output logic        WR            ,
  output logic   irq_pending_o       ,
  output logic   crash_dump_o        ,
  output logic [3:0 ] byte_mark      ,
  output logic        DMEM_rst       ,  
  output logic        core_busy_o       
 );
 import pkg::*;

  logic [4:0 ] WB_rd_add         ;
  logic [31:0] WB_data_write_reg ;
  logic        WB_regwrite       ;
  // output of IF stage
  logic [31:0] IF_instr          ;
  logic [4:0 ] IMEM_add          ;
  logic [31:0] IF_pc             ;

// hazard control
  logic stall       ;
  logic IF_ID_flush ;
  logic EX_flush    ;
  // OUTPUT ID stage
  logic [4:0 ] ID_rs1_add        ;
  logic [4:0 ] ID_rs2_add        ;
  logic [4:0 ] ID_rd_add         ;
  logic [31:0] ID_rs1_data       ;
  logic [31:0] ID_rs2_data       ;
  logic [31:0] ID_pc             ;
  logic [3:0 ] ID_alu_op         ;
  logic [31:0] ID_imm            ;
  logic [1:0 ] ID_sel_to_reg     ;
  logic        ID_regwrite       ;
  logic [3:0 ] ID_mem_op         ;
  logic        ID_jump           ;
  logic ID_RD                    ;
  logic ID_WR                    ;
  logic        ID_branch         ;
  logic [1:0 ] ID_alu_sel1       ;
  logic [1:0 ] ID_alu_sel2       ;
  logic        ID_pc_sel         ;
  // OUTPUT EX stage
  logic [31:0] EX_pc             ;
  logic [4:0 ] EX_rs1_add        ;
  logic [4:0 ] EX_rs2_add        ;
  logic [4:0 ] EX_rd_add         ;
  logic [1:0 ] EX_sel_to_reg     ;
  logic        EX_regwrite       ;
  logic        EX_RD             ;
  logic        EX_WR             ;
  logic [3:0 ] EX_mem_op         ;
  logic [31:0] EX_alu_result     ;
  logic        EX_zero           ;
  logic [31:0] EX_imm            ;
  logic [31:0] EX_pc_dest        ;
  logic [31:0] EX_rs2_data       ;
  logic        EX_branch         ;
  logic        EX_jump           ;
  // output of MEM stage
  logic [31:0] MEM_add           ;
  logic [3:0 ] DMEM_byte_mark    ;
  logic [31:0] DMEM_data_write   ;
  logic [31:0] MEM_data          ;
  logic [31:0] DMEM_data_o       ;
  logic        MEM_regwrite      ;
  logic [31:0] MEM_alu_result    ;
  logic [4:0 ] MEM_rd_add        ;
  logic [1:0 ] MEM_sel_to_reg    ;
  logic        MEM_RD_mem        ;
  logic        MEM_WR_mem        ;
  logic [31:0] MEM_pc            ;
  logic [1:0 ] forward_A         ;
  logic [1:0 ] forward_B         ;
  logic [31:0] MEM_imm           ;
  logic        forward_dmem      ;

  assign RD        = MEM_RD_mem     ;
  assign WR        = MEM_WR_mem     ;
  assign byte_mark = DMEM_byte_mark ;

  wire pc_sel = ((EX_branch &  EX_zero) | EX_jump);

  logic [15:0] IF_instr_compressed;
  logic ID_illegal_insn       ; 
  logic ID_ecall_insn         ; 
  logic ID_mret_insn          ; 
  logic ID_dret_insn          ; 
  logic ID_wfi_insn           ; 
  logic ID_ebrk_insn          ; 
  logic ID_csr_pipe_flush     ; 
  logic ID_instr_valid        ;   
  logic [31:0] ID_instr       ;   
  logic ID_instr_compressed   ;   
  logic ID_instr_is_compressed;   
  logic ID_instr_bp_taken     ;   
  logic IF_instr_fetch_err    ;   
  
  logic [31:0] lsu_addr_last  ; 
  logic MEM_load_err          ; 
  logic MEM_store_err         ; 
  logic mem_resp_intg_err     ; 
  logic branch                ; 
  logic jump                  ; 
  logic instr_fetch_err_plus2 ; 
  logic debug_ebreaku         ;  
  logic priv_mode             ;  
  logic irq_nm_ext            ;  
  logic debug_single_step     ;  
  logic debug_ebreakm         ;  
  logic trigger_match         ;  

  logic instr_valid_clear             ;            
  logic pc_set                        ;
  logic flush                         ;
  exc_cause_t exc_cause               ;
  dbg_cause_e debug_cause             ;
  logic csr_save                      ;
  logic csr_restore_mret              ;
  logic csr_restore_dret              ;
  logic csr_save_cause                ;
  logic core_sleep                    ;
  
  logic ctrl_busy                     ;            
  logic exception                     ;
  logic perf_jump                     ;
  logic perf_branch                   ;

  // CSR logic
  logic  [31:0] hart_id                  ;
  logic  [31:0] csr_wdata                ;
  priv_lvl_e priv_mode_id                ;
  priv_lvl_e priv_mode_lsu               ;
  logic  csr_mstatus_tw                  ;
  logic  [31:0] csr_mtvec                ;
  logic  csr_mtvec_init                  ;
  logic  [31:0] boot_addr                ;
  logic  csr_access                      ;
  csr_num_e csr_addr                     ;
  logic  [31:0] csr_wd1ata               ;
  csr_op_e csr_op                        ;
  logic  csr_op_en                       ;
  logic  [31:0] csr_rdata                ;
  logic  irq_software                    ;
  logic  irq_timer                       ;
  logic  irq_external                    ;
  logic  [14:0] irq_fast                 ;
  logic  nmi_mode                        ;
  logic  irq_pending                     ;
  irqs_t irqs                            ;
  logic  csr_mstatus_mie                 ;
  logic  [31:0] csr_mepc                 ;
  logic  [31:0] csr_mtval                ;
  pmp_cfg_t csr_pmp_cfg [4]              ;
  logic  [33:0] csr_pmp_addr  [4]        ;
  pmp_mseccfg_t csr_pmp_mseccfg          ;
  logic  debug_mode                      ;
  logic  debug_mode_entering             ;
  logic  debug_csr_save                  ;
  logic  [31:0] csr_depc                 ;
  logic  [31:0] pc                       ;
  logic  data_ind_timing                 ;
  logic  dummy_instr_en                  ;
  logic  [2:0] dummy_instr_mask          ;
  logic  dummy_instr_seed_en             ;
  logic  [31:0] dummy_instr_seed         ;
  logic  icache_enable                   ;
  logic  csr_shadow_err                  ;
  logic  ic_scr_key_valid                ;
  exc_cause_t csr_mcause                 ;
  logic  double_fault_seen               ;
  logic  instr_ret                       ;
  logic  instr_ret_compressed            ;
  logic  instr_ret_spec                  ;
  logic  instr_ret_compressed_spec       ;
  logic  iside_wait                      ;
  logic  branch_taken                    ;
  logic  mem_load                        ;
  logic  mem_store                       ;
  logic  dside_wait                      ;
  logic  mul_wait                        ;
  logic  div_wait                        ;
  logic mtval_1bit;

  logic is_compressed                    ;
  logic illegal_instr                    ;

  pc_sel_e pc_sel_mux          ;
  exc_pc_sel_e exc_pc_sel      ;
  csr_op_e ID_csr_op           ;
  pc_sel_e pc_mux              ;
  exc_pc_sel_e exc_pc_mux      ;
  rf_wd_sel_e ID_rf_wdata_sel  ;
  rf_wd_sel_e EX_rf_wdata_sel  ;
  rf_wd_sel_e MEM_rf_wdata_sel ;
  rf_wd_sel_e WB_rf_wdata_sel  ;

  logic ID_instr_c_illegal; 
  
logic [31:0] ID_imm_i_type   ;  
logic [31:0] ID_imm_s_type   ;
logic [31:0] ID_imm_b_type   ;
logic [31:0] ID_imm_u_type   ;
logic [31:0] ID_imm_j_type   ;


  IF_stage #( .DATA_WIDTH(32))  if_stage (
     .clk              (clk          )
    ,.rst_n            (rst_n        )
    ,.IF_instr_i       (Instr_in     )
    ,.boot_addr_i      (boot_add     )
    ,.flush            (IF_ID_flush  )
    ,.pc_dest          (EX_pc_dest   )
    ,.IMEM_data_i      (Instr_in     )
    ,.stall            (stall        )
    ,.pc_sel           (pc_sel       )
    ,.IF_pc_o          (IF_pc        )
    ,.IF_instr_o       (IF_instr     )
    ,.IMEM_add_o       (A_IMEM       )
    ,.IF_pc_sel_mux_i  (pc_sel_mux   )
    ,.IF_exc_sel_i     (exc_pc_sel   )
    ,.is_compressed_o  (is_compressed)
    ,.illegal_instr_o  (illegal_instr)
    ,.IF_instr_fetch_err_o(IF_instr_fetch_err)
    ,.pc_set_i         (pc_set       )
    ,.csr_mepc_i       (csr_mepc     )  
    ,.csr_depc_i       (csr_depc     )  
    ,.csr_mtvec_i      (csr_mtvec    )  
    ,.IF_instr_compressed_o (IF_instr_compressed)

  );


  ID_stage #( .DATA_WIDTH(32)) id_stage (
   .clk                  (clk                 ) 
  ,.rst_n                (rst_n               )
  ,.stall                (stall               )
  ,.flush                (IF_ID_flush         )
  ,.ID_instr_i           (IF_instr            )
	,.EX_zero_i            (EX_zero             )
	,.EX_branch_i          (EX_branch           )
	,.EX_jump_i            (EX_jump             )
  ,.EX_ALU_result_i      (EX_alu_result       )
  ,.EX_rd_add_i          (EX_rd_add           )
  ,.WB_data_i            (WB_data_write_reg   )
  ,.WB_regwrite_i        (WB_regwrite         )
  ,.WB_rd_add_i          (WB_rd_add           )
  ,.ID_pc_i              (IF_pc               )
  ,.ID_rs1_add_o         (ID_rs1_add          )
  ,.ID_rs2_add_o         (ID_rs2_add          )
  ,.ID_rd_add_o          (ID_rd_add           )
  ,.ID_rs1_data_o        (ID_rs1_data         )
  ,.ID_rs2_data_o        (ID_rs2_data         )
  ,.ID_pc_o              (ID_pc               )
  ,.ID_imm_o             (ID_imm              )
  ,.ID_alu_op_o          (ID_alu_op           )
  ,.ID_regwrite_o        (ID_regwrite         )
  ,.ID_mem_op_o          (ID_mem_op           )
  ,.ID_jump_o            (ID_jump             )
  ,.ID_sel_to_reg_o      (ID_sel_to_reg       )
  ,.ID_RD_en_o           (ID_RD               )
  ,.ID_WR_en_o           (ID_WR               )
  ,.ID_branch_o          (ID_branch           )
  ,.ID_alu_sel1_o        (ID_alu_sel1         )
  ,.ID_alu_sel2_o        (ID_alu_sel2         )
  ,.ID_pc_sel_o          (ID_pc_sel           )
  ,.ID_rf_wdata_sel_i    (WB_rf_wdata_sel     )             
  ,.ID_dret_insn_o       (ID_dret_insn        )             
  ,.ID_ecall_insn_o      (ID_ecall_insn       )             
  ,.ID_illegal_insn_o    (ID_illegal_insn     )             
  ,.ID_ebrk_insn_o       (ID_ebrk_insn        )             
  ,.ID_mret_insn_o       (ID_mret_insn        )             
  ,.ID_wfi_insn_o        (ID_wfi_insn         )             
  ,.ID_imm_i_type_o      (ID_imm_i_type       )             
  ,.ID_imm_s_type_o      (ID_imm_s_type       )             
  ,.ID_imm_b_type_o      (ID_imm_b_type       )             
  ,.ID_imm_u_type_o      (ID_imm_u_type       )             
  ,.ID_imm_j_type_o      (ID_imm_j_type       )             
  ,.ID_csr_access_o      (ID_csr_access       )             
  ,.ID_csr_op_o          (ID_csr_op           )             
  ,.ID_data_req_o        (ID_data_req         )             
  ,.ID_instr_c_illegal_i (ID_instr_c_illegal  )
  ,.ID_rf_wdata_sel_o    (ID_rf_wdata_sel     )
  ,.ID_csr_data_i        (csr_rdata           )

);


  EX_stage #( .DATA_WIDTH(32)) ex_stage (
     .clk              (clk               )                               
    ,.rst_n            (rst_n             )
    ,.EX_pc_i          (ID_pc             )
    ,.EX_rs1_add_i     (ID_rs1_add        )
    ,.EX_rs2_add_i     (ID_rs2_add        )
    ,.EX_rd_add_i      (ID_rd_add         )
    ,.EX_sel_to_reg_i  (ID_sel_to_reg     )
    ,.EX_rf_wdata_sel_i(ID_rf_wdata_sel   )
    ,.EX_rf_wdata_sel_o(EX_rf_wdata_sel   )
    ,.EX_regwrite_i    (ID_regwrite       )
		,.EX_branch_i      (ID_branch         )
		,.EX_jump_i        (ID_jump           )
    ,.EX_RD_mem_i      (ID_RD             )
    ,.EX_WR_mem_i      (ID_WR             )
    ,.EX_mem_op_i      (ID_mem_op         )
    ,.EX_rs2_data_i    (ID_rs2_data       )
    ,.EX_rs1_data_i    (ID_rs1_data       )
    ,.EX_sel_alu1_i    (ID_alu_sel1       )
    ,.EX_sel_alu2_i    (ID_alu_sel2       )
    ,.EX_imm_i         (ID_imm            )
		,.EX_alu_op_i      (ID_alu_op         )
    ,.flush            (EX_flush          )
    ,.forwardA         (forward_A         )
    ,.forwardB         (forward_B         )
    ,.WB_data_i        (WB_data_write_reg )
    ,.EX_data_i        (EX_alu_result     )
    ,.hazard           (hazard            )
    ,.EX_rs2_data_o    (EX_rs2_data       )
    ,.EX_pc_o          (EX_pc             )
    ,.EX_rs1_add_o     (EX_rs1_add        )
    ,.EX_rs2_add_o     (EX_rs2_add        )
    ,.EX_rd_add_o      (EX_rd_add         )
    ,.EX_sel_to_reg_o  (EX_sel_to_reg     )
    ,.EX_regwrite_o    (EX_regwrite       )
    ,.EX_RD_mem_o      (EX_RD             )
    ,.EX_WR_mem_o      (EX_WR             )
    ,.EX_mem_op_o      (EX_mem_op         )
    ,.EX_alu_result_o  (EX_alu_result     )
    ,.EX_zero_o        (EX_zero           )
    ,.EX_imm_o         (EX_imm            )
    ,.EX_pc_dest       (EX_pc_dest        )
	  ,.EX_branch_o      (EX_branch         )
	  ,.EX_jump_o        (EX_jump           )
);

   MEM_stage #( .DATA_WIDTH(32)) mem_stage (
     .clk               (clk               )
    ,.rst_n             (rst_n             )
    ,.WB_data_i         (WB_data_write_reg )
    ,.MEM_rf_wdata_sel_i(EX_rf_wdata_sel   )
    ,.MEM_rf_wdata_sel_o(MEM_rf_wdata_sel  )
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
    ,.DMEM_data_i       (D_in              ) 
    ,.DMEM_rst_o        (DMEM_rst          )
    ,.load_err_o        (MEM_load_err      )
    ,.store_err_o       (MEM_store_err     )
    ,.last_add_o        (lsu_addr_last     )
  );

  WB_stage #(.DATA_WIDTH(32))  wb_stage (
     .clk                   (clk               )
    ,.rst_n                 (rst_n             )
    ,.WB_rf_wdata_sel_i     (MEM_rf_wdata_sel  )
    ,.WB_rf_wdata_sel_o     (WB_rf_wdata_sel   )
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

 logic clk_gated  ;

 SLEEP_UNIT sleep_unit (
   .clk_i         ( clk        )
   ,.rst_n        ( rst_n      )
   ,.core_sleep_i ( core_sleep )
   ,.clk_gated_o  ( clk_gated  )
 );


  controller control_main (
    .clk                      (clk              )
    ,.rst_n                   (rst_n            )
    ,.illegal_insn_i          (ID_illegal_insn  )           
    ,.ecall_insn_i            (ID_ecall_insn    )  
    ,.mret_insn_i             (ID_mret_insn     ) 
    ,.dret_insn_i             (ID_dret_insn     ) 
    ,.wfi_insn_i              (ID_wfi_insn      ) 
    ,.ebrk_insn_i             (ID_ebrk_insn     ) 
    ,.csr_pipe_flush_i        (ID_csr_pipe_flush)     
    
    ,.instr_valid_i           (instr_rvalid_i        )       
    ,.instr_i                 (IF_instr              )       
    ,.instr_compressed_i      (IF_instr_compressed   )       
    ,.instr_is_compressed_i   (IF_instr_is_compressed)       
    ,.instr_bp_taken_i        ( )          
    ,.instr_fetch_err_i       (IF_instr_fetch_err    )          
    ,.pc_i                    (ID_pc                 )
    // from LSU;
    ,.lsu_addr_last_i         (lsu_addr_last         )      
    ,.load_err_i              (MEM_load_err          )      
    ,.store_err_i             (MEM_store_err         )      
    ,.mem_resp_intg_err_i     (mem_resp_intg_err_i   )      
    ,.branch_i                (ID_branch             )   
    ,.jump_i                  (ID_jump               )   
    ,.instr_fetch_err_plus2_i (instr_fetch_err_plus2_i )   
    ,.debug_ebreaku_i         (debug_ebreaku         )   
    ,.csr_mstatus_mie_i       (csr_mstatus_mie       )   
    ,.priv_mode_i             (priv_mode             )  
    ,.irq_pending_i           (irq_pending           )  
    ,.irqs_i                  (irqs                  )  
    ,.irq_nm_ext_i            (irq_nm_i              )  
    ,.debug_req_i             (debug_req_i           )  
    ,.debug_single_step_i     (debug_single_step     )  
    ,.debug_ebreakm_i         (debug_ebreakm         )  
    ,.trigger_match_i         (1'b0                  )  
  
     //// OUTPUT //////////
    ,.instr_valid_clear_o     (instr_valid_clear     )     
    ,.instr_req_o             (instr_req             )     
    ,.pc_set_o                (pc_set                )     
    ,.pc_mux_o                (pc_sel_mux            )     
    ,.exc_pc_mux_o            (exc_pc_sel            )     
    ,.flush_o                 (flush                 )     
    ,.exc_cause_o             (exc_cause             )     
    ,.debug_cause_o           (debug_cause           )     
    ,.csr_mtval_o             (mtval_1bit            )     
    ,.csr_save_o              (csr_save              )     
    ,.csr_restore_mret_o      (csr_restore_mret      )     
    ,.csr_restore_dret_o      (csr_restore_dret      )     
    ,.csr_save_cause_o        (csr_save_cause        )     
    ,.nmi_mode_o              (nmi_mode              )     
    ,.core_sleep_o            (core_sleep            )     
    ,.debug_mode_o            (debug_mode            )     
    ,.debug_mode_entering_o   (debug_mode_entering   )     
  
    ,.ctrl_busy_o             (ctrl_busy             )  
    ,.exception_o             (exception             )  
    ,.perf_jump_o             (perf_jump             )  
    ,.perf_branch_o           (perf_branch           )  
    ,.debug_csr_save_o        (debug_csr_save        )  
 );
 

  cs_registers control_state_reg (
     .clk                          (clk                        ) 
    ,.rst_n                        (rst_n                      )                                          
    ,.hart_id_i                    (hart_id                    )                    
    ,.csr_wdata_i                  (csr_wdata                  )                    
    ,.priv_mode_id_o               (priv_mode_id               )                    
    ,.priv_mode_lsu_o              (priv_mode_lsu              )                    
    ,.csr_mstatus_tw_o             (csr_mstatus_tw             )                    
    ,.csr_mtvec_o                  (csr_mtvec                  )                    
    ,.csr_mtvec_init_i             (csr_mtvec_init             )                    
    ,.boot_addr_i                  (boot_addr                  )                    
    ,.csr_access_i                 (csr_access                 )                    
    ,.csr_addr_i                   (csr_addr                   )                    
    ,.csr_wd1ata_i                 (csr_wd1ata                 )                    
    ,.csr_op_i                     (csr_op                     )                    
    ,.csr_op_en_i                  (csr_op_en                  )                    
    ,.csr_rdata_o                  (csr_rdata                  )                    
    ,.irq_software_i               (irq_software               )                    
    ,.irq_timer_i                  (irq_timer                  )                    
    ,.irq_external_i               (irq_external               )                    
    ,.irq_fast_i                   (irq_fast                   )                    
    ,.nmi_mode_i                   (nmi_mode                   )                    
    ,.irq_pending_o                (irq_pending                )                    
    ,.irqs_o                       (irqs                       )                    
    ,.csr_mstatus_mie_o            (csr_mstatus_mie            )                    
    ,.csr_mepc_o                   (csr_mepc                   )                    
    ,.csr_mtval_o                  (csr_mtval                  )                    
    ,.csr_pmp_cfg_o                (csr_pmp_cfg                )                    
    ,.csr_pmp_addr_o               (csr_pmp_addr               )                    
    ,.csr_pmp_mseccfg_o            (csr_pmp_mseccfg            )                    
    ,.debug_mode_i                 (debug_mode                 )                    
    ,.debug_mode_entering_i        (debug_mode_entering        )                    
    ,.debug_cause_i                (debug_cause                )                    
    ,.debug_csr_save_i             (debug_csr_save             )                    
    ,.csr_depc_o                   (csr_depc                   )                    
    ,.debug_single_step_o          (debug_single_step          )                    
    ,.debug_ebreakm_o              (debug_ebreakm              )                    
    ,.debug_ebreaku_o              (debug_ebreaku              )                    
    ,.trigger_match_o              (trigger_match              )                    
    ,.pc_i                         (pc                         )                    
    ,.data_ind_timing_o            (data_ind_timing            )                    
    ,.dummy_instr_en_o             (dummy_instr_en             )                    
    ,.dummy_instr_mask_o           (dummy_instr_mask           )                    
    ,.dummy_instr_seed_en_o        (dummy_instr_seed_en        )                    
    ,.dummy_instr_seed_o           (dummy_instr_seed           )                    
    ,.icache_enable_o              (icache_enable              )                    
    ,.csr_shadow_err_o             (csr_shadow_err             )                    
    ,.ic_scr_key_valid_i           (ic_scr_key_valid           )                    
    ,.csr_save_i                   (csr_save                   )                    
    ,.csr_restore_mret_i           (csr_restore_mret           )                    
    ,.csr_restore_dret_i           (csr_restore_dret           )                    
    ,.csr_save_cause_i             (csr_save_cause             )                    
    ,.csr_mcause_i                 (csr_mcause                 )                    
    ,.csr_mtval_i                  (csr_mtval                  )                    
    ,.illegal_csr_insn_o           (illegal_csr_insn           )                    
    ,.double_fault_seen_o          (double_fault_seen          )                    
    ,.instr_ret_i                  (instr_ret                  )                                              
    ,.instr_ret_compressed_i       (instr_ret_compressed       )                                              
    ,.instr_ret_spec_i             (instr_ret_spec             )                                              
    ,.instr_ret_compressed_spec_i  (instr_ret_compressed_spec  )                                              
    ,.iside_wait_i                 (iside_wait                 )                                              
    ,.jump_i                       (jump                       )                                              
    ,.branch_i                     (ID_branch                  )                                              
    ,.branch_taken_i               (branch_taken               )                                               
    ,.mem_load_i                   (mem_load                   )                                               
    ,.mem_store_i                  (mem_store                  )                                               
    ,.dside_wait_i                 (dside_wait                 )                                               
    ,.mul_wait_i                   (mul_wait                   )                                               
    ,.div_wait_i                   (div_wait                   )                    
    );
    

endmodule



