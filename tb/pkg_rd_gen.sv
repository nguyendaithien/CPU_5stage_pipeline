package pkg_rd_gen;

  `define  OPCODE_LOAD      7'h03
  `define  OPCODE_MISC_MEM  7'h0f
  `define  OPCODE_OP_IMM    7'h13
  `define  OPCODE_AUIPC     7'h17
  `define  OPCODE_STORE     7'h23
  `define  OPCODE_OP        7'h33
  `define  OPCODE_LUI       7'h37
  `define  OPCODE_BRANCH    7'h63
  `define  OPCODE_JALR      7'h67
  `define  OPCODE_JAL       7'h6f
  `define  OPCODE_SYSTEM    7'h73

  typedef enum logic [6:0] {
    OPCODE_LOAD     = 7'h03,
    OPCODE_MISC_MEM = 7'h0f,
    OPCODE_OP_IMM   = 7'h13,
    OPCODE_AUIPC    = 7'h17,
    OPCODE_STORE    = 7'h23,
    OPCODE_OP       = 7'h33,
    OPCODE_LUI      = 7'h37,
    OPCODE_BRANCH   = 7'h63,
    OPCODE_JALR     = 7'h67,
    OPCODE_JAL      = 7'h6f,
    OPCODE_SYSTEM   = 7'h73
  } opcode_e;

  typedef enum logic [4:0] {
    X1  = 5'd1,
    X2  = 5'd2,
    X3  = 5'd3,
    X4  = 5'd4,
    X5  = 5'd5,
    X6  = 5'd6,
    X7  = 5'd7,
    X8  = 5'd8,
    X9  = 5'd9,
    X10 = 5'd10,
    X11 = 5'd11,
    X12 = 5'd12,
    X13 = 5'd13,
    X14 = 5'd14,
    X15 = 5'd15,
    X16 = 5'd16,
    X17 = 5'd17,
    X18 = 5'd18,
    X19 = 5'd19,
    X20 = 5'd20,
    X21 = 5'd21,
    X22 = 5'd22,
    X23 = 5'd23,
    X24 = 5'd24,
    X25 = 5'd25,
    X26 = 5'd26,
    X27 = 5'd27,
    X28 = 5'd28,
    X29 = 5'd29,
    X30 = 5'd30,
    X31 = 5'd31
  } register_e;

  typedef enum logic [2:0] {
   FUNCT3_ADD_SUB    =  3'd0,  
   FUNCT3_SLL        =  3'd1,
   FUNCT3_SLT        =  3'd2,
   FUNCT3_SLTU       =  3'd3,
   FUNCT3_XOR        =  3'd4,
   FUNCT3_SRL_SRA    =  3'd5,
   FUNCT3_OR         =  3'd6,
   FUNCT3_AND        =  3'd7
 } funct3_r_t;

  typedef enum logic [2:0] {
   FUNCT3_ADDI       =  3'b000, 
   FUNCT3_ANDI       =  3'b111,
   FUNCT3_ORI        =  3'b110,
   FUNCT3_XORI       =  3'b100,
   FUNCT3_SLTI       =  3'b010,
   FUNCT3_SLTIU      =  3'b011,
   FUNCT3_SRAI_SRLI  =  3'b101,
   FUNCT3_SLLI       =  3'b001
 } funct3_i_t;


  typedef enum logic [2:0] {
   FUNCT3_SB    =  3'b000, 
   FUNCT3_SW    =  3'b010,
   FUNCT3_SH    =  3'b001
 } funct3_s_t;

  typedef struct packed{ 
    randc opcode_e opcode;
    randc funct3_r_t funct3;
    randc register_e rs1;  
    randc register_e rs2;
    randc register_e rd;
    randc bit [6:0] funct7;
  } instr_R_type;

  typedef struct packed{ 
    randc opcode_e opcode;
    randc funct3_i_t funct3;
    randc register_e rs1;  
    randc register_e rd;
    randc bit [11:0] imm;
  } instr_I_type;

  typedef struct packed{ 
    randc opcode_e opcode;
    randc funct3_i_t funct3;
    randc register_e rs1;  
    randc register_e rs2;
    randc bit [6:0] imm_1;
    randc bit [4:0] imm_2;
  } instr_S_type;

endpackage
