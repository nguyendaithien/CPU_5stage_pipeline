module tb();


   logic mode_10;
   logic mode_20;
   logic mode_30;

  instr_format instr_test;
  logic [31:0] R_instr;
  logic [31:0] R;
  logic [31:0] I;
  logic [31:0] S;
  logic [31:0] L;
  logic [31:0] B;
  logic [31:0] U;
  logic [31:0] J;
  int file;
  initial begin
  file = $fopen("instr_set_1.dat","w");
end
//  logic [31:0] Instr_set [500];
  logic [31:0] instr_1;
  logic [31:0] instr_2;
  initial begin 
    instr_test = new();
    for (int i = 0; i < 500 ; i = i+ 2) begin
    instr_test.randomize();
      assert(instr_test.randomize())
      R_instr = {instr_test.instr.funct7,instr_test.instr.rs2, instr_test.instr.rs1,instr_test.instr.funct3, instr_test.instr.rd, instr_test.instr.opcode};

      instr_test.assembly_R( instr_test);
      instr_test.assembly_I( instr_test);
      instr_test.assembly_S( instr_test);
      instr_test.assembly_L( instr_test);
      instr_test.assembly_B( instr_test);
      instr_test.assembly_U( instr_test);
      instr_test.assembly_J( instr_test);

      instr_test.counter_R(instr_test);
      instr_test.counter_L(instr_test);
      instr_test.counter_S(instr_test);
      instr_test.counter_I(instr_test);
      instr_test.counter_B(instr_test);
      instr_test.counter_JAL(instr_test);
      instr_test.counter_JALR(instr_test);
      instr_test.counter_LUI(instr_test);
      instr_test.counter_AUIPC(instr_test);

      instr_test.display_random();

        case(instr_test.random_1)
          4'd0: instr_1 = instr_test.I_instr;
          4'd1: instr_1 = instr_test.S_instr;
          4'd2: instr_1 = instr_test.L_instr;
          4'd3: begin
            if( i > 600 ) begin
            instr_1 = instr_test.B_instr;
            end
            else begin
            instr_1 = instr_2;
            end
          end
          4'd4: instr_1 = instr_test.U_instr;
          4'd5: begin 
            if( i > 400 ) begin
            instr_1 = instr_test.J_instr;
            end
            else begin
            instr_1 = instr_2;
            end
          end
          default: instr_1 = instr_test.R_instr;
        endcase
        case(instr_test.random_2)
          4'd0: instr_2 = instr_test.I_instr;
          4'd1: instr_2 = instr_test.S_instr;
          4'd2: instr_2 = instr_test.L_instr;
          4'd3: begin 
            if( i > 600 ) begin
            instr_2 = instr_test.B_instr;
            end
            else begin
            instr_2 = instr_1;
            end
          end
          4'd4: instr_2 = instr_test.U_instr;
          4'd5: begin 
            if( i > 600 ) begin
            instr_2 = instr_test.B_instr;
            end
            else begin
            instr_2 = instr_1;
            end
          end
          default: instr_2 = instr_test.R_instr;
        endcase
          $display (" INSTR 1 = %h  " , instr_1 );
          $display (" INSTR 2 = %h  " , instr_2 );
        instr_test.Instr_set[i] = instr_1;
        instr_test.Instr_set[i+1] = instr_2;
      //instr_test.display();
      //instr_test.display_I();
      //instr_test.display_S();
      //instr_test.display_L();
      //instr_test.display_B();
      //instr_test.display_U();
      //instr_test.display_J();
    end


    //if(file) begin
    for (int i = 0 ; i < 500 ; i++) begin 
 //    $display(" Instr randim %d : %h ", i , instr_test.Instr_set[i]); 
     $fwrite(file, "%h\n", instr_test.Instr_set[i]); 
  //  end
   // $fclose(file);
    end

    $display("num of counter_r    : %d", instr_test.counter_r    ) ;
    $display("num of counter_add  : %d", instr_test.counter_add  ) ;
    $display("num of counter_slt  : %d", instr_test.counter_slt  ) ;
    $display("num of counter_sub  : %d", instr_test.counter_sub  ) ;
    $display("num of counter_or   : %d", instr_test.counter_or   ) ;
    $display("num of counter_xor  : %d", instr_test.counter_xor  ) ;
    $display("num of counter_sltu : %d", instr_test.counter_sltu ) ;
    $display("num of counter_sra  : %d", instr_test.counter_sra  ) ;
    $display("num of counter_srl  : %d", instr_test.counter_srl  ) ;
    $display("num of counter_and  : %d", instr_test.counter_and  ) ;
    $display("num of counter_sll  : %d", instr_test.counter_sll  ) ;
    $display("num of counter_addi : %d", instr_test.counter_addi ) ;
    $display("num of counter_slti : %d", instr_test.counter_slti ) ;
    $display("num of counter_ori  : %d", instr_test.counter_ori  ) ;
    $display("num of counter_sltui: %d", instr_test.counter_sltui) ;
    $display("num of counter_xori : %d", instr_test.counter_xori ) ;
    $display("num of counter_srai : %d", instr_test.counter_srai ) ;
    $display("num of counter_srli : %d", instr_test.counter_srli ) ;
    $display("num of counter_andi : %d", instr_test.counter_andi ) ;
    $display("num of counter_slli : %d", instr_test.counter_slli ) ;
    $display("num of counter_lb   : %d", instr_test.counter_lb   ) ;
    $display("num of counter_lh   : %d", instr_test.counter_lh   ) ;
    $display("num of counter_lw   : %d", instr_test.counter_lw   ) ;
    $display("num of counter_sb   : %d", instr_test.counter_sb   ) ;
    $display("num of counter_sh   : %d", instr_test.counter_sh   ) ;
    $display("num of counter_sw   : %d", instr_test.counter_sw   ) ;
    $display("num of counter_jal  : %d", instr_test.counter_jal  ) ;
    $display("num of counter_jalr : %d", instr_test.counter_jalr ) ;
    $display("num of counter_bge  : %d", instr_test.counter_bge  ) ;
    $display("num of counter_bne  : %d", instr_test.counter_bne  ) ;
    $display("num of counter_beq  : %d", instr_test.counter_beq  ) ;
    $display("num of counter_blt  : %d", instr_test.counter_blt  ) ;
    $display("num of counter_bltu : %d", instr_test.counter_bltu ) ;
    $display("num of counter_bgeu : %d", instr_test.counter_bgeu ) ;
    $display("num of counter_lui  : %d", instr_test.counter_lui  ) ;
    $display("num of counter_auipc: %d", instr_test.counter_auipc) ;
    $display("num of all : %d",
 instr_test.counter_r    
+ instr_test.counter_add   
+ instr_test.counter_slt   
+ instr_test.counter_sub   
+ instr_test.counter_or    
+ instr_test.counter_xor   
+ instr_test.counter_sltu  
+ instr_test.counter_sra   
+ instr_test.counter_srl   
+ instr_test.counter_and   
+ instr_test.counter_sll   
+ instr_test.counter_addi  
+ instr_test.counter_slti  
+ instr_test.counter_ori   
+ instr_test.counter_sltui 
+ instr_test.counter_xori  
+ instr_test.counter_srai  
+ instr_test.counter_srli  
+ instr_test.counter_andi  
+ instr_test.counter_slli  
+ instr_test.counter_lb    
+ instr_test.counter_lh    
+ instr_test.counter_lw    
+ instr_test.counter_sb    
+ instr_test.counter_sh    
+ instr_test.counter_sw    
+ instr_test.counter_jal   
+ instr_test.counter_jalr  
+ instr_test.counter_bge   
+ instr_test.counter_bne   
+ instr_test.counter_beq   
+ instr_test.counter_blt   
+ instr_test.counter_bltu  
+ instr_test.counter_bgeu  
+ instr_test.counter_lui   
+ instr_test.counter_auipc 
  ) ;




  end

  endmodule


