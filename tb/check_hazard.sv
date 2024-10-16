module check_hazard(
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
logic [31:0] data_write_reg; assign data_write_reg = top.id_stage.data_write_reg; 
logic [31:0] op_a_alu;assign op_a_alu = top.ex_stage.op_a_alu;  
logic [31:0] op_b_alu;assign op_b_alu = top.ex_stage.op_b_alu;
logic [31:0] alu_result; assign alu_result = top.ex_stage.alu_result;
 

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

  logic [1:0 ] EX_sel_to_reg      ; assign EX_sel_to_reg         =   top.EX_sel_to_reg                ;                          
  logic        EX_RD              ; assign EX_RD                 =   top.EX_RD                        ;                          
  logic        EX_WR              ; assign EX_WR                 =   top.EX_WR                        ;                          
  logic [3:0 ] EX_mem_op          ; assign EX_mem_op             =   top.EX_mem_op                    ;                          
  logic [31:0] EX_alu_result      ; assign EX_alu_result         =   top.EX_alu_result                ;                          
  logic        EX_zero_o          ; assign EX_zero_o             =   top.EX_zero                      ;                          
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
  logic [31:0] MEM_alu_result     ; assign MEM_alu_result        =   top.MEM_alu_result               ;                          
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
  logic stall       ; assign stall       = top.stall                                         ;
  logic IF_ID_flush ; assign IF_ID_flush = top.IF_ID_flush                                   ;
  logic EX_flush    ; assign EX_flush    = top.EX_flush                                      ;
  logic EX_zero     ; assign EX_zero     = top.ex_stage.zero                                 ;
  logic hazard      ; assign hazard      = top.hazard                                        ;
  logic no_hazard   ; assign no_hazard = (~hazard) & (~EX_flush) & (~IF_ID_flush) & (~stall) ;

// decode instr
 logic [31:0] IF_instr ; assign IF_instr = top.if_stage.IF_instr_i ;
 logic [2:0]  funct_3  ; assign funct_3  = IF_instr[14:12]         ;
 logic [6:0]  opcode   ; assign opcode   = IF_instr[6:0]           ;

 logic is_add_instr    ; assign is_add_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_ADD_SUB) & (IF_instr[30] == 1'b0)     ;
 logic is_load_instr   ; assign is_load_instr    = (opcode == OPCODE_LOAD)                                                           ;
 logic is_store_instr  ; assign is_store_inst    = (opcode == OPCODE_STORE)                                                          ;
 logic is_imm_instr    ; assign is_imm_instr     = (opcode == OPCODE_OP_IMM)                                                         ;
 logic is_branch_instr ; assign is_branch_instr  = (opcode == OPCODE_BRANCH)                                                         ;
 logic is_op_instr     ; assign is_op_instr      = (opcode == OPCODE_OP)                                                             ;
 logic is_sub_instr    ; assign is_sub_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_ADD_SUB) & (IF_instr[30] == 1'b0)     ;
 logic is_sll_instr    ; assign is_sll_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SLL)                                  ;
 logic is_slt_instr    ; assign is_slt_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SLT)                                  ;
 logic is_sltu_instr   ; assign is_sltu_instr    = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SLTU)                                 ;
 logic is_xor_instr    ; assign is_xor_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_XOR)                                  ;
 logic is_srl_instr    ; assign is_srl_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SRL_SRA) & (IF_instr[30]     == 1'b0) ;
 logic is_sra_instr    ; assign is_sra_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_SRL_SRA) & (IF_instr[30]     == 1'b1) ;
 logic is_or_instr     ; assign is_or_instr      = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_OR)                                   ;
 logic is_and_instr    ; assign is_and_instr     = (opcode == OPCODE_OP) & (funct_3 == `FUNCT3_AND)                                  ;

 logic is_addi_instr  ; assign is_addi_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_ADDI)                                   ;
 logic is_slli_instr  ; assign is_slli_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SLLI )                                  ;
 logic is_slti_instr  ; assign is_slti_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SLTI )                                  ;
 logic is_sltiu_instr ; assign is_sltiu_instr = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SLTIU)                                  ;
 logic is_xori_instr  ; assign is_xori_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_XORI)                                   ;
 logic is_srli_instr  ; assign is_srli_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SRAI_SRLI) & (IF_instr[30]     == 1'b0) ;
 logic is_srai_instr  ; assign is_srai_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_SRAI_SRLI) & (IF_instr[30]     == 1'b1) ;
 logic is_ori_instr   ; assign is_ori_instr   = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_ORI)                                    ;
 logic is_andi_instr  ; assign is_andi_instr  = (opcode == OPCODE_OP_IMM) & (funct_3 == `FUNCT3_ANDI)                                   ;

 logic is_lui_instr   ; assign is_lui_instr   = (opcode == OPCODE_LUI)   ;
 logic is_auipc_instr ; assign is_auipc_instr = (opcode == OPCODE_AUIPC) ;
 logic is_jalr_instr  ; assign is_jalr_instr  = (opcode == OPCODE_JALR)  ;
 logic is_jal_instr   ; assign is_jal_instr   = (opcode == OPCODE_JAL)   ;
 logic  EX_regwrite   ; assign  EX_regwrite  = top.EX_regwrite           ;
 logic  MEM_regwrite  ; assign  MEM_regwrite = top.MEM_regwrite          ;
 logic  WB_regwrire   ; assign WB_regwrite   = top.MEM_regwrite          ;

 logic [4:0] EX_rd_add     ; assign EX_rd_add   =  top.EX_rd_add ; 
 logic [4:0] ID_rd_add     ; assign ID_rd_add   =  top.ID_rd_add ; 
 logic [4:0] ID_rs1_add    ; assign ID_rs1_add  =  top.ID_rs1_add; 
 logic [4:0] MEM_rd_add    ; assign MEM_rd_add  =  top.MEM_rd_add; 
 logic [4:0] ID_rs2_add    ; assign ID_rs2_add  =  top.ID_rs2_add; 
 logic [4:0] EX_rs1_add    ; assign EX_rs1_add  =  top.EX_rs1_add; 
 logic [4:0] EX_rs2_add    ; assign EX_rs2_add  =  top.EX_rs2_add; 
 logic       hazard_EX_rs1 ; assign hazard_EX_rs1 = (EX_regwrite == 1'b1) && (EX_rd_add != 0 ) && (EX_rd_add == ID_rs1_add)                                                                                                          ;
 logic       hazard_WB_rs1 ; assign hazard_WB_rs1 = ((!hazard_EX_rs1) & (MEM_regwrite == 1'b1) && (MEM_rd_add != 0 ) && ~( (EX_regwrite  == 1'b1) && (EX_rd_add != 0) && (EX_rd_add == ID_rs1_add)) && (MEM_rd_add == ID_rs1_add))   ;
 logic       hazard_EX_rs2 ; assign hazard_EX_rs2 = ( (EX_regwrite == 1'b1) && (EX_rd_add != 0) && (EX_rd_add  == ID_rs2_add))                                                                                                       ;
 logic       hazard_WB_rs2 ; assign hazard_WB_rs2 = ((!hazard_EX_rs2) &  (MEM_regwrite == 1'b1) && (MEM_rd_add != 0) &&  ~ ( (EX_regwrite  == 1'b1) && (EX_rd_add != 0) && (EX_rd_add == ID_rs2_add)) && (MEM_rd_add == ID_rs2_add)) ;
 logic       mem_hazard    ; assign mem_hazard    = (MEM_regwrite == 1'b1) && (EX_rs2_add == MEM_rd_add) && (MEM_rd_add != 0)                                                                                                        ;

 ctrl_fsm_e current_state; assign current_state = top.control_main.current_state;


  property check_add_instr_hazard_EX_rs1;
    @(posedge clk) 
    (is_op_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=> (hazard_EX_rs1) & (!EX_flush)  & (( op_a_alu == EX_alu_result ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == ($past(alu_result,2))) ) ; 
  endproperty
  add_instr_hazard_EX_rs1: assert property(check_add_instr_hazard_EX_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD 1"  ); end
    else begin
    $display ("check hazard 1 fail");
  end

  property check_add_instr_hazard_EX_rs2;
    @(posedge clk) 
    (is_op_instr & (current_state == PROCESSING))  |=> (!IF_ID_flush) |=> (hazard_EX_rs2) & (!EX_flush)  & (( op_a_alu == ID_rs1_data ) & (op_b_alu == EX_alu_result )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == ($past(alu_result,2))) ) ; 
  endproperty
  add_instr_hazard_EX_rs2: assert property(check_add_instr_hazard_EX_rs2) 
  begin
    $display( "[HAZARD] pass HAZARD 2"  ); end
    else begin
    $display ("check hazard 2 fail");
  end

  property check_add_instr_hazard_WB_rs1;
    @(posedge clk) 
    (is_op_instr & (current_state == PROCESSING)) |=> (!IF_ID_flush) |=> (hazard_WB_rs1) & (!EX_flush)  |->  (( op_a_alu == WB_data_write ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == ($past(alu_result,2))) ) ; 
  endproperty
  add_instr_hazard_WB_rs1: assert property(check_add_instr_hazard_WB_rs1)
  begin
    $display( "[HAZARD] pass HAZARD 3"  ); end
    else begin
    $display ("check hazard 3 fail");
  end

  property check_add_instr_hazard_WB_rs2;
    @(posedge clk) 
    (is_op_instr & (current_state == PROCESSING)) |=> (!IF_ID_flush) |=> (hazard_WB_rs2) & (!EX_flush) |->  (( op_a_alu == ID_rs1_data ) & (op_b_alu == WB_data_write )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == ($past(alu_result,2))) ) ; 
  endproperty
  add_instr_hazard_WB_rs2: assert property(check_add_instr_hazard_WB_rs1)
  begin
    $display( "[HAZARD] pass HAZARD 4"  ); end
    else begin
    $display ("check hazard 4 fail");
  end
// LOAD STORE
  property check_load_instr_hazard_EX_rs1;
    @(posedge clk) 
    (is_load_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=>  (hazard_EX_rs1) & (!EX_flush)  & (( op_a_alu == EX_alu_result ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b1))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == top.DMEM_data_o) ) ; 
  endproperty
  load_instr_hazard_EX_rs1: assert property(check_load_instr_hazard_EX_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD load rs1"  ); end
    else begin
    $display ("check hazard load 1 fail");
  end

  property check_load_instr_hazard_WB_rs1;
    @(posedge clk) 
    (is_load_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=> (hazard_WB_rs1) & (!EX_flush)  & (( op_a_alu == EX_alu_result ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b1))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == top.DMEM_data_o) ) ; 
  endproperty
  load_instr_hazard_WB_rs1: assert property(check_load_instr_hazard_WB_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD load 2"  ); end
    else begin
    $display ("check hazard load 2 fail");
  end

  property check_store_instr_hazard_EX_rs1;
    @(posedge clk) 
    (is_store_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=> (hazard_EX_rs1) & (!EX_flush)  & (( op_a_alu == EX_alu_result ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b1 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b0)) ; 
  endproperty
  store_instr_hazard_EX_rs1: assert property(check_store_instr_hazard_EX_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD store rs1"  ); end
    else begin
    $display ("check hazard store 1 fail");
  end

  property check_store_instr_hazard_WB_rs1;
    @(posedge clk) 
    (is_store_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=> (hazard_WB_rs1) & (!EX_flush)  & (( op_a_alu == WB_data_write ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b1 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b0)) ; 
  endproperty
  store_instr_hazard_WB_rs1: assert property(check_store_instr_hazard_WB_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD store 2"  ); end
    else begin
    $display ("check hazard store 2 fail");
  end

  // IMM ISTR
  property check_imm_instr_hazard_EX_rs1;
    @(posedge clk) 
    (is_imm_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=> (hazard_EX_rs1) & (!EX_flush)  & (( op_a_alu == EX_alu_result ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == ($past(alu_result,2))) ) ; 
  endproperty
  imm_instr_hazard_EX_rs1: assert property(check_imm_instr_hazard_EX_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD imm rs1"  ); end
    else begin
    $display ("check hazard imm 1 fail");
  end

  property check_imm_instr_hazard_WB_rs1;
    @(posedge clk) 
    (is_imm_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=> (hazard_WB_rs1) & (!EX_flush)  & (( op_a_alu == WB_data_write ) & (op_b_alu == ID_imm )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b1) & (data_write_reg == WB_data_write) & (data_write_reg == ($past(alu_result,2))) ) ; 
  endproperty
  imm_instr_hazard_WB_rs1: assert property(check_imm_instr_hazard_WB_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD imm 2"  ); end
    else begin
    $display ("check hazard imm 2 fail");
  end

  // BRANCH INSTR
  property check_branch_instr_hazard_EX_rs1;
    @(posedge clk) 
    (is_branch_instr & (current_state == PROCESSING) & (!IF_ID_flush ))  |=> (!IF_ID_flush) |=> (hazard_EX_rs1) & (!EX_flush)  & (( op_a_alu == EX_alu_result ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b0) ) ; 
  endproperty
  branch_instr_hazard_EX_rs1: assert property(check_branch_instr_hazard_EX_rs1) 
  begin
    $display( "[HAZARD] pass HAZARD branch 1"  ); end
    else begin
    $display ("check hazard br 1 fail");
  end

  property check_branch_instr_hazard_EX_rs2;
    @(posedge clk) 
    (is_branch_instr & (current_state == PROCESSING))  |=> (!IF_ID_flush) |=> (hazard_EX_rs2) &  (!EX_flush) &  (hazard_EX_rs2) & (( op_a_alu == ID_rs1_data ) & (op_b_alu == EX_alu_result )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b0) ) ; 
  endproperty
  branch_instr_hazard_EX_rs2: assert property(check_branch_instr_hazard_EX_rs2) 
  begin
    $display( "[HAZARD] pass HAZARD branch 2"  ); end
    else begin
    $display ("check hazard 2 br fail");
  end

  property check_branch_instr_hazard_WB_rs1;
    @(posedge clk) 
    (is_branch_instr & (current_state == PROCESSING)) |=> (!IF_ID_flush) |=> (hazard_WB_rs1) &  (!EX_flush) &  (hazard_WB_rs1) |->  (( op_a_alu == WB_data_write ) & (op_b_alu == ID_rs2_data )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b0)) ; 
  endproperty
  branch_instr_hazard_WB_rs1: assert property(check_branch_instr_hazard_WB_rs1)
  begin
    $display( "[HAZARD] pass HAZARD BRANCH 3"  ); end
    else begin
    $display ("check hazard br 3 fail");
  end

  property check_branch_instr_hazard_WB_rs2;
    @(posedge clk) 
    (is_branch_instr & (current_state == PROCESSING)) |=> (!IF_ID_flush) |=>  (!EX_flush) & (hazard_WB_rs2) |->  (( op_a_alu == ID_rs1_data ) & (op_b_alu == WB_data_write )) |-> ##1 ( ( MEM_WR == 1'b0 ) & (MEM_RD == 1'b0))  |-> ##1 ((WB_regwrite == 1'b0)  ) ; 
  endproperty
  branch_instr_hazard_WB_rs2: assert property(check_branch_instr_hazard_WB_rs1)
  begin
    $display( "[HAZARD] pass HAZARD BRANCH 4"  ); end
    else begin
    $display ("check hazard br fail");
  end
  //




endmodule
