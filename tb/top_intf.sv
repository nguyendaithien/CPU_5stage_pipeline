interface top_intf(input clk, rst_n);
  logic [31:0] boot_add                ;
  logic [31:0] Instr_in                ;
  logic [31:0] D_in                    ;
  logic        irq_software_i          ;
  logic        irq_timer_i             ;
  logic        irq_external_i          ;
  logic [14:0] irq_fast_i              ;
  logic        debug_req_i             ;
  logic        irq_nm_i                ;
  logic        data_gnt_i              ;
  logic        data_rvalid_i           ;
  logic        data_rdata_i            ;
  logic        data_err_i              ;
  logic        instr_gnt_i             ;
  logic        instr_rvalid_i          ;
  logic        instr_rdata_i           ;
  logic        instr_err_i             ;
  logic        instr_fetch_err_plus2_i ;
  logic        mem_resp_intg_err_i     ;
  logic [31:0] A_DMEM                  ;
  logic        instr_req               ;
  logic        data_req_o              ;
  logic [31:0] A_IMEM                  ;
  logic [31:0] D_out                   ;
  logic        RD                      ;
  logic        WR                      ;
  logic        irq_pending_o           ;
  logic        crash_dump_o            ;
  logic [3:0 ] byte_mark               ;
  logic        DMEM_rst                ;
  logic        core_busy_o             ;

endinterface
