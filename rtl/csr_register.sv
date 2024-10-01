module cs_registers  (
  // Clock and Reset
  input  logic                 clk  ,
  input  logic                 rst_n,

  // Hart ID
  input  logic [31:0]          hart_id_i  ,
  input  logic [31:0]          csr_wdata_i,

  // Privilege mode
  output pkg::priv_lvl_e  priv_mode_id_o   ,
  output pkg::priv_lvl_e  priv_mode_lsu_o  ,
  output logic            csr_mstatus_tw_o ,

  // mtvec
  output logic [31:0]          csr_mtvec_o      , 
  input  logic                 csr_mtvec_init_i ,
  input  logic [31:0]          boot_addr_i      , 

  // Interface to registers (SRAM like)
  input  logic                 csr_access_i ,
  input  pkg::csr_num_e        csr_addr_i   ,
  input  logic [31:0]          csr_wd1ata_i ,
  input  pkg::csr_op_e         csr_op_i     , 
  input                        csr_op_en_i  ,
  output logic [31:0]          csr_rdata_o  , 

  // interrupts
  input  logic                 irq_software_i    ,
  input  logic                 irq_timer_i       ,
  input  logic                 irq_external_i    ,
  input  logic [14:0]          irq_fast_i        ,
  input  logic                 nmi_mode_i        ,
  output logic                 irq_pending_o     ,
  output pkg::irqs_t           irqs_o            ,
  output logic                 csr_mstatus_mie_o ,
  output logic [31:0]          csr_mepc_o        ,
  output logic [31:0]          csr_mtval_o       ,

  // PMP
  output pkg::pmp_cfg_t     csr_pmp_cfg_o  [4],
  output logic [33:0]       csr_pmp_addr_o [4],
  output pkg::pmp_mseccfg_t csr_pmp_mseccfg_o ,

  // debug
  input  logic                 debug_mode_i          ,
  input  logic                 debug_mode_entering_i ,
  input  pkg::dbg_cause_e      debug_cause_i         , // EABRK , TRIGGER , HALT , STEP , NONE
  input  logic                 debug_csr_save_i      ,
  output logic [31:0]          csr_depc_o            ,
  output logic                 debug_single_step_o   ,
  output logic                 debug_ebreakm_o       ,
  output logic                 debug_ebreaku_o       ,
  output logic                 trigger_match_o       ,

 // program counter
  input  logic [31:0]          pc_i,
  // NOT USE
  output logic                 data_ind_timing_o     ,
  output logic                 dummy_instr_en_o      ,
  output logic [2:0]           dummy_instr_mask_o    ,
  output logic                 dummy_instr_seed_en_o ,
  output logic [31:0]          dummy_instr_seed_o    ,
  output logic                 icache_enable_o       ,
  output logic                 csr_shadow_err_o      ,
  input  logic                 ic_scr_key_valid_i    ,

  input  logic                 csr_save_i         ,
  input  logic                 csr_restore_mret_i ,
  input  logic                 csr_restore_dret_i ,
  input  logic                 csr_save_cause_i   ,
  input  pkg::exc_cause_t      csr_mcause_i       ,
  input  logic [31:0]          csr_mtval_i        ,
  output logic                 illegal_csr_insn_o , 
                                                    
  output logic                 double_fault_seen_o,

  input  logic                 instr_ret_i                                             ,
  input  logic                 instr_ret_compressed_i                                  ,
  input  logic                 instr_ret_spec_i                                        ,
  input  logic                 instr_ret_compressed_spec_i                             ,
  input  logic                 iside_wait_i                                            ,
  input  logic                 jump_i                                                  ,
  input  logic                 branch_i                                                ,
  input  logic                 branch_taken_i                                          , 
  input  logic                 mem_load_i                                              , 
  input  logic                 mem_store_i                                             , 
  input  logic                 dside_wait_i                                            , 
  input  logic                 mul_wait_i                                              , 
  input  logic                 div_wait_i                   
);

  import pkg::*;
  pkg::irqs_t mie_d;
  pkg::irqs_t mie_q;

  typedef struct packed {
      pkg::x_debug_ver_e xdebugver ;
      logic [11:0]       zero2     ;
      logic              ebreakm   ;
      logic              zero1     ;
      logic              ebreaks   ;
      logic              ebreaku   ;
      logic              stepie    ;
      logic              stopcount ;
      logic              stoptime  ;
      pkg::dbg_cause_e   cause     ;
      logic              zero0     ;
      logic              mprven    ;
      logic              nmip      ;
      logic              step      ;
      pkg::priv_lvl_e    prv       ;
  } dcsr_t;

  localparam logic [31:0] MISA_VALUE =
      (0                 <<  0) 
    | (0                 <<  1) 
    | (1                 <<  2) 
    | (0                 <<  3) 
    | (32'(0)            <<  4) 
    | (0                 <<  5) 
    | (32'(!0)           <<  8) 
    | (0                 << 12) 
    | (0                 << 13) 
    | (0                 << 18) 
    | (1                 << 20) 
    | (0                 << 23) 
    | (32'(CSR_MISA_MXL) << 30);


  typedef struct packed {
    logic           mpie;
    pkg::priv_lvl_e mpp ;
  } status_stk_t;

  typedef struct packed {
    logic           mie  ;
    logic           mpie ;
    pkg::priv_lvl_e mpp  ;
    logic           mprv ;
    logic           tw   ;
  } status_t;


  pkg::priv_lvl_e   priv_lvl_q, priv_lvl_d         ;
  status_t          mstatus_q, mstatus_d           ;
  pkg::exc_cause_t  mcause_q, mcause_d             ;
  pkg::irqs_t       mip                            ;
  dcsr_t            dcsr_q, dcsr_d                 ;
  status_stk_t      mstack_q, mstack_d             ;
  pkg::exc_cause_t  mstack_cause_q, mstack_cause_d ;

  logic        mcountinhibit_we           ;
  logic [31:0] mcountinhibit              ;
  logic        mstatus_err                ;
  logic        mstatus_en                 ;
  logic        mie_en                     ;
  logic [31:0] mscratch_q                 ;
  logic        mscratch_en                ;
  logic [31:0] mepc_q, mepc_d             ;
  logic        mepc_en                    ;
  logic        mcause_en                  ;
  logic [31:0] mtval_q, mtval_d           ;
  logic        mtval_en                   ;
  logic [31:0] mtvec_q, mtvec_d           ;
  logic        mtvec_err                  ;
  logic        mtvec_en                   ;
  logic        dcsr_en                    ;
  logic [31:0] depc_q, depc_d             ;
  logic        depc_en                    ;
  logic [31:0] dscratch0_q                ;
  logic [31:0] dscratch1_q                ;
  logic        dscratch0_en, dscratch1_en ;
  logic [31:0] exception_pc               ;
  logic        dbg_csr                    ;
  logic        illegal_csr                ;
  logic        illegal_csr_priv           ;
  logic        illegal_csr_dbg            ;
  logic        illegal_csr_write          ;
 
  // CSR update logic
  logic [31:0] csr_wdata_int ;
  logic [31:0] csr_rdata_int ;
  logic        csr_we_int    ;
  logic        csr_wr        ;
 

  logic        mstack_en                  ;
  logic [31:0] mstack_epc_q, mstack_epc_d ;
 
 
   // CSRs for recoverable NMIs
   // NOTE: these CSRS are nonstandard, see https://github.com/riscv/riscv-isa-manual/issues/261
 
 //  read logic
  always_comb begin
     csr_rdata_int = 32'd0;
     illegal_csr   = 1'b0 ;
     dbg_csr       = 1'b0 ;
 
     unique case (csr_addr_i)
       CSR_MVENDORID : csr_rdata_int = CSR_MVENDORID_VALUE ;
       CSR_MARCHID   : csr_rdata_int = CSR_MARCHID_VALUE   ;
       CSR_MIMPID    : csr_rdata_int = CSR_MIMPID_VALUE    ;
       CSR_MHARTID   : csr_rdata_int = hart_id_i           ;
       CSR_MSTATUS   : begin
         csr_rdata_int                                                   = 32'd0          ;
         csr_rdata_int[CSR_MSTATUS_MIE_BIT]                              = mstatus_q.mie  ;
         csr_rdata_int[CSR_MSTATUS_MPIE_BIT]                             = mstatus_q.mpie ;
         csr_rdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] = mstatus_q.mpp  ;
         csr_rdata_int[CSR_MSTATUS_MPRV_BIT]                             = mstatus_q.mprv ;
       end
       CSR_MISA: csr_rdata_int = MISA_VALUE;
       CSR_MIE : begin
         csr_rdata_int                                     = 32'd0              ;
         csr_rdata_int[CSR_MSIX_BIT]                       = mie_q.irq_software ;
         csr_rdata_int[CSR_MTIX_BIT]                       = mie_q.irq_timer    ;
         csr_rdata_int[CSR_MEIX_BIT]                       = mie_q.irq_external ;
       end
 
       CSR_MSCRATCH : csr_rdata_int = mscratch_q ;
       CSR_MTVEC    : csr_rdata_int = mtvec_q    ;
       CSR_MEPC     : csr_rdata_int = mepc_q     ;
       CSR_MCAUSE   : csr_rdata_int = {mcause_q.irq_ext | mcause_q.irq_int,
                                    mcause_q.irq_int ? {26{1'b1}} : 26'b0,
                                    mcause_q.lower_cause[4:0]};
       CSR_MTVAL    : csr_rdata_int = mtval_q;
       CSR_MIP      : begin
         csr_rdata_int     = 32'd0            ;
         csr_rdata_int[3]  = mip.irq_software ;
         csr_rdata_int[7]  = mip.irq_timer    ;
         csr_rdata_int[11] = mip.irq_external ;
       end
       CSR_DCSR: begin
         csr_rdata_int = dcsr_q;
         dbg_csr       = 1'b1  ;
       end
       CSR_DPC: begin
         csr_rdata_int = depc_q;
         dbg_csr       = 1'b1  ;
       end
       CSR_DSCRATCH0: begin
         csr_rdata_int = dscratch0_q;
         dbg_csr       = 1'b1       ;
       end
       CSR_DSCRATCH1: begin
         csr_rdata_int = dscratch1_q;
         dbg_csr       = 1'b1       ;
       end
       default: begin
         illegal_csr   = 1'b1;
       end
     endcase
 
  end

// write logic
  always_comb begin
    exception_pc = pc_i       ;
    priv_lvl_d   = priv_lvl_q ;
    mstatus_en   = 1'b0       ;
    mstatus_d    = mstatus_q  ;
    mie_en       = 1'b0       ;
    mscratch_en  = 1'b0       ;
    mepc_en      = 1'b0       ;
    mcause_en    = 1'b0       ;
    mtval_en     = 1'b0       ;
    mtvec_en     = 1'b0       ;
    dcsr_en      = 1'b0       ;
    depc_en      = 1'b0       ;
    dscratch0_en = 1'b0       ;
    dscratch1_en = 1'b0       ;
  
    if(csr_we_int) begin
      unique case (csr_addr_i)
        // mstatus: IE bit
        CSR_MSTATUS: begin
          mstatus_en = 1'b1;
          mstatus_d    = '{
          mie  : csr_wdata_int             [ CSR_MSTATUS_MIE_BIT                                ]   ,
          mpie : csr_wdata_int             [ CSR_MSTATUS_MPIE_BIT                               ]   ,
          mpp  : priv_lvl_e'(csr_wdata_int [ CSR_MSTATUS_MPP_BIT_HIGH : CSR_MSTATUS_MPP_BIT_LOW ] ) ,
          mprv : csr_wdata_int             [ CSR_MSTATUS_MPRV_BIT                               ]   ,
          tw   : csr_wdata_int             [ CSR_MSTATUS_TW_BIT                                 ]
          };
          if((mstatus_d.mpp != PRIV_LVL_M) && (mstatus_d.mpp != PRIV_LVL_U)) begin
            mstatus_d.mpp = PRIV_LVL_U;
          end
        end
        CSR_MIE    : mie_en    = 1'b1;
        CSR_MEPC   : mepc_en   = 1'b1;
        CSR_MCAUSE : mcause_en = 1'b1;
        CSR_MTVAL  : mtval_en  = 1'b1;
        CSR_MTVEC  : mtvec_en  = 1'b1;
        CSR_DCSR   : begin
          dcsr_d  = csr_wdata_int ;
          dcsr_en = 1'b1          ;
        end
        CSR_DPC           : depc_en          = 1'b1;
        CSR_DSCRATCH0     : dscratch0_en     = 1'b1;
        CSR_DSCRATCH1     : dscratch1_en     = 1'b1;
        CSR_MCOUNTINHIBIT : mcountinhibit_we = 1'b1;
        default:; // Do nothing for other CSR addresses
      endcase
    end
  
    unique case (1'b1) 
      csr_save_cause_i: begin
      if(csr_save_i) begin
        exception_pc = pc_i;
      end
      priv_lvl_d = pkg::PRIV_LVL_M;
    
    if(debug_csr_save_i) begin
      dcsr_d.prv   = priv_lvl_q        ;
      dcsr_d.cause = debug_cause_i     ;
      depc_d       = exception_pc      ;
      depc_en      = 1'b1              ;
    end else if(!debug_mode_i) begin
      mtval_en       = 1'b1        ;
      mtval_d        = csr_mtval_i ;
      mstatus_en     = 1'b1        ;
      mstatus_d.mie  = 1'b0        ; // disable interrupts
    
      mstatus_d.mpie = mstatus_q.mie ;
      mstatus_d.mpp  = priv_lvl_q    ;
      mepc_en        = 1'b1          ;
      mepc_d         = exception_pc  ;
      mcause_en      = 1'b1          ;
      mcause_d       = csr_mcause_i  ;

      mstack_en      = 1'b1          ;
      
      end
    end // csr_save_cause_i
    
    csr_restore_dret_i: begin
     // priv_lvl_d = dcsr_q.qrv;
    end
    csr_restore_mret_i: begin
      priv_lvl_d    = mstatus_q.mpp ;
      mstatus_en    = 1'b1          ;
      mstatus_d.mie = mstatus_q.mpie;
      if(mstatus_q.mpp != pkg::PRIV_LVL_M) begin
        mstatus_d.mprv = 1'b0;
      end


     if(nmi_mode_i) begin
       mstatus_d.mpie = mstack_q.mpie  ;
       mstatus_d.mpp  = mstack_q.mpp   ;
       mepc_en        = 1'b1           ;
       mepc_d         = mstack_epc_q   ;
       mcause_en      = 1'b1           ;
       mcause_d       = mstack_cause_q ;
     end else begin
       mstatus_d.mpie = 1'b1            ;
       mstatus_d.mpp  = pkg::PRIV_LVL_U ;
     end
     end
        default:;
      endcase
    end
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      priv_lvl_q     <= pkg::PRIV_LVL_M;
    end else begin
      priv_lvl_q     <= priv_lvl_d;
    end
  end

  // CSR operation logic
  always_comb begin
    unique case (csr_op_i)
      pkg::CSR_OP_WRITE: csr_wdata_int   = csr_wdata_i                ;
      pkg::CSR_OP_SET  :   csr_wdata_int = csr_wdata_i | csr_rdata_o  ;
      pkg::CSR_OP_CLEAR: csr_wdata_int   = ~csr_wdata_i & csr_rdata_o ;
      pkg::CSR_OP_READ :  csr_wdata_int  = csr_wdata_i                ;
      default:      csr_wdata_int = csr_wdata_i;
    endcase
  end

  assign csr_wr = (csr_op_i inside {pkg::CSR_OP_WRITE, pkg::CSR_OP_SET, pkg::CSR_OP_CLEAR});
  assign csr_we_int  = csr_wr & csr_op_en_i & ~illegal_csr_insn_o;
  assign csr_rdata_o = csr_rdata_int;

 // directly output some registers
  assign csr_mepc_o  = mepc_q ;
  assign csr_depc_o  = depc_q ;
  assign csr_mtvec_o = mtvec_q;
  assign csr_mtval_o = mtval_q;

  assign csr_mstatus_mie_o   = mstatus_q.mie  ;
  assign csr_mstatus_tw_o    = mstatus_q.tw   ;
  assign debug_single_step_o = dcsr_q.step    ;
  assign debug_ebreakm_o     = dcsr_q.ebreakm ;
  assign debug_ebreaku_o     = dcsr_q.ebreaku ;

  // Qualify incoming interrupt requests in mip CSR with mie CSR for controller and to re-enable
  // clock upon WFI (must be purely combinational).
  assign irqs_o        = mip & mie_q;
  assign irq_pending_o = |irqs_o    ;

  assign mip.irq_software = irq_software_i ;
  assign mip.irq_timer    = irq_timer_i    ;
  assign mip.irq_external = irq_external_i ;
  assign mip.irq_fast     = irq_fast_i     ;

  ///////////////// CSR Inatatiation /////////////////////////

 // MSTATUS
  localparam status_t MSTATUS_RST_VAL = '{
  mie  : 1'b0       ,
  mpie : 1'b1       ,
  mpp  : pkg::PRIV_LVL_U ,
  mprv : 1'b0       ,
  tw   : 1'b0       };

  csr #(
    .Width     ($bits(status_t    )   ) ,
    .ShadowCopy(0         ) ,
    .ResetValue({MSTATUS_RST_VAL} )
  ) u_mstatus_csr (
    .clk        ( clk         ) ,
    .rst_n      ( rst_n       ) ,
    .wr_data_i  ( {mstatus_d} ) ,
    .wr_en_i    ( mstatus_en  ) ,
    .rd_data_o  ( mstatus_q   ) ,
    .rd_error_o ( mstatus_err )
  );

  // MEPC
  csr #(
    .Width     (32      ) ,
    .ShadowCopy(1'b0    ) ,
    .ResetValue('0      )
    ) u_mepc_csr (
    .clk       (clk     ) ,
    .rst_n     (rst_n   ) ,
    .wr_data_i (mepc_d  ) ,
    .wr_en_i   (mepc_en ) ,
    .rd_data_o (mepc_q  ) ,
    .rd_error_o()
  );

  // MIE
  assign mie_d.irq_software = csr_wdata_int[pkg::CSR_MSIX_BIT];
  assign mie_d.irq_timer    = csr_wdata_int[pkg::CSR_MTIX_BIT];
  assign mie_d.irq_external = csr_wdata_int[pkg::CSR_MEIX_BIT];
  assign mie_d.irq_fast     = csr_wdata_int[pkg::CSR_MFIX_BIT_HIGH:pkg::CSR_MFIX_BIT_LOW];

  csr #(
    .Width     ($bits(pkg::irqs_t )   ) ,
    .ShadowCopy(1'b0         ) ,
    .ResetValue('0           )
  ) u_mie_csr (
    .clk       (clk     ) ,
    .rst_n     (rst_n   ) ,
    .wr_data_i ({mie_d} ) ,
    .wr_en_i   (mie_en  ) ,
    .rd_data_o (mie_q   ) ,
    .rd_error_o()
  );
  // MSCRATCH
  csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mscratch_csr (
    .clk       (clk           ) ,
    .rst_n     (rst_n         ) ,
    .wr_data_i (csr_wdata_int ) ,
    .wr_en_i   (mscratch_en   ) ,
    .rd_data_o (mscratch_q    ) ,
    .rd_error_o()
  );
  // MCAUSE
  csr #(
    .Width     ($bits(pkg::exc_cause_t)),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mcause_csr (
    .clk       (clk        ) ,
    .rst_n     (rst_n      ) ,
    .wr_data_i ({mcause_d} ) ,
    .wr_en_i   (mcause_en  ) ,
    .rd_data_o (mcause_q   ) ,
    .rd_error_o()
  );
  // MTVAL thanh ghi ngoai le
  csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mtval_csr (
    .clk       (clk      ) ,
    .rst_n     (rst_n    ) ,
    .wr_data_i (mtval_d  ) ,
    .wr_en_i   (mtval_en ) ,
    .rd_data_o (mtval_q  ) ,
    .rd_error_o()
  );
  // MTVEC chua dia chi co so
  csr #(
    .Width     (32),
    .ShadowCopy(0),
    .ResetValue(32'd1)
  ) u_mtvec_csr (
    .clk       (clk       ) ,
    .rst_n     (rst_n     ) ,
    .wr_data_i (mtvec_d   ) ,
    .wr_en_i   (mtvec_en  ) ,
    .rd_data_o (mtvec_q   ) ,
    .rd_error_o(mtvec_err )
  );
  // DCSR
  localparam dcsr_t DCSR_RESET_VAL = '{
      xdebugver : pkg::XDEBUGVER_STD  ,
      cause     : pkg::DBG_CAUSE_NONE , // 3'h0
      prv       : pkg::PRIV_LVL_M     ,
      default: '0
  };
  csr #(
    .Width     ($bits(dcsr_t)),
    .ShadowCopy(1'b0),
    .ResetValue({DCSR_RESET_VAL})
  ) u_dcsr_csr (
    .clk       (clk      ) ,
    .rst_n     (rst_n    ) ,
    .wr_data_i ({dcsr_d} ) ,
    .wr_en_i   (dcsr_en  ) ,
    .rd_data_o (dcsr_q   ) ,
    .rd_error_o()
  );
 // DEPC
  csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_depc_csr (
    .clk       (clk     ) ,
    .rst_n     (rst_n   ) ,
    .wr_data_i (depc_d  ) ,
    .wr_en_i   (depc_en ) ,
    .rd_data_o (depc_q  ) ,
    .rd_error_o()
  );
  // DSCRATCH0
  csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_dscratch0_csr (
    .clk       (clk           ) ,
    .rst_n     (rst_n         ) ,
    .wr_data_i (csr_wdata_int ) ,
    .wr_en_i   (dscratch0_en  ) ,
    .rd_data_o (dscratch0_q   ) ,
    .rd_error_o()
  );

  // DSCRATCH1
  csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_dscratch1_csr (
    .clk       (clk           ) ,
    .rst_n     (rst_n         ) ,
    .wr_data_i (csr_wdata_int ) ,
    .wr_en_i   (dscratch1_en  ) ,
    .rd_data_o (dscratch1_q   ) ,
    .rd_error_o()
  );
endmodule
