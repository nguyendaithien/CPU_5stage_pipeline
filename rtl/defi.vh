`ifndef defi
`define defi

    // OPCODES
    `define OPCODE_OP          7'b0110011  
    `define OPCODE_OP_IMM      7'b0010011
    `define OPCODE_BRANCH      7'b1100011
    `define OPCODE_LUI         7'b0110111 
    `define OPCODE_AUIPC       7'b0010111 
    `define OPCODE_JAL         7'b1101111 
    `define OPCODE_JALR        7'b1100111 
    `define OPCODE_LOAD        7'b0000011 
    `define OPCODE_STORE       7'b0100011 
    `define OPCODE_SYSTEM      7'h73
    
    // EXCEPTIONS
    `define ECALL              32'h00000073
    `define EBREAK             32'h00100073

    // FUNCT7 - OP
    `define FUNCT7_SRA_I_SUB   7'b0100000
    `define FUNCT7_DEFAULT     7'b0000000
    
    // FUNCT3 - OP
    `define FUNCT3_ADD_SUB     3'b000
    `define FUNCT3_SLL         3'b001
    `define FUNCT3_SLT         3'b010
    `define FUNCT3_SLTU        3'b011
    `define FUNCT3_XOR         3'b100
    `define FUNCT3_SRL_SRA     3'b101
    `define FUNCT3_OR          3'b110
    `define FUNCT3_AND         3'b111
    
    // FUNCT3 - IMM
    `define FUNCT3_ADDI        3'b000
    `define FUNCT3_ANDI        3'b111
    `define FUNCT3_ORI         3'b110
    `define FUNCT3_XORI        3'b100
    `define FUNCT3_SLTI        3'b010
    `define FUNCT3_SLTIU       3'b011
    `define FUNCT3_SRAI_SRLI   3'b101
    `define FUNCT3_SLLI        3'b001
    
    // FUNCT3 - LOAD
    `define FUNCT3_LW          3'b010
    `define FUNCT3_LB          3'b000
    `define FUNCT3_LH          3'b001
    `define FUNCT3_LBU         3'b100 
    `define FUNCT3_LHU         3'b101 
    
    
    // FUNCT3 - STORE
    `define FUNCT3_SB          3'b000
    `define FUNCT3_SW          3'b010
    `define FUNCT3_SH          3'b001
    
    // FUNCT3 - BRANCH
    `define FUNCT3_BEQ         3'b000
    `define FUNCT3_BNE         3'b001
    `define FUNCT3_BLT         3'b100
    `define FUNCT3_BGE         3'b101
    `define FUNCT3_BLTU        3'b110
    `define FUNCT3_BGEU        3'b111
    
    // ALU
    `define ALU_ADD            4'd0  // add
    `define ALU_SUB            4'd1  // subtact
    `define ALU_AND            4'd2  // logical AND
    `define ALU_OR             4'd3  // logical OR
    `define ALU_XOR            4'd4  // logical XOR
    
    `define ALU_SLL            4'd5  // logical left shift
    `define ALU_SRL            4'd6  // logical right shift
    `define ALU_SRA            4'd7  // arithmetic right shift
    `define ALU_SLT            4'd8  // arithmetic right shift
    `define ALU_SLTU           4'd9  // arithmetic right shift


    
    `define ALU_BEQ            4'd10  
    `define ALU_BNE            4'd11 
    `define ALU_BLT            4'd12 
    `define ALU_BGE            4'd13 
    `define ALU_BLTU           4'd14 
    `define ALU_BGEU           4'd15 
    
    // BRANCH GEN
    `define PC_RELATIVE       2'b10  // conditional branch
    `define REG_OFFSET        2'b11
    
    
    // MEMORY STORE/LOAD MASK SELECT
    `define MEM_LB            4'b0000
    `define MEM_LH            4'b0001
    `define MEM_LW            4'b0010
    
    `define MEM_LB_U          4'b1000
    `define MEM_LH_U          4'b1001

    `define MEM_SB            4'b0111
    `define MEM_SH            4'b0100
    `define MEM_SW            4'b0101

`endif
