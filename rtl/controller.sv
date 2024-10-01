module controller (
  input              clk                     ,
  input              rst_n                   ,
  input              debug_ebreaku_i         ,
  input logic        illegal_insn_i          ,
  input logic        ecall_insn_i            ,
  input logic        mret_insn_i             ,
  input logic        dret_insn_i             ,
  input logic        wfi_insn_i              ,
  input logic        ebrk_insn_i             ,
  input logic        csr_pipe_flush_i        ,
  input logic        instr_fetch_err_plus2_i ,
  input logic        instr_valid_i           ,
  input logic [31:0] instr_i                 ,
  input logic [15:0] instr_compressed_i      ,
  input logic        instr_is_compressed_i   ,
  input logic        instr_bp_taken_i        ,
  input logic        instr_fetch_err_i       ,
  input logic [31:0] pc_i                    ,
  input logic [31:0] lsu_addr_last_i         , // last addr load or store ;
  input logic        load_err_i              ,
  input logic        store_err_i             ,
  input logic        mem_resp_intg_err_i     ,
  input logic        branch_i                ,
  input logic        jump_i                  ,
  input logic        csr_mstatus_mie_i       ,
  input logic        irq_pending_i           ,
  input logic        priv_mode_i             ,

  input pkg::irqs_t  irqs_i                  ,

  input  logic             irq_nm_ext_i        ,
  input  logic             debug_req_i         ,
  input  logic             debug_single_step_i ,
  input  logic             debug_ebreakm_i     ,
  input  logic             trigger_match_i     ,
  output logic             instr_valid_clear_o ,
  output logic             controller_run_o    ,
  output logic             instr_req_o         ,
  output logic             pc_set_o            , // TOP                                 ;
  output pkg::pc_sel_e     pc_mux_o            , // IF                                  ;
  output pkg::exc_pc_sel_e exc_pc_mux_o        , //(IF)                                 ;
  output pkg::exc_cause_t  exc_cause_o         ,
  output pkg::dbg_cause_e  debug_cause_o       ,
  output logic             nmi_mode_o          ,
  output logic             csr_mtval_o         ,
  output logic             csr_mstatus_mie     ,
  output logic             csr_save_o          , // instead of csr_save_if, csr_save_id
  output logic             csr_restore_mret_o  ,
  output logic             csr_restore_dret_o  ,
  output logic             csr_save_cause_o    ,
  output logic             debug_csr_save_o    ,

// SLEEP UNIT
  output logic core_sleep_o          ,
  //INTERUPT to CSR
  output logic irq_pending_o         ,
  output logic irqs_o                ,
  
  // DEBUG to CSR
  output logic debug_mode_o          ,
  output logic debug_mode_entering_o ,

//ORTHER
  output logic flush_o       ,
  output logic exception_o   ,
  output logic perf_jump_o   ,
  output logic perf_branch_o ,
  output logic ctrl_busy_o   
 );
  import pkg::*;

   ctrl_fsm_e current_state;
   ctrl_fsm_e next_state   ;

  logic ecall_insn_prio            ;
  logic store_err_q                ;
  logic store_err_d                ;
  logic load_err_q                 ;
  logic load_err_d                 ;
  assign load_err_d  = load_err_i  ;
  assign store_err_d = store_err_i ;
  logic [3:0] mfip_id              ;
  logic irq_nm                     ;
  logic irq_nm_int                 ;
  logic irq_nm_int_mtval           ;
  logic irq_nm_int_cause           ;
  
  logic  halt_if                                          ;
  logic  ecall_insn, ebrk_insn, instr_fetch_err, wfi_insn ;
  logic illegal_insn_q                                    ;
  logic illegal_insn_d                                    ;
  logic  nmi_mode_q, nmi_mode_d                           ;
  logic  debug_mode_q, debug_mode_d                       ;
  logic  enter_debug_mode                                 ;
  logic  enter_debug_mode_prio_d                          ;
  logic  enter_debug_mode_prio_q                          ;
  logic  exc_req_d = (ecall_insn | ebrk_insn | illegal_insn_d | instr_fetch_err) & (current_state != FLUSH);
  logic  exc_req_q                    ;
  logic  dret_insn, mret_insn         ;
  logic  illegal_insn_prio            ;
  logic  ebrk_insn_prio               ;
  logic  load_err_prio,store_err_prio ;
  logic  ebreak_into_debug            ;
  logic  instr_fetch_err_prio         ;
  logic irq_enabled                   ;

  //DEBUG CAUSE
  pkg::dbg_cause_e debug_cause_d;
  pkg::dbg_cause_e debug_cause_q;
  logic do_single_step_d;
  logic do_single_step_q;


  assign enter_debug_mode = enter_debug_mode_prio_d | (trigger_match_i & ~debug_mode_q);
  assign enter_debug_mode_prio_d = (debug_req_i | debug_single_step_i) & ~debug_mode_q ;
  assign nmi_mode_o = nmi_mode_q;
  assign illegal_insn_d = illegal_insn_i & (current_state != FLUSH);

  assign do_single_tep_d = instr_valid_i ? (~debug_mode_q & debug_single_step_i) : do_single_step_q;

  assign ebreak_into_debug = priv_mode_i == PRIV_LVL_M ? debug_ebreakm_i :
                               priv_mode_i == PRIV_LVL_U ? debug_ebreaku_i : 1'b0;
  assign debug_cause_d = trigger_match_i    ? DBG_CAUSE_TRIGGER : 
   ebrk_insn_prio & ebreak_into_debug ? DBG_CAUSE_EBREAK : debug_req_i   ? DBG_CAUSE_HALTREQ : do_single_step_d  ? DBG_CAUSE_STEP  :DBG_CAUSE_NONE ;


  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        nmi_mode_q              <=  1'b0;
        do_single_step_q        <=  1'b0;
        debug_mode_q            <=  1'b0;
        enter_debug_mode_prio_q <=  1'b0;
        load_err_q              <=  1'b0;
        store_err_q             <=  1'b0;
        exc_req_q               <=  1'b0;
        illegal_insn_q          <=  1'b0;
    end else begin
        nmi_mode_q              <= nmi_mode_d              ;
        do_single_step_q        <= do_single_step_d        ;
        debug_mode_q            <= debug_mode_d            ;
        enter_debug_mode_prio_q <= enter_debug_mode_prio_d ;
        load_err_q              <= load_err_d              ;
        store_err_q             <= store_err_d             ;
        exc_req_q               <= exc_req_d               ;
        illegal_insn_q          <= illegal_insn_d          ;
    end
  end
      
      
  always_comb begin
    instr_fetch_err_prio = 0;
    illegal_insn_prio    = 0;
    ecall_insn_prio      = 0;
    ebrk_insn_prio       = 0;
    store_err_prio       = 0;
    load_err_prio        = 0;
    if (store_err_q) begin
      store_err_prio = 1'b1;
    end else if (load_err_q) begin
        load_err_prio  = 1'b1;
    end else if (instr_fetch_err) begin
        instr_fetch_err_prio = 1'b1;
    end else if (illegal_insn_q) begin
        illegal_insn_prio = 1'b1;
    end else if (ecall_insn) begin
        ecall_insn_prio = 1'b1;
    end else if (ebrk_insn) begin
        ebrk_insn_prio = 1'b1;
    end
  end


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       debug_cause_q <= DBG_CAUSE_NONE;
    end else begin
      debug_cause_q <= debug_cause_d;
    end
  end

  assign debug_cause_o = debug_cause_q;



  // Interupt of system = irq external + irq_internal
  //
  assign exception_o = (load_err_q | store_err_q | store_err_i | load_err_i);
  assign irq_nm = irq_nm_ext_i | irq_nm_int;
  assign irq_nm_int = mem_resp_intg_err_i;
  logic [31:0] mem_resp_intg_err_addr_q, mem_resp_intg_err_addr_d;

  always_comb begin
    if(mem_resp_intg_err_i) begin
      mem_resp_intg_err_addr_d = lsu_addr_last_i;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      mem_resp_intg_err_addr_q <= 0;
    end else begin
      mem_resp_intg_err_addr_q <= mem_resp_intg_err_addr_d ;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      current_state <= RESET;
    end
    else begin
      current_state <= next_state;
    end
  end

  assign irq_enabled = csr_mstatus_mie_i;
  
  logic handle_irq = ~debug_mode_q & ~debug_single_step_i & ~nmi_mode_q & 
 (irq_nm | (irq_pending_i & irq_enabled));

  always_comb begin
    instr_req_o           = 1'b1                 ;
    csr_save_o            = 1'b0                 ;
    csr_restore_mret_o    = 1'b0                 ;
    csr_restore_dret_o    = 1'b0                 ;
    csr_save_cause_o      = 1'b0                 ;
    csr_mtval_o           = 1'b0                 ;
    pc_mux_o              = PC_BOOT              ;
    pc_set_o              = 1'b0                 ;
    exc_pc_mux_o          = EXC_PC_IRQ           ;
    exc_cause_o           = ExcCauseInsnAddrMisa ;
    next_state            = current_state        ;
    halt_if               = 1'b0                 ;
    flush_o               = 1'b0                 ;
    debug_csr_save_o      = 1'b0                 ;
    debug_mode_d          = debug_mode_q         ;
    debug_mode_entering_o = 1'b0                 ;
    nmi_mode_d            = nmi_mode_q           ;
    perf_jump_o           = 1'b0                 ;
    perf_branch_o         = 1'b0                 ;

  assign ecall_insn      = ecall_insn_i      & instr_valid_i;
  assign mret_insn       = mret_insn_i       & instr_valid_i;
  assign dret_insn       = dret_insn_i       & instr_valid_i;
  assign wfi_insn        = wfi_insn_i        & instr_valid_i;
  assign ebrk_insn       = ebrk_insn_i       & instr_valid_i;
  //assign csr_pipe_flush  = csr_pipe_flush_i  & instr_valid_i;
  assign instr_fetch_err = instr_fetch_err_i & instr_valid_i;

  unique case (current_state)
    RESET: begin
      instr_req_o = 1'b0     ;
      pc_mux_o    = PC_BOOT  ;
      pc_set_o    = 1'b1     ;
      next_state  = BOOT_SET ;
    end
    BOOT_SET: begin
      instr_req_o = 1'b1       ;
      pc_mux_o    = PC_BOOT    ;
      pc_set_o    = 1'b1       ;
      next_state  = PROCESSING ;
    end
    WAIT_SLEEP: begin
      ctrl_busy_o = 1'b0 ;
      instr_req_o = 1'b0 ;
      halt_if     = 1'b1 ;
      flush_o     = 1'b1 ;
      next_state  = SLEEP;
    end
    SLEEP: begin
      instr_req_o  = 1'b0 ;
      halt_if      = 1'b1 ;
      flush_o      = 1'b1 ;
      core_sleep_o = 1'b1 ;
      
      if( irq_nm_ext_i || irq_pending_i || debug_req_i || debug_ebreakm_i || debug_single_step_i ) begin
        next_state = PROCESSING;
      end else begin
        ctrl_busy_o = 1'b0;
      end
    end

    PROCESSING: begin
      if(handle_irq) begin
        next_state = INTERUPT;
        halt_if    = 1'b1    ;
      end
      if(enter_debug_mode) begin
        next_state = DEBUG;
        halt_if    = 1'b1 ;
      end
      if(exception_o) begin
        next_state = FLUSH;
      end
      if(branch_i | jump_i) begin
        perf_branch_o = branch_i;
        perf_jump_o   = jump_i  ; 
      end
      if(wfi_insn_i & ~debug_req_i & ~do_single_step_q & ~debug_mode_o) begin
        next_state = WAIT_SLEEP;
      end

    end

    INTERUPT: begin
      pc_mux_o    = PC_EXC     ;
      exc_pc_mux_o = EXC_PC_IRQ;
      if(handle_irq) begin
        pc_set_o         = 1'b1;
        csr_save_o       = 1'b1;
        csr_save_cause_o = 1'b1;
        if(irq_nm & !nmi_mode_q) begin
          exc_cause_o = irq_nm_ext_i ? ExcCauseIrqNm : '{irq_ext: 1'b0, irq_int: 1'b1, lower_cause: irq_nm_int_cause};
          if(irq_nm_int & !irq_nm_ext_i) begin
            csr_mtval_o = irq_nm_int_mtval;
          end
        nmi_mode_d = 1'b1;
      end else if(irqs_i.irq_fast != 15'b0) begin
          exc_cause_o = '{irq_ext: 1'b1, irq_int: 1'b0, lower_cause: {1'b1, mfip_id}};
          end else if (irqs_i.irq_external) begin
            exc_cause_o = ExcCauseIrqExternalM;
          end else if (irqs_i.irq_software) begin
            exc_cause_o = ExcCauseIrqSoftwareM;
          end else begin // irqs_i.irq_timer
            exc_cause_o = ExcCauseIrqTimerM;
          end
        end
      next_state = PROCESSING;
    end
    
    DEBUG: begin
      pc_mux_o         = PC_EXC     ;
      exc_pc_mux_o     = EXC_PC_DBD ;
      flush_o          = 1'b1       ;
      pc_set_o         = 1'b1       ;
      csr_save_cause_o = 1'b1       ;

      debug_mode_d          = 1'b1;
      debug_mode_entering_o = 1'b1;
      
      next_state = PROCESSING;
    end
    FLUSH: begin
      halt_if    = 1'b1       ;
      flush_o    = 1'b1       ;
      next_state = PROCESSING ;
      if(exc_req_q || store_err_q || load_err_q) begin
        pc_set_o         = 1'b1                                       ;
        pc_mux_o         = PC_EXC                                     ;
        exc_pc_mux_o     = debug_mode_q ? EXC_PC_DBG_EXC : EXC_PC_EXC ;

        unique case (1'b1)
          instr_fetch_err_prio: begin
            exc_cause_o = ExcCauseInstrAccessFault                        ;
            csr_mtval_o = instr_fetch_err_plus2_i ? (pc_i + 32'd2) : pc_i ;
          end
          illegal_insn_prio: begin
            exc_cause_o = ExcCauseIllegalInsn                                           ;
            csr_mtval_o = instr_is_compressed_i ? {16'b0, instr_compressed_i} : instr_i ;
          end
          ecall_insn_prio: begin
            exc_cause_o = (priv_mode_i == PRIV_LVL_M) ? ExcCauseEcallMMode :  ExcCauseEcallUMode;
          end
          ebrk_insn_prio: begin
            if (debug_mode_q | ebreak_into_debug) begin
              pc_set_o         = 1'b0  ;
              csr_save_o       = 1'b0  ;
              csr_save_cause_o = 1'b0  ;
              next_state       = DEBUG ;
              flush_o          = 1'b0  ;
            end else begin
              exc_cause_o      = ExcCauseBreakpoint;
            end
          end
          store_err_prio: begin
            exc_cause_o = ExcCauseStoreAccessFault ;
            csr_mtval_o = lsu_addr_last_i          ;
          end
          load_err_prio: begin
            exc_cause_o = ExcCauseLoadAccessFault ;
            csr_mtval_o = lsu_addr_last_i         ;
          end
          default: ;
        endcase
      end else begin
        if (mret_insn) begin
          pc_mux_o           = PC_ERET ;
          pc_set_o           = 1'b1    ;
          csr_restore_mret_o = 1'b1    ;
          if (nmi_mode_q) begin
            nmi_mode_d          = 1'b0; // exit NMI mode
          end
        end else if (dret_insn) begin
          pc_mux_o              = PC_DRET ;
          pc_set_o              = 1'b1    ;
          debug_mode_d          = 1'b0    ;
          csr_restore_dret_o    = 1'b1    ;
        end else if (wfi_insn) begin
          next_state           = WAIT_SLEEP;
        end
      end // exc_req_q
      if (enter_debug_mode_prio_q && !(ebrk_insn_prio && ebreak_into_debug)) begin
          next_state = DEBUG;
        end
      end // FLUSH

      default: begin
        instr_req_o = 1'b0 ;
        next_state  = RESET;
      end
  endcase
end

endmodule

