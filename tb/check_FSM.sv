module check_FSM(
  input         clk                    ,         
  input         rst_n                  ,         
  input  [31:0] boot_add               ,         
  input  [31:0] Instr_in               ,         
  input  [31:0] D_in                   ,         
  input         irq_software_i         ,         
  input         irq_timer_i            ,            
  input         irq_external_i         ,
  input  [14:0] irq_fast_i             ,
  input         debug_req_i            ,      
  input         irq_nm_i               ,      
  input         data_gnt_i             ,      
  input         data_rvalid_i          ,      
  input         data_rdata_i           ,      
  input         data_err_i             ,      
  input         instr_gnt_i            ,      
  input         instr_rvalid_i         ,      
  input         instr_rdata_i          ,      
  input         instr_err_i            ,      
  input         instr_fetch_err_plus2_i,
  input         mem_resp_intg_err_i    
);
import pkg_1::*;

ctrl_fsm_e current_state;assign  current_state = top.control_main.current_state ; 
ctrl_fsm_e next_state   ;assign  next_state    = top.control_main.next_state    ;


  logic instr_valid_clear   ;assign  instr_valid_clear   = top.instr_valid_clear   ;     
  logic instr_req           ;assign  instr_req           = top.instr_req           ;     
  logic pc_set              ;assign  pc_set              = top.pc_set              ;     
  logic flush               ;assign  flush               = top.flush               ;     
  pkg::pc_sel_e     pc_mux            ;assign  pc_mux            = top.pc_mux           ; 
  pkg::exc_pc_sel_e exc_pc_mux        ;assign  exc_pc_mux        = top.exc_pc_mux       ; 
  pkg::exc_cause_t  exc_cause         ;assign  exc_cause         = top.exc_cause        ; 
  pkg::dbg_cause_e  debug_cause       ;assign  debug_cause       = top.debug_cause      ; 
  logic mtval_1bit          ;assign  mtval_1bit          = top.mtval_1bit          ;     
  logic csr_save            ;assign  csr_save            = top.csr_save            ;     
  logic csr_restore_mret    ;assign  csr_restore_mret    = top.csr_restore_mret    ;     
  logic csr_restore_dret    ;assign  csr_restore_dret    = top.csr_restore_dret    ;     
  logic csr_save_cause      ;assign  csr_save_cause      = top.csr_save_cause      ;     
  logic nmi_mode            ;assign  nmi_mode            = top.nmi_mode            ;     
  logic core_sleep          ;assign  core_sleep          = top.core_sleep          ;     
  logic debug_mode          ;assign  debug_mode          = top.debug_mode          ;     
  logic debug_mode_entering ;assign  debug_mode_entering = top.debug_mode_entering ;     

  logic ctrl_busy           ;assign  ctrl_busy           = top.ctrl_busy           ;     
  logic exception           ;assign  exception           = top.exception           ;     
  logic perf_jump           ;assign  perf_jump           = top.perf_jump           ;     
  logic perf_branch         ;assign  perf_branch         = top.perf_branch         ;     
  logic debug_csr_save      ;assign  debug_csr_save      = top.debug_csr_save      ;     

  logic enter_debug_mode    ; assign enter_debug_mode    = top.control_main.enter_debug_mode                       ;
  logic handle_irq          ; assign handle_irq          = top.control_main.handle_irq                             ;
  logic exception_o         ; assign exception_o         = top.control_main.exception_o                            ;
  logic do_single_step      ; assign do_single_step      = top.control_main.do_single_step_q                       ;
  logic wfi_insn            ; assign wfi_insn            = top.ID_wfi_insn                                         ;
  logic cond_sleep          ; assign cond_sleep          = wfi_insn & !debug_req_i & !do_single_step & !debug_mode ;
  logic debug_mode_q        ; assign debug_mode_q        = top.control_main.debug_mode_q                           ;
  logic debug_single_step_i ; assign debug_single_step_i = top.control_main.debug_single_step_i                    ;
  logic nmi_mode_q          ; assign nmi_mode_q          = top.control_main.nmi_mode_q                             ;
  logic irq_nm              ; assign irq_nm              = top.control_main.irq_nm                                 ;
  logic irq_pending_i       ; assign irq_pending_i       = top.control_main.irq_pending_i                          ;
  logic irq_enabled         ; assign irq_enabled         = top.control_main.irq_enabled                            ;
  logic cond_interupt       ; assign cond_interupt       = ~debug_mode_q & ~debug_single_step_i & ~nmi_mode_q &
 (irq_nm | (irq_pending_i & irq_enabled));

  logic enter_debug_mode_prio_d ; assign enter_debug_mode_prio_d = top.control_main.enter_debug_mode_prio_d                    ;
  logic trigger_match_i         ; assign trigger_match_i         = top.control_main.trigger_match_i                            ;
  logic cond_debug              ; assign cond_debug              = enter_debug_mode_prio_d | (trigger_match_i & ~debug_mode_q) ;
  logic load_err_q              ; assign load_err_q              = top.control_main.load_err_q                                 ;
  logic store_err_q             ; assign store_err_q             = top.control_main.store_err_q                                ;
  logic store_err_i             ; assign store_err_i             = top.control_main.store_err_i                                ;
  logic load_err_i              ; assign load_err_i              = top.control_main.load_err_i                                 ;
  logic cond_flush              ; assign cond_flush              = (load_err_q | store_err_q | store_err_i | load_err_i)       ;

  // common check
  property tran_state(current_state, cond, next_state);
   @(posedge clk) disable iff (!rst_n)
    ((current_state ) & (cond)) |=> (next_state);
  endproperty
  property output_of_state(current_state, delay, output_state);
   @(posedge clk) disable iff (!rst_n)
    (current_state ) |-> ##delay  (next_state);
  endproperty

  check_process_to_sleep: assert property(tran_state(.current_state(current_state == PROCESSING), .cond(cond_sleep), .next_state(current_state == WAIT_SLEEP)));
  check_process_to_interupt: assert property(tran_state(.current_state(current_state == PROCESSING), .cond(cond_interupt), .next_state(current_state == INTERUPT)));
  check_process_to_debug: assert property(tran_state(.current_state(current_state == PROCESSING), .cond(cond_debug), .next_state(current_state == DEBUG)));
  check_process_to_flush: assert property(tran_state(.current_state(current_state == PROCESSING), .cond(cond_flush), .next_state(current_state == FLUSH)));



endmodule


