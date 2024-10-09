import pkg_rd_gen::*;
module random_gen();

   logic mode_10;
   logic mode_20;
   logic mode_30;


  class instr_format;
    rand instr_R_type instr;
    rand instr_I_type instr_i;
    rand instr_S_type instr_s;
    bit [31:0] R_instr;
    bit [31:0] I_instr;
    bit [31:0] S_instr;
 /// CONSTRAINT FOR R TYPE
  constraint R_funct7_ADD_SUB { if (instr.funct3 == FUNCT3_ADD_SUB) instr.funct7 inside {7'b0100000,7'b0000000 }; } 
  constraint R_funct7_SRA_SRL { if (instr.funct3 == FUNCT3_SRL_SRA) instr.funct7 inside {7'b0100000,7'b0000000 }; } 
  constraint R_opcode {instr.opcode inside{OPCODE_OP};} 

 // CONSTRAINT FOR I TYPE
  constraint I_opcode {instr_i.opcode inside {OPCODE_OP_IMM};} 
  constraint I_mm { instr_i.imm inside {2,4,6,8,10,12,14,16,18,20} ;} 
 // constraint R_funct3_SRAI_SRLI { if (instr_i.funct3 == FUNCT3_SRAI_SRLI) instr_i.imm[10] inside {1'b1,1'b0};} 

   // CONSTRAINT FOR S_TYPE
  constraint S_opcode {instr_s.opcode inside {OPCODE_STORE};}_
  constraint S_imm { instr_s.imm_1 inside {2,4,6,8,10,12,14};}
  constraint S_imm { instr_s.imm_2 inside {2,4,6,8,10,12,14};}

  function assembly_R(instr_format instr_i);
    instr_i.R_instr= {instr_i.instr.funct7,instr_i.instr.rs2, instr_i.instr.rs1,instr_i.instr.funct3, instr_i.instr.rd, instr_i.instr.opcode}; 
    return instr_i.R_instr;
  endfunction

  function assembly_I(instr_format instr_i);
    instr_i.I_instr= {instr_i.instr_i.imm, instr_i.instr_i.rs1,instr_i.instr_i.funct3, instr_i.instr_i.rd, instr_i.instr_i.opcode}; 
    return instr_i.I_instr;
  endfunction

  function assembly_S(instr_format instr_i);
    instr_i.S_instr= {instr_i.instr.imm_1,instr_i.instr.rs2, instr_i.instr.rs1,instr_i.instr.funct3, instr_i.instr.imm_2, instr_i.instr.opcode}; 
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

  function display_I();
    $display (" I_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_i.opcode ) ;
    $display (" rs1 = %d  "     , instr_i.rs1    ) ;
    $display (" imm = %d  "     , instr_i.imm    ) ;
    $display (" rd = %d  "      , instr_i.rd     ) ;
    $display (" funct3 = %d  "  , instr_i.funct3 ) ;
    $display (" I_instr = %b  " , I_instr      ) ;
  endfunction

  function display_S();
    $display (" S_TYPE " ) ;
    $display (" OPCODE  = %h  " , instr_i.opcode ) ;
    $display (" rs1 = %d  "     , instr_i.rs1    ) ;
    $display (" imm_1 = %d  "   , instr_i.imm_1    ) ;
    $display (" imm_2 = %d  "   , instr_i.imm_2    ) ;
    $display (" rs2 = %d  "     , instr_i.rs2     ) ;
    $display (" funct3 = %d  "  , instr_i.funct3 ) ;
    $display (" S_instr = %b  " , S_instr      ) ;
  endfunction

endclass
  instr_format instr_test;
  logic [31:0] R_instr;
  logic [31:0] R;
  logic [31:0] I;
  logic [31:0] S;
  initial begin 
    instr_test = new();
    instr_test.randomize();
    for (int i = 0; i < 10 ; i++) begin
      assert(instr_test.randomize())
      R_instr = {instr_test.instr.funct7,instr_test.instr.rs2, instr_test.instr.rs1,instr_test.instr.funct3, instr_test.instr.rd, instr_test.instr.opcode};
      R = instr_test.assembly_R( instr_test);
      I = instr_test.assembly_I( instr_test);
      S = instr_test.assembly_S( instr_test);
      instr_test.display();
      instr_test.display_I();
      instr_test.display_S();
 //   $display (" INSTR = %b  " , R_instr );
//    $display (" INSTR = %b  " , R );
    end
  end
  endmodule



