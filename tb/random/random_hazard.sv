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

    bit [7:0] counter_r    ;
    bit [7:0] counter_add  ;
    bit [7:0] counter_slt  ;
    bit [7:0] counter_sub  ;
    bit [7:0] counter_or   ;
    bit [7:0] counter_xor  ;
    bit [7:0] counter_sltu ;
    bit [7:0] counter_sra  ;
    bit [7:0] counter_srl  ;
    bit [7:0] counter_and  ;
    bit [7:0] counter_sll  ;

    bit [9:0] counter_lb;
    bit [9:0] counter_lh;
    bit [9:0] counter_lw;

    rand bit [3:0] random_1;
    bit [31:0] Instr_set [800];
    bit [4:0] rd_store_1;

    function store_R(instr instr_i);
      instr_i.rd_store =  instr_i.instr_r.rd;
    endfunction

    constraint hazard_1 { if( instr.rd inside {x2,x3,x4,x5,x6,x7,x8} instr_i.rs1 inside {rd_store} ;}
    constraint hazard_1 { if( instr.rd inside {x2,x3,x4,x5,x6,x7,x8} instr_i.rs2 inside {rd_store} ;}
    constraint hazard_1 { if( instr.rd inside {x2,x3,x4,x5,x6,x7,x8} instr_l.rs1 inside {rd_store} ;}
    constraint hazard_1 { if( instr.rd inside {x2,x3,x4,x5,x6,x7,x8} instr_s.rs1 inside {rd_store} ;}
