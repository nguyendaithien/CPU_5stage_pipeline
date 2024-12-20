module test_case(
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

logic  [31:0] IMEM_data    ; assign IMEM_data_i    = top.if_stage.IMEM_data_i ;
logic  [4:0]  ID_rs1_addr  ; assign ID_rs1_addr    = top.id_stage.rs1_add     ;
logic  [4:0]  ID_rs2_addr  ; assign ID_rs2_addr    = top.id_stage.rs1_add     ;
logic  [4:0]  ID_rsd_addr  ; assign ID_rs3_addr    = top.id_stage.rs1_add     ;
logic  [31:0]  ID_rs1_data ; assign ID_rs1_data    = top.ID_rs1_data          ;
logic  [31:0]  ID_rs2_data ; assign ID_rs2_data    = top.ID_rs1_data          ;
logic  MEM_RD;assign MEM_RD = top.EX_RD;  
logic  MEM_WR;assign MEM_WR = top.EX_WR;
logic  WB_regwrire          ; assign WB_regwrite    = top.MEM_regwrite            ;
logic [31:0] data_write_reg ; assign data_write_reg = top.id_stage.data_write_reg ;
logic [31:0] op_a_alu       ; assign op_a_alu       = top.ex_stage.op_a_alu       ;
logic [31:0] op_b_alu       ; assign op_b_alu       = top.ex_stage.op_b_alu       ;
logic [31:0] alu_result     ; assign alu_result     = top.ex_stage.alu_result     ;
 

  logic [15:0] IF_instr_compressed;assign  IF_instr_compressed      = top.IF_instr_compressed         ; 
  logic ID_illegal_insn           ;assign  ID_illegal_insn          = top.ID_illegal_insn             ; 
  logic ID_ecall_insn             ;assign  ID_ecall_insn            = top.ID_ecall_insn               ; 
  logic ID_mret_insn              ;assign  ID_mret_insn             = top.ID_mret_insn                ; 
  logic ID_dret_insn              ;assign  ID_dret_insn             = top.ID_dret_insn                ; 
  logic ID_wfi_insn               ;assign  ID_wfi_insn              = top.ID_wfi_insn                 ; 
  logic ID_ebrk_insn              ;assign  ID_ebrk_insn             = top.ID_ebrk_insn                ; 
  logic ID_csr_pipe_flush         ;assign  ID_csr_pipe_flush        = top.ID_csr_pipe_flush           ; 
  logic ID_instr_valid            ;assign  ID_instr_valid           = top.ID_instr_valid              ;   
  logic [31:0] ID_instr           ;assign  ID_instr                 = top.ID_instr                    ; 
  logic ID_instr_compressed       ;assign  ID_instr_compressed      = top.ID_instr_compressed         ;   
  logic ID_instr_is_compressed    ;assign  ID_instr_is_compressed   = top.ID_instr_is_compressed      ;   
  logic ID_instr_bp_taken         ;assign  ID_instr_bp_taken        = top.ID_instr_bp_taken           ;   


  logic [4:0 ] IMEM_add           ; assign IMEM_add              =   top.IMEM_add                     ;                          
  logic [31:0] IF_pc              ; assign IF_pc                 =   top.IF_pc                        ;                          
  logic [4:0 ] ID_rs1_add         ; assign ID_rs1_add            =   top.ID_rs1_add                   ;                          
  logic [4:0 ] ID_rs2_add         ; assign ID_rs2_add            =   top.ID_rs2_add                   ;                          
  logic [4:0 ] ID_rd_add          ; assign ID_rd_add             =   top.ID_rd_add                    ;                          
  logic [31:0] ID_pc              ; assign ID_pc                 =   top.ID_pc                        ;                          
  logic [3:0 ] ID_alu_op          ; assign ID_alu_op             =   top.ID_alu_op                    ;                          
  logic [31:0] ID_imm             ; assign ID_imm                =   top.ID_imm                       ;                          
  logic [1:0 ] ID_sel_to_reg      ; assign ID_sel_to_reg         =   top.ID_sel_to_reg                ;                          
  logic        ID_regwrite        ; assign ID_regwrite           =   top.ID_regwrite                  ;                          
  logic [3:0 ] ID_mem_op          ; assign ID_mem_op             =   top.ID_mem_op                    ;                          
  logic        ID_jump            ; assign ID_jump               =   top.ID_jump                      ;                          
  logic ID_RD                     ; assign  ID_RD                =   top.ID_RD                        ;                          
  logic ID_WR                     ; assign  ID_WR                =   top.ID_WR                        ;                          
  logic        ID_branch          ; assign ID_branch             =   top.ID_branch                    ;                          
  logic [1:0 ] ID_alu_sel1        ; assign ID_alu_sel1           =   top.ID_alu_sel1                  ;                          
  logic [1:0 ] ID_alu_sel2        ; assign ID_alu_sel2           =   top.ID_alu_sel2                  ;                          
  logic        ID_pc_sel          ; assign ID_pc_sel             =   top.ID_pc_sel                    ;                          
  logic [31:0] EX_pc              ; assign EX_pc                 =   top.EX_pc                        ;                          
  logic [4:0 ] EX_rs1_add         ; assign EX_rs1_add            =   top.EX_rs1_add                   ;                          

  logic [4:0 ] EX_rs2_add         ; assign EX_rs2_add            =   top.EX_rs2_add                   ;                          
  logic [4:0 ] EX_rd_add          ; assign EX_rd_add             =   top.EX_rd_add                    ;                          
  logic [1:0 ] EX_sel_to_reg      ; assign EX_sel_to_reg         =   top.EX_sel_to_reg                ;                          
  logic        EX_regwrite        ; assign EX_regwrite           =   top.EX_regwrite                  ;                          
  logic        EX_RD              ; assign EX_RD                 =   top.EX_RD                        ;                          
  logic        EX_WR              ; assign EX_WR                 =   top.EX_WR                        ;                          
  logic [3:0 ] EX_mem_op          ; assign EX_mem_op             =   top.EX_mem_op                    ;                          
  logic [31:0] EX_alu_result      ; assign EX_alu_result         =   top.EX_alu_result                ;                          
  logic        EX_zero_o          ; assign EX_zero_o               =   top.EX_zero                      ;                          
  logic [31:0] EX_imm             ; assign EX_imm                =   top.EX_imm                       ;                          
  logic [31:0] EX_pc_dest         ; assign EX_pc_dest            =   top.EX_pc_dest                   ;                          
  logic [31:0] EX_rs2_data        ; assign EX_rs2_data           =   top.EX_rs2_data                  ;                          
  logic        EX_branch          ; assign EX_branch             =   top.EX_branch                    ;                          
  logic        EX_jump            ; assign EX_jump               =   top.EX_jump                      ;                          
  logic [31:0] MEM_add            ; assign MEM_add               =   top.MEM_add                      ;                          
  logic [3:0 ] DMEM_byte_mark     ; assign DMEM_byte_mark        =   top.DMEM_byte_mark               ;                          
  logic [31:0] DMEM_data_write    ; assign DMEM_data_write       =   top.DMEM_data_write              ;                          
  logic [31:0] MEM_data           ; assign MEM_data              =   top.MEM_data                     ;                          
  logic [31:0] DMEM_data_o        ; assign DMEM_data_o           =   top.DMEM_data_o                  ;                          
  logic        MEM_regwrite       ; assign MEM_regwrite          =   top.MEM_regwrite                 ;                          
  logic [31:0] MEM_alu_result     ; assign MEM_alu_result        =   top.MEM_alu_result               ;                          
  logic [4:0 ] MEM_rd_add         ; assign MEM_rd_add            =   top.MEM_rd_add                   ;                          
  logic [1:0 ] MEM_sel_to_reg     ; assign MEM_sel_to_reg        =   top.MEM_sel_to_reg               ;                          
  logic        MEM_RD_mem         ; assign MEM_RD_mem            =   top.MEM_RD_mem                   ;                          
  logic        MEM_WR_mem         ; assign MEM_WR_mem            =   top.MEM_WR_mem                   ;                          
  logic [31:0] MEM_pc             ; assign MEM_pc                =   top.MEM_pc                       ;                          
  logic [1:0 ] forward_A          ; assign forward_A             =   top.forward_A                    ;                          
  logic [1:0 ] forward_B          ; assign forward_B             =   top.forward_B                    ;                          
  logic [31:0] MEM_imm            ; assign MEM_imm               =   top.MEM_imm                      ;                          
  logic        forward_dmem       ; assign forward_dmem          =   top.forward_dmem                 ;                          
  logic [31:0] WB_data_write      ; assign WB_data_write         =   top.WB_data_write_reg            ;

  logic [31:0] data_write_mem;  assign data_write_mem = top.mem_stage.data_write;
  logic [31:0] mem_rs1_data;    assign mem_rs1_data = top.mem_stage.MEM_rs2_data_i;

// hazard control
  logic stall       ; assign stall       = top.stall         ;
  logic IF_ID_flush ; assign IF_ID_flush = top.IF_ID_flush   ;
  logic EX_flush    ; assign EX_flush    = top.EX_flush      ;
  logic EX_zero     ; assign EX_zero     = top.ex_stage.zero ;
  logic hazard      ; assign hazard      = top.hazard        ;
  logic no_hazard ; assign no_hazard = (~hazard) & (~EX_flush) & (~IF_ID_flush) & (~stall);

// decode instr
 logic [31:0] IF_instr ; assign IF_instr = top.if_stage.IF_instr_i ;
 logic [2:0]  funct_3  ; assign funct_3  = IF_instr[14:12]         ;
 logic [6:0]  opcode   ; assign opcode   = IF_instr[6:0]           ;

 logic is_add_instr  ; assign is_add_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_ADD_SUB) & (IF_instr[30] == 1'b0) ;
 logic is_sub_instr  ; assign is_sub_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_ADD_SUB) & (IF_instr[30] == 1'b1) ;
 logic is_sll_instr  ; assign is_sll_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SLL)                              ;
 logic is_slt_instr  ; assign is_slt_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SLT)                              ;
 logic is_sltu_instr ; assign is_sltu_instr = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SLTU)                             ;
 logic is_xor_instr  ; assign is_xor_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_XOR)                              ;
 logic is_srl_instr  ; assign is_srl_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SRL_SRA) & (IF_instr[30]     == 1'b0) ;
 logic is_sra_instr  ; assign is_sra_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SRL_SRA) & (IF_instr[30]     == 1'b1) ;
 logic is_or_instr   ; assign is_or_instr   = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_OR)                                           ;
 logic is_and_instr  ; assign is_and_instr  = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_AND)                                          ;

 logic is_addi_instr  ; assign is_addi_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_ADDI)                                   ;
 logic is_slli_instr  ; assign is_slli_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SLLI )                                  ;
 logic is_slti_instr  ; assign is_slti_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SLTI )                                  ;
 logic is_sltiu_instr ; assign is_sltiu_instr = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SLTIU)                                  ;
 logic is_xori_instr  ; assign is_xori_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_XORI)                                   ;
 logic is_srli_instr  ; assign is_srli_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SRAI_SRLI) & (IF_instr[30]     == 1'b0) ;
 logic is_srai_instr  ; assign is_srai_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SRAI_SRLI) & (IF_instr[30]     == 1'b1) ;
 logic is_ori_instr   ; assign is_ori_instr   = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_ORI)                                    ;
 logic is_andi_instr  ; assign is_andi_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_ANDI)                                   ;

 logic is_lui_instr   ; assign is_lui_instr   = (opcode == OPCODE_LUI)? 1'd1 : 1'd0 ;
 logic is_auipc_instr ; assign is_auipc_instr = (opcode == OPCODE_AUIPC)            ;
 logic is_jalr_instr  ; assign is_jalr_instr  = (opcode == OPCODE_JALR)             ;
 logic is_jal_instr   ; assign is_jal_instr   = (opcode == OPCODE_JAL)              ;

 logic is_beg_instr    ; assign  is_beg_instr   = (opcode == OPCODE_BRANCH) & (funct_3 == `FUNCT3_BGE ) ;
 logic is_bne_instr    ; assign  is_bne_instr   = (opcode == OPCODE_BRANCH) & (funct_3 == `FUNCT3_BNE ) ;
 logic is_blt_instr    ; assign  is_blt_instr   = (opcode == OPCODE_BRANCH) & (funct_3 == `FUNCT3_BLT ) ;
 logic is_bge_instr    ; assign  is_bge_instr   = (opcode == OPCODE_BRANCH) & (funct_3 == `FUNCT3_BGE ) ;
 logic is_bltu_instr   ; assign  is_bltu_instr  = (opcode == OPCODE_BRANCH) & (funct_3 == `FUNCT3_BLTU) ;
 logic is_bgeu_instr   ; assign  is_bgeu_instr  = (opcode == OPCODE_BRANCH) & (funct_3 == `FUNCT3_BGEU) ;

 logic is_lw_instr  ; assign is_lw_instr  = (opcode == OPCODE_LOAD) & (funct_3 == `MEM_LW)   ;
 logic is_lb_instr  ; assign is_lb_instr  = (opcode == OPCODE_LOAD) & (funct_3 == `MEM_LB)   ;
 logic is_lh_instr  ; assign is_lh_instr  = (opcode == OPCODE_LOAD) & (funct_3 == `MEM_LH)   ;
 logic is_lbu_instr ; assign is_lbu_instr = (opcode == OPCODE_LOAD) & (funct_3 == `MEM_LB_U) ;
 logic is_lhu_instr ; assign is_lhu_instr = (opcode == OPCODE_LOAD) & (funct_3 == `MEM_LH_U) ;

 logic is_sb_instr ; assign is_sb_instr = (opcode == OPCODE_STORE) & (funct_3 == `MEM_SB)  ;
 logic is_sh_instr ; assign is_sh_instr = (opcode == OPCODE_STORE) & (funct_3 == `MEM_SH)  ;
 logic is_sw_instr ; assign is_sw_instr = (opcode == OPCODE_STORE) & (funct_3 == `MEM_SW)  ;

 logic is_ecall_instr  ; assign is_ecall_instr  = (opcode == OPCODE_SYSTEM) & (IF_instr[31:20] == 12'h000)  ;
 logic is_ebreak_instr ; assign is_ebreak_instr = (opcode == OPCODE_SYSTEM) & (IF_instr[31:20] == 12'h001)  ;
 logic is_mret_instr   ; assign is_mret_instr   = (opcode == OPCODE_SYSTEM) & (IF_instr[31:20] == 12'h302)  ;
 logic is_dret_instr   ; assign is_dret_instr   = (opcode == OPCODE_SYSTEM) & (IF_instr[31:20] == 12'h702)  ;
 logic is_wfi_instr    ; assign is_wfi_instr    = (opcode == OPCODE_SYSTEM) & (IF_instr[31:20] == 12'h105)  ;

 logic is_csr_read_instr     ; assign is_csr_read_instr  = (opcode == OPCODE_SYSTEM) & (IF_instr[13:12] == 2'b00)  ;
 logic is_csr_write_instr    ; assign is_csr_write_instr = (opcode == OPCODE_SYSTEM) & (IF_instr[13:12] == 2'b01)  ;
 logic is_csr_set_instr      ; assign is_csr_set_instr   = (opcode == OPCODE_SYSTEM) & (IF_instr[13:12] == 2'b10)  ;
 logic is_csr_clear_instr    ; assign is_csr_clear_instr = (opcode == OPCODE_SYSTEM) & (IF_instr[13:12] == 2'b11)  ;

 logic  [31:0]   imm_i ;   assign imm_i = top.ID_imm_i_type;  
 logic  [31:0]   imm_s ;   assign imm_s = top.ID_imm_s_type;
 logic  [31:0]   imm_b ;   assign imm_b = top.ID_imm_b_type;
 logic  [31:0]   imm_u ;   assign imm_u = top.ID_imm_u_type;
 logic  [31:0]   imm_j ;   assign imm_j = top.ID_imm_j_type;

 logic [31:0] WB_imm        ; assign WB_imm        = top.wb_stage.WB_imm            ;
 logic [31:0] WB_pc         ; assign WB_pc         = top.wb_stage.pc                ;
 logic [31:0] WB_alu_result ; assign WB_alu_result = top.wb_stage.WB_alu_result     ;
 logic [31:0] WB_dmem_data  ; assign WB_dmem_data  = top.wb_stage.DMEM_data_i       ;
 ctrl_fsm_e current_state   ; assign current_state = top.control_main.current_state ;

 logic [31:0] data_to_mem ; assign data_to_mem = top.D_out;

 always @(posedge top.MEM_WR_mem) begin
  $display ("add to mem %h"  , top.A_DMEM);
  $display ("data to mem %h" , data_to_mem);
end 


 property check_common(a,delay,b);
   @(posedge clk) disable iff(!rst_n)
    a |-> ##delay b; 
 endproperty

  property check_add_instr;
    @(posedge clk) 
    (is_add_instr & (current_state == PROCESSING)) |-> ##2 (no_hazard) & (alu_result == (op_a_alu + op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == ($past(alu_result,2))) ) ; 
  endproperty
  add_instr: assert property(check_add_instr)  begin
    $display ("[INSTR] check add pass");
  end
  else begin
    $display ("check add instr fail");
  end

  property check_sub_instr;
    @(posedge clk) 
    ((is_sub_instr) & (current_state == PROCESSING))|-> ##2 (no_hazard) &(alu_result == (op_a_alu - op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == $past(alu_result,2)) ) ; 
  endproperty
  sub_instr: assert property(check_sub_instr) begin 
    $display ("[INSTR] check sub pass");
  end
  else begin
    $display ("check sub instr fail");
  end
  always @(is_sub_instr) begin
    $display( "IS SUB INSTR");
  end
  always @(is_lbu_instr) begin
    $display( "IS LBU INSTR");
  end

  property check_sll_instr;
    @(posedge clk) 
    (is_sll_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu <<  op_b_alu[4:0])) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  sll_instr: assert property(check_sll_instr) begin
    $display ("[INSTR] check add pass");
  end
  else begin
    $display ("check sll instr fail");
  end

  property check_slt_instr;
    @(posedge clk) 
    (is_slt_instr) |-> ##2 (no_hazard) &(alu_result == ((op_a_alu < op_b_alu) ? 32'd1 : 32'd0 )) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  slt_instr: assert property(check_slt_instr) begin
    $display ("[INSTR] check slt pass");
  end
    else begin
    $display ("check slt instr fail");
  end

  property check_sltu_instr;
    @(posedge clk) 
    (is_sltu_instr & (current_state == PROCESSING) ) |=> (!IF_ID_flush) |=> (!EX_flush) & (no_hazard) &(alu_result == ((op_a_alu < op_b_alu) ? 32'd1 : 32'd0 )) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  sltu_instr: assert property(check_sltu_instr) begin
    $display ("[INSTR] check sltu pass");
  end
    else begin
    $display ("check sltu instr fail");
  end

  property check_xor_instr;
    @(posedge clk) 
    (is_xor_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu ^ op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  xor_instr: assert property(check_xor_instr) begin 
    $display ("[INSTR] check xor pass");
  end
  else begin
    $display ("check xor instr fail");
  end

  property check_srl_instr;
    @(posedge clk) 
    (is_srl_instr) |-> ##2 (no_hazard) &(alu_result == ((op_a_alu >> op_b_alu[4:0]))) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  srl_instr: assert property(check_srl_instr) begin 
    $display ("[INSTR] check srl pass");
  end
  else begin
    $display ("check srl instr fail");
  end

  property check_sra_instr;
    @(posedge clk) 
    (is_sra_instr) |=> (!IF_ID_flush)  |=> (!EX_flush) &  (alu_result == ($signed(op_a_alu) >>> op_b_alu[4:0])) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  sra_instr: assert property(check_sra_instr) begin
    $display ("[INSTR] check sra pass");
  end
    else begin
    $display ("check sra instr fail");
  end

  property check_or_instr;
    @(posedge clk) 
    (is_or_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu | op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  or_instr: assert property(check_or_instr)begin 
    $display ("[INSTR] check or pass");
  end
  else begin
    $display ("check or instr fail");
  end

  property check_and_instr;
    @(posedge clk) 
    (is_and_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu & op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  and_instr: assert property(check_and_instr) begin
    $display ("[INSTR] check and pass");
  end
    else begin
    $display ("check and instr fail");
  end
 /////// I TYPE INSTRUCTION
  property check_addi_instr;
    @(posedge clk) 
    (is_addi_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu + op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  addi_instr: assert property(check_addi_instr) else begin
    $display ("check addi instr fail");
  end

  property check_ori_instr;
    @(posedge clk) 
    (is_ori_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu | op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  ori_instr: assert property(check_ori_instr) else begin
    $display ("check ori instr fail");
  end

  property check_xori_instr;
    @(posedge clk) 
    (is_xori_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu ^ op_b_alu)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  xori_instr: assert property(check_xori_instr) else begin
    $display ("check xori instr fail");
  end

  property check_slti_instr;
    @(posedge clk) 
    (is_slti_instr) |-> ##2 (no_hazard) &(alu_result == ((op_a_alu < op_b_alu) ? 32'd1 : 32'd0)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  slti_instr: assert property(check_slti_instr) else begin
    $display ("check slti instr fail");
  end

  property check_sltiu_instr;
    @(posedge clk) 
    (is_sltiu_instr) |-> ##2 (no_hazard) &(alu_result == ((op_a_alu < op_b_alu)? 32'd1 : 32'd0)) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  sltiu_instr: assert property(check_sltiu_instr) else begin
    $display ("check sltiu instr fail");
  end

  property check_srai_instr;
    @(posedge clk) 
    (is_srai_instr & (current_state == PROCESSING)) |=> (!IF_ID_flush) |=> (!EX_flush) & (alu_result == ($signed(op_a_alu) >>> op_b_alu[4:0] )) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm ) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  srai_instr: assert property(check_srai_instr) else begin
    $display ("check srai instr fail");
  end
  always @(is_srai_instr) begin
    $display( "is srai instr" );
  end
  always @(is_srli_instr) begin
    $display( "is srli instr" );
  end
  always @(is_lbu_instr) begin
    $display( "is lbu instr" );
  end

  property check_srli_instr;
    @(posedge clk) 
    (is_srli_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu >> op_b_alu[4:0])) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  srli_instr: assert property(check_srli_instr) else begin
    $display ("check srli instr fail");
  end

  property check_slli_instr;
    @(posedge clk) 
    (is_slli_instr) |-> ##2 (no_hazard) &(alu_result == (op_a_alu << op_b_alu[4:0])) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == 32'($past(alu_result,2))) ) ; 
  endproperty
  slli_instr: assert property(check_slli_instr) else begin
    $display ("check slli instr fail");
  end
  // LUI, AUIPC
  property check_lui_instr;
    @(posedge clk)
    (is_lui_instr & (!IF_ID_flush) ) |=> (!IF_ID_flush)  |=>  ((ID_imm == imm_u)) |-> ##2 ( (WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (WB_data_write == WB_imm));       
  endproperty
  lui_instr : assert property (check_lui_instr) else begin
    $display ("check lui instr fail , regwrite = %b  and data_wrie (true or fail) ? %b and sel_to_reg WB %b and sel_to_reg MEM %b and sel_to_reg EX %b and sel_to_reg ID  %b and sel_to_reg decoder %b opcode %h ", WB_regwrite,   (WB_data_write == WB_imm), top.wb_stage.WB_sel_to_reg,$past(top.MEM_sel_to_reg),$past(top.EX_sel_to_reg,2), $past(top.ID_sel_to_reg,3), $past(top.id_stage.sel_to_reg,4),$past(top.id_stage.decode.opcode,4) );
  end

  property check_auipc_instr;
    @(posedge clk)
    (is_auipc_instr) |=> (!IF_ID_flush)  |=>  ((ID_imm == imm_u)) &  (no_hazard) & ((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_pc ) & (op_b_alu == ID_imm ) & (ID_imm == imm_u))  |-> ##2 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (WB_data_write == WB_alu_result));       
  endproperty
  auipc_instr : assert property (check_auipc_instr) else begin
    $display ("check auipc instr fail");
  end

  // LOAD , STORE INSTR
  property check_lw_instr;
    @(posedge clk) 
    (is_lw_instr) |-> ##2 (no_hazard) &((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b1)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (WB_data_write == WB_dmem_data )) ; 
  endproperty
  lw_instr: assert property(check_lw_instr) else begin
    $display ("check lw instr fail");
  end

  property check_lh_instr;
    @(posedge clk) 
    (is_lh_instr) |-> ##2 (no_hazard) &((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b1)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (WB_data_write == WB_dmem_data )) ; 
  endproperty
  lh_instr: assert property(check_lh_instr) else begin
    $display ("check lh instr fail");
  end

  property check_lb_instr;
    @(posedge clk) 
    (is_lb_instr) |=> (!IF_ID_flush) & (!stall) |=> (!EX_flush) &  (no_hazard) & ((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b1)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (WB_data_write == WB_dmem_data )) ; 
  endproperty
  lb_instr: assert property(check_lb_instr) begin
    $display ("check lb instr PASSS"); end
  else begin 
    $display ("check lb instr FAIL");
  end

  property check_lbu_instr;
    @(posedge clk) 
    (is_lbu_instr) |=> (!IF_ID_flush)  |=> ((!EX_flush) & (alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |=>  (( MEM_WR == 1'b0 ) & (MEM_RD == 1'b1)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (WB_data_write == WB_dmem_data )) ; 
  endproperty
  lbu_instr: assert property(check_lbu_instr) else begin
    $display ("check lbu instr fail");
  end

  property check_lhu_instr;
    @(posedge clk) 
    (is_lhu_instr) |=> (!IF_ID_flush) |=> (!EX_flush) & (no_hazard) &((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b1)) |=> ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (WB_data_write == WB_dmem_data )) ; 
  endproperty
  lhu_instr: assert property(check_lhu_instr) else begin
    $display ("check lhu instr fail");
  end

  property check_sb_instr;
    @(posedge clk) 
    (is_sb_instr) |=> (!IF_ID_flush) |=> (!EX_flush) & (no_hazard) & ((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b1 ) & (MEM_RD == 1'b0)& (data_write_mem == mem_rs1_data )) ; 
  endproperty
  sb_instr: assert property(check_sb_instr) else begin
    $display ("check sb instr fail");
  end

  property check_sh_instr;
    @(posedge clk) 
    (is_sh_instr) |=> (!IF_ID_flush) |=> (!EX_flush) &  (no_hazard) &((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b1 ) & (MEM_RD == 1'b0) & (data_write_mem == mem_rs1_data )) ; 
  endproperty
  sh_instr: assert property(check_sh_instr) else begin
    $display ("check sh instr fail");
  end

  property check_sw_instr;
    @(posedge clk) 
    (is_sw_instr) |=> (!IF_ID_flush) |=> (!EX_flush) & (no_hazard) &((alu_result == (op_a_alu + op_b_alu)) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b1 ) & (MEM_RD == 1'b0) & (data_write_mem == mem_rs1_data )) ; 
  endproperty
  sw_instr: assert property(check_sw_instr) else begin
    $display ("check sw instr fail");
  end

  // BRANCH INSTR
  property check_beg_instr;
    @(posedge clk) 
    (is_beg_instr) |-> ##2 (no_hazard) &((EX_zero == (op_a_alu ==  op_b_alu)? 1'b1 : 1'b0) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 (( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) ; 
  endproperty
  beg_instr: assert property(check_beg_instr) else begin
    $display ("check beg instr fail");
  end

  property check_bne_instr;
    @(posedge clk) 
    (is_bne_instr) |=> (!IF_ID_flush) |=> (!EX_flush) &  ((no_hazard) &(EX_zero == (op_a_alu !=  op_b_alu) ? 1'b1 : 1'b0) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 (( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) ; 
  endproperty
  bne_instr: assert property(check_bne_instr) else begin
    $display ("check bne instr fail");
  end

  property check_blt_instr;
    @(posedge clk) 
    (is_blt_instr) |=> (!IF_ID_flush) |=> ((!EX_flush)  & (EX_zero == ($signed(op_a_alu) <  $signed(op_b_alu)) ? 1'b1 : 1'b0) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 (( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) ; 
  endproperty
  blt_instr: assert property(check_blt_instr) else begin
    $display ("check blt instr fail");
  end

  property check_bge_instr;
    @(posedge clk) 
    (is_bge_instr)  |=> (!IF_ID_flush) |=> ((!EX_flush) &  (EX_zero <= (op_a_alu !=  op_b_alu)? 1'b1 : 1'b0) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 (( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) ; 
  endproperty
  bge_instr: assert property(check_bge_instr) else begin
    $display ("check bge instr fail");
  end

  property check_bltu_instr;
    @(posedge clk) 
    (is_bltu_instr) |-> ##2 ((no_hazard) &(EX_zero == (op_a_alu <  op_b_alu)? 1'b1 : 1'b0) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 (( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) ; 
  endproperty
  bltu_instr: assert property(check_bltu_instr) else begin
    $display ("check bltu instr fail");
  end

  property check_bgeu_instr;
    @(posedge clk) 
    (is_bgeu_instr) |-> ##2 ((no_hazard) &(EX_zero == (op_a_alu >=  op_b_alu)? 1'b1 : 1'b0) & ( op_a_alu == ID_rs1_data ) & (op_b_alu == ID_rs2_data )) |-> ##1 (( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0)) ; 
  endproperty
  bgeu_instr: assert property(check_bgeu_instr) else begin
    $display ("check bgeu instr fail");
  end



endmodule
