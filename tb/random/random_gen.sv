import pkg_rd_gen::*;

  class instr_format;
    rand instr_R_type instr;
    rand instr_I_type instr_i;
    rand instr_S_type instr_s;
    rand instr_L_type instr_l;
    rand instr_B_type instr_b;
    rand instr_U_type instr_u;
    rand instr_J_type instr_j;
    bit [31:0] R_instr;
    bit [31:0] I_instr;
    bit [31:0] S_instr;
    bit [31:0] L_instr;
    bit [31:0] B_instr;
    bit [31:0] U_instr;
    bit [31:0] J_instr;

    bit [7:0] counter_r     ;
    bit [7:0] counter_add   ;
    bit [7:0] counter_slt   ;
    bit [7:0] counter_sub   ;
    bit [7:0] counter_or    ;
    bit [7:0] counter_xor   ;
    bit [7:0] counter_sltu  ;
    bit [7:0] counter_sra   ;
    bit [7:0] counter_srl   ;
    bit [7:0] counter_and   ;
    bit [7:0] counter_sll   ;
    bit [7:0] counter_addi  ;
    bit [7:0] counter_slti  ;
    bit [7:0] counter_subi  ;
    bit [7:0] counter_ori   ;
    bit [7:0] counter_sltui ;
    bit [7:0] counter_xori  ;
    bit [7:0] counter_srai  ;
    bit [7:0] counter_srli  ;
    bit [7:0] counter_andi  ;
    bit [7:0] counter_slli  ;
    bit [9:0] counter_lb    ;
    bit [9:0] counter_lh    ;
    bit [9:0] counter_lw    ;
    bit [9:0] counter_sb    ;
    bit [9:0] counter_sh    ;
    bit [9:0] counter_sw    ;
    bit [9:0] counter_jal   ;
    bit [9:0] counter_jalr  ;
    bit [9:0] counter_bge   ;
    bit [9:0] counter_bne   ;
    bit [9:0] counter_beq   ;
    bit [9:0] counter_blt   ;
    bit [9:0] counter_bltu  ;
    bit [9:0] counter_bgeu  ;
    bit [9:0] counter_lui   ;
    bit [9:0] counter_auipc ;


    rand bit [3:0] random_1;
    rand bit [3:0] random_2;

    bit [31:0] Instr_set [800];

    function counter_R(instr_format instr_i);
      if(instr_i.instr.opcode == OPCODE_OP) begin
        counter_r = counter_r + 1;
        if((instr_i.instr.funct3 == FUNCT3_ADD_SUB ) & (instr_i.instr.funct7[6] == 0 )) begin
          counter_add = counter_add + 10'd1;
        end
        if((instr_i.instr.funct3 == FUNCT3_SRL_SRA ) & (instr_i.instr.funct7[6] == 1 )) begin
          counter_sra = counter_sra + 10'd1;
        end
        if((instr_i.instr.funct3 == FUNCT3_SRL_SRA ) & (instr_i.instr.funct7[6] == 0 )) begin
          counter_srl = counter_srl + 10'd1;
        end
        else if(instr_i.instr.funct3 == FUNCT3_SLT) begin
          counter_slt = counter_slt + 10'd1;
        end
        else if(instr_i.instr.funct3 == FUNCT3_SLTU) begin
          counter_sltu = counter_sltu + 10'd1;
        end
        else if(instr_i.instr.funct3 == FUNCT3_ADD_SUB &  (instr_i.instr.funct7[6] == 1 )) begin
          counter_sub = counter_sub + 10'd1;
        end
        else if(instr_i.instr.funct3 == FUNCT3_SLL ) begin
          counter_sll = counter_sll + 10'd1;
        end
        else if(instr_i.instr.funct3 == FUNCT3_AND ) begin
          counter_and = counter_and + 10'd1;
        end
        else if(instr_i.instr.funct3 == FUNCT3_OR ) begin
          counter_or = counter_or + 10'd1;
        end
        else if(instr_i.instr.funct3 == FUNCT3_XOR ) begin
          counter_xor = counter_xor + 10'd1;
        end
      end
    endfunction

    function counter_I(instr_format instr_i);
      if(instr_i.instr_i.opcode == OPCODE_OP_IMM) begin
        counter_r = counter_r + 1;
        if((instr_i.instr_i.funct3 == FUNCT3_ADDI )) begin
          counter_addi = counter_addi + 10'd1;
        end
        if((instr_i.instr.funct3 == FUNCT3_SRAI_SRLI ) & (instr_i.instr.funct7[6] == 1 )) begin
          counter_srai = counter_srai + 10'd1;
        end
        if((instr_i.instr.funct3 == FUNCT3_SRAI_SRLI ) & (instr_i.instr.funct7[6] == 0 )) begin
          counter_srli = counter_srli + 10'd1;
        end
        else if(instr_i.instr_i.funct3 == FUNCT3_SLTI) begin
          counter_slti = counter_slti + 10'd1;
        end
        else if(instr_i.instr_i.funct3 == FUNCT3_SLTIU) begin
          counter_sltui = counter_sltui + 10'd1;
        end
        else if(instr_i.instr_i.funct3 == FUNCT3_SLLI ) begin
          counter_slli = counter_slli + 10'd1;
        end
        else if(instr_i.instr_i.funct3 == FUNCT3_ANDI ) begin
          counter_andi = counter_andi + 10'd1;
        end
        else if(instr_i.instr_i.funct3 == FUNCT3_ORI ) begin
          counter_ori = counter_ori + 10'd1;
        end
        else if(instr_i.instr_i.funct3 == FUNCT3_XORI ) begin
          counter_xori = counter_xori + 10'd1;
        end
      end
    endfunction

    function counter_JAL(instr_format instr_i);
      if(instr_i.instr_j.opcode == OPCODE_JAL) begin 
        counter_jal = counter_jal + 10'd1;
      end
    endfunction

    function counter_LUI(instr_format instr_i);
      if(instr_i.instr_u.opcode == OPCODE_LUI) begin 
        counter_lui = counter_lui + 10'd1;
      end
    endfunction

    function counter_AUIPC(instr_format instr_i);
      if(instr_i.instr_u.opcode == OPCODE_AUIPC) begin 
        counter_auipc = counter_auipc + 10'd1;
      end
    endfunction
    function counter_JALR(instr_format instr_i);
      if(instr_i.instr_j.opcode == OPCODE_JALR) begin 
        counter_jalr = counter_jalr + 10'd1;
      end
    endfunction

    function counter_S(instr_format instr_i);
      if(instr_i.instr_s.opcode == OPCODE_STORE) begin 
       if(instr_i.instr_s.funct3 == FUNCT3_SB) begin
        counter_sb = counter_sb + 10'd1;
      end
       if(instr_i.instr_s.funct3 == FUNCT3_SH) begin
        counter_sh = counter_sh + 10'd1;
      end
       if(instr_i.instr_s.funct3 == FUNCT3_SW) begin
        counter_sw = counter_sw + 10'd1;
      end
      end
    endfunction

    function counter_B(instr_format instr_i);
      if(instr_i.instr_b.opcode == OPCODE_BRANCH) begin 
       if(instr_i.instr_b.funct3 == FUNCT3_BEQ) begin
        counter_beq = counter_beq + 10'd1;
      end
       if(instr_i.instr_b.funct3 == FUNCT3_BNE) begin
        counter_bne = counter_bne + 10'd1;
      end
       if(instr_i.instr_b.funct3 == FUNCT3_BLT) begin
        counter_blt = counter_blt + 10'd1;
      end
       if(instr_i.instr_b.funct3 == FUNCT3_BGE) begin
        counter_bge = counter_bge + 10'd1;
      end
       if(instr_i.instr_b.funct3 == FUNCT3_BLTU) begin
        counter_bltu = counter_bltu + 10'd1;
      end
       if(instr_i.instr_b.funct3 == FUNCT3_BGEU) begin
        counter_bgeu = counter_bgeu + 10'd1;
      end
      end
    endfunction


    function counter_L(instr_format instr_i);
      if(instr_i.instr_l.opcode == OPCODE_LOAD) begin
        if(instr_i.instr_l.funct3 == FUNCT3_LB) begin
          counter_lb = counter_lb + 10'd1;
        end
        if(instr_i.instr_l.funct3 == FUNCT3_LH) begin
          counter_lh = counter_lh + 10'd1;
        end
        if(instr_i.instr_l.funct3 == FUNCT3_LW) begin
          counter_lw = counter_lw + 10'd1;
        end
      end
    endfunction

    function new();
      counter_r = 10'd0;
      counter_add = 10'd0 ;
      counter_slt = 10'd0 ;
      counter_sub = 10'd0 ;
      counter_or  = 10'd0 ;
      counter_xor = 10'd0 ;
      counter_sltu= 10'd0 ;
      counter_sra = 10'd0 ;
      counter_srl = 10'd0 ;
      counter_and = 10'd0 ;
      counter_lb = 10'd0 ;
      counter_addi  = 10'd0  ;
      counter_slti  = 10'd0  ;
      counter_subi  = 10'd0  ;
      counter_ori   = 10'd0  ;
      counter_sltui = 10'd0  ;
      counter_xori  = 10'd0  ;
      counter_srai  = 10'd0  ;
      counter_srli  = 10'd0  ;
      counter_andi  = 10'd0  ;
      counter_slli  = 10'd0  ;
      counter_lh    = 10'd0  ;
      counter_lw    = 10'd0  ;
      counter_sb    = 10'd0  ;
      counter_sh    = 10'd0  ;
      counter_sw    = 10'd0  ;
      counter_jal   = 10'd0  ;
      counter_jalr  = 10'd0  ;
      counter_bge   = 10'd0  ;
      counter_bne   = 10'd0  ;
      counter_beq   = 10'd0  ;
      counter_blt   = 10'd0  ;
      counter_bltu  = 10'd0  ;
      counter_bgeu  = 10'd0  ;
      counter_lui   = 10'd0  ;
      counter_auipc = 10'd0  ;
    endfunction

  constraint random1 { random_1 inside {0,1,2,3,4,5,6,7,8,9,10};}
  constraint random2 { random_2 inside {0,1,2,3,4,5,6,7,8,9,10};}
  constraint random3 { if(random_1) random_2 != random_1 ;}
  constraint random4 { if(random_1 > 5) random_2 inside{0,1,2,3,4} ;}
 /// CONSTRAINT FOR R TYPE
//  constraint R_funct7_ADD_SUB { if (instr.funct3 == FUNCT3_ADD_SUB) instr.funct7 inside {7'b0100000,7'b0000000 }; } 
//  constraint R_funct7_SRA_SRL { if (instr.funct3 == FUNCT3_SRL_SRA) instr.funct7 inside {7'b0100000,7'b0000000 }; } 
  constraint R_opcode {instr.opcode inside{OPCODE_OP};} 

 // CONSTRAINT FOR I TYPE
  constraint I_opcode {instr_i.opcode inside {OPCODE_OP_IMM};} 
  constraint I_mm { instr_i.imm inside {2,4,6,8,10,12} ;} 
 // constraint R_funct3_SRAI_SRLI { if (instr_i.funct3 == FUNCT3_SRAI_SRLI) instr_i.imm[10] inside {1'b1,1'b0};} 

   // CONSTRAINT FOR S_TYPE
  constraint S_opcode  { instr_s.opcode inside {OPCODE_STORE};}
  constraint S_imm1    { instr_s.imm_1 inside {7'd2,7'd4,7'd6};}
  constraint S_imm2    { instr_s.imm_2 inside {5'd2,5'd4,5'd6};}

  // CONSTRAINT FOR L TYPE
  constraint L_mm { instr_l.imm inside {12'd2,12'd4,12'd6,12'd8} ;} 
  constraint L_opcode  { instr_l.opcode inside {OPCODE_LOAD};}

  // CONSTRAINT FOR B TYPE
  constraint B_opcode  { instr_b.opcode inside {OPCODE_BRANCH};}
  constraint B_imm     { {instr_b.imm_1, instr_b.imm_4, instr_b.imm_2, instr_b.imm_3} inside {12'd8, 12'd12, 12'd16} ;}

  // CONSTRAINT FOR U TYPE
  constraint U_opcode  { instr_u.opcode inside {OPCODE_LUI, OPCODE_AUIPC};}
  constraint U_imm { instr_u.imm == 20'd0 ;}

  // CONSTRAINT FOR J TYPE
  constraint J_opcode  { instr_j.opcode inside {OPCODE_JAL, OPCODE_JALR};}
  constraint J_imm     { {instr_j.imm_1, instr_j.imm_4, instr_j.imm_3, instr_j.imm_2} inside {20'd8, 20'd12, 20'd16} ;}

  function assembly_R(instr_format instr_i);
    instr_i.R_instr= {instr_i.instr.funct7,instr_i.instr.rs2, instr_i.instr.rs1,instr_i.instr.funct3, instr_i.instr.rd, instr_i.instr.opcode}; 
    return instr_i.R_instr;
  endfunction

  function assembly_B(instr_format instr_i);
    instr_i.B_instr= {instr_i.instr_b.imm_1,instr_i.instr_b.imm_2, instr_i.instr_b.rs2,instr_i.instr_b.rs1, instr_i.instr_b.funct3, instr_i.instr_b.imm_3, instr_i.instr_b.imm_4, instr_i.instr_b.opcode}; 
    return instr_i.B_instr;
  endfunction

  function assembly_J(instr_format instr_i);
    instr_i.J_instr= {instr_i.instr_j.imm_1,instr_i.instr_j.imm_2, instr_i.instr_j.imm_3,instr_i.instr_j.imm_4, instr_i.instr_j.rd, instr_i.instr_j.opcode} ;
    return instr_i.J_instr;
  endfunction

  function assembly_I(instr_format instr_i);
    instr_i.I_instr= {instr_i.instr_i.imm, instr_i.instr_i.rs1,instr_i.instr_i.funct3, instr_i.instr_i.rd, instr_i.instr_i.opcode}; 
    return instr_i.I_instr;
  endfunction

  function assembly_U(instr_format instr_i);
    instr_i.U_instr= {instr_i.instr_u.imm, instr_i.instr_u.rd,instr_i.instr_u.opcode}; 
    return instr_i.U_instr;
  endfunction

  function assembly_L(instr_format instr_i);
    instr_i.L_instr = {instr_i.instr_l.imm, instr_i.instr_l.rs1,instr_i.instr_l.funct3, instr_i.instr_l.rd, instr_i.instr_l.opcode}; 
    return instr_i.L_instr;
  endfunction

  function assembly_S(instr_format instr_i);
    instr_i.S_instr= {instr_i.instr_s.imm_1,instr_i.instr_s.rs2, instr_i.instr_s.rs1,instr_i.instr_s.funct3, instr_i.instr_s.imm_2, instr_i.instr_s.opcode}; 
    return instr_i.S_instr;
  endfunction

  function display();
    $display (" R_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr.opcode ) ;
    $display (" rs1 = %d  "     , instr.rs1    ) ;
    $display (" rs2 = %d  "     , instr.rs2    ) ;
    $display (" rd = %d  "      , instr.rd     ) ;
    $display (" funct3 = %d  "  , instr.funct3 ) ;
    $display (" funct7 = %d  "  , instr.funct7 ) ;
    $display (" R_instr = %b  " , R_instr      ) ;
  endfunction

  function display_random();
    $display (" ran dom index 1  = %d  " , random_1 ) ;
    $display (" ran dom index 2  = %d  " , random_2 ) ;
  endfunction


  function display_I();
    $display (" I_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_i.opcode ) ;
    $display (" rs1 = %d  "     , instr_i.rs1    ) ;
    $display (" imm = %d  "     , instr_i.imm    ) ;
    $display (" rd = %d  "      , instr_i.rd     ) ;
    $display (" funct3 = %d  "  , instr_i.funct3 ) ;
    $display (" I_instr = %b  " , I_instr      ) ;
  endfunction

  function display_B();
    $display (" B_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_b.opcode ) ;
    $display (" rs1 = %d  "     , instr_b.rs1    ) ;
    $display (" rs2 = %d  "     , instr_b.rs2    ) ;
    $display (" imm = %d  "     , {instr_b.imm_1, instr_b.imm_4,  instr_b.imm_2,instr_b.imm_3} ) ;
    $display (" funct3 = %d  "  , instr_b.funct3 ) ;
    $display (" B_instr = %b  " , B_instr      ) ;
  endfunction

  function display_J();
    $display (" J_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_j.opcode ) ;
    $display (" rd = %d  "     , instr_j.rd    ) ;
    $display (" imm = %d  "     , {instr_j.imm_1, instr_j.imm_4,  instr_j.imm_3,instr_j.imm_2} ) ;
    $display (" J_instr = %b  " , J_instr      ) ;
  endfunction

  function display_L();
    $display (" L_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_l.opcode ) ;
    $display (" rs1 = %d  "     , instr_l.rs1    ) ;
    $display (" imm = %d  "     , instr_l.imm    ) ;
    $display (" rd = %d  "      , instr_l.rd     ) ;
    $display (" funct3 = %d  "  , instr_l.funct3 ) ;
    $display (" L_instr = %b  " , L_instr      ) ;
  endfunction

  function display_U();
    $display (" U_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_u.opcode ) ;
    $display (" rd = %d  "     ,  instr_u.rd    ) ;
    $display (" imm = %d  "     ,  instr_u.imm    ) ;
    $display (" U_instr = %b  " , U_instr      ) ;
  endfunction

  function display_S();
    $display (" S_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_s.opcode ) ;
    $display (" rs1 = %d  "     , instr_s.rs1    ) ;
    $display (" imm_1 = %d  "   , instr_s.imm_1    ) ;
    $display (" imm_2 = %d  "   , instr_s.imm_2    ) ;
    $display (" rs2 = %d  "     , instr_s.rs2     ) ;
    $display (" funct3 = %d  "  , instr_s.funct3 ) ;
    $display (" S_instr = %b  " , S_instr      ) ;
  endfunction

endclass

//endmodule









