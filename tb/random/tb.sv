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
    for (int i = 0; i < 800 ; i = i+ 2) begin
    instr_test.randomize();
      assert(instr_test.randomize())
      R_instr = {instr_test.instr.funct7,instr_test.instr.rs2, instr_test.instr.rs1,instr_test.instr.funct3, instr_test.instr.rd, instr_test.instr.opcode};
      instr_test.counter_R(instr_test);
      instr_test.counter_L(instr_test);
      instr_test.assembly_R( instr_test);
      instr_test.assembly_I( instr_test);
      instr_test.assembly_S( instr_test);
      instr_test.assembly_L( instr_test);
      instr_test.assembly_B( instr_test);
      instr_test.assembly_U( instr_test);
      instr_test.assembly_J( instr_test);

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
    $display(" NUM OF R TYPE : %d", instr_test.counter_r);
    $display(" NUM OF ADD : %d", instr_test.counter_add);
    $display(" NUM OF SUB : %d", instr_test.counter_sub);
    $display(" NUM OF AND : %d", instr_test.counter_and);
    $display(" NUM OF OR : %d", instr_test.counter_or);
    $display(" NUM OF SLL : %d", instr_test.counter_sll);
    $display(" NUM OF XOR : %d", instr_test.counter_xor);
    $display(" NUM OF SLT : %d", instr_test.counter_slt);
    $display(" NUM OF LB : %d", instr_test.counter_lb);
    $display(" NUM OF LH : %d", instr_test.counter_lh);
    $display(" NUM OF LW : %d", instr_test.counter_lw);
  end

  endmodule


