`include "defi.vh"
module CONTROL_HAZARD #( parameter DATA_WIDTH = 32) (
   clk
  ,rst_n
  ,stall_o
  ,IF_ID_flush_o
  ,EX_flush_o
  ,hazard
  ,forward_A_o 
  ,forward_B_o
  ,forward_dmem
  ,ID_RD_mem_i // check load instruction
  ,ID_rs1_add_i
  ,ID_rs2_add_i
  ,ID_rd_add_i
  ,EX_rs1_add_i
  ,EX_rs2_add_i
  ,EX_rd_add_i
  ,MEM_rd_add_i
  ,EX_regwrite_i
  ,MEM_regwrite_i
  ,IF_instr_i
  ,ID_jump
  ,zero
 );

   input             clk             ;
   input             rst_n           ;
   output reg        stall_o         ;
   output wire       IF_ID_flush_o   ;
   output reg        EX_flush_o      ;
   output reg [1:0 ] forward_A_o     ;
   output reg [1:0 ] forward_B_o     ;
   output reg        forward_dmem    ;
   output reg        hazard          ;
   input             ID_RD_mem_i     ;
   input      [4:0 ] ID_rs1_add_i    ;
   input      [4:0 ] ID_rs2_add_i    ;
   input      [4:0 ] ID_rd_add_i     ;
   input      [4:0 ] EX_rs1_add_i    ;
   input      [4:0 ] EX_rs2_add_i    ;
   input      [4:0 ] EX_rd_add_i     ;
   input      [4:0 ] MEM_rd_add_i    ;
   input             EX_regwrite_i   ;
   input             MEM_regwrite_i  ;
   input      [31:0] IF_instr_i      ;
   input             ID_jump         ;
   input             zero            ;

    reg [6:0] opcode; 
    reg IF_ID_flush1; 
    reg IF_ID_flush2; 

     // EX HAZARD
   always@* begin
     if ( (EX_regwrite_i == 1'b1) && (EX_rd_add_i != 0 ) && (EX_rd_add_i == ID_rs1_add_i)) begin
         forward_A_o = 2'b01; 
         hazard = 1'b1;
     end 
     // WB hazard -> forward from WB_Rd_data to op1 
     else if ( (MEM_regwrite_i == 1'b1) && (MEM_rd_add_i != 0 ) && ~( (EX_regwrite_i  == 1'b1) && (EX_rd_add_i != 0) && (EX_rd_add_i == ID_rs1_add_i)) && (MEM_rd_add_i == ID_rs1_add_i)) begin
       forward_A_o = 2'b00; 
       hazard = 1'b1;
     end
     else begin
       forward_A_o = 2'b00;              
       hazard = 1'b0;
     end
  end
    
    always@* begin // EX HAZARD -> forward from EX_ALU_result to op2
        if ( (EX_regwrite_i == 1'b1) && (EX_rd_add_i != 0) && (EX_rd_add_i  == ID_rs2_add_i)) begin
          forward_B_o = 2'b01;
          hazard = 1'b1;
        end
         // WB hazard -> forward from WB_Rd_data to op2
        else if ( (MEM_regwrite_i == 1'b1) && (MEM_rd_add_i != 0) &&  ~ ( (EX_regwrite_i  == 1'b1) && (EX_rd_add_i != 0) && (EX_rd_add_i == ID_rs2_add_i)) && (MEM_rd_add_i == ID_rs2_add_i)) begin 
          forward_B_o = 2'b00;
          hazard = 1'b1;
        end
        else begin
          forward_B_o = 2'b00;         
          hazard = 1'b0;
        end
    end

//  Memory write forwarding:
//  1) no forwarding, write value of rs2 to data mem
//  2) forward data from prior MEM stage output 

    always@* begin
      if ((MEM_regwrite_i == 1'b1) && (EX_rs2_add_i == MEM_rd_add_i) && (MEM_rd_add_i != 0)) begin
          forward_dmem = 1'b1; // forward from MEM_ALU_result
      end
      else begin
          forward_dmem = 1'b0;
      end
    end

    always @* begin
        opcode = IF_instr_i[6:0] ;
    end

    always@* begin
        if(ID_RD_mem_i == 1'b1) begin
            if( ( (opcode == `OPCODE_OP) || (opcode == `OPCODE_BRANCH) || (opcode == `OPCODE_STORE) ) && ( (ID_rd_add_i == IF_instr_i[19:15]) || (ID_rd_add_i == IF_instr_i[24:20]) ))     
            begin
                stall_o = 1'b1;
            end 
            else if( ( (opcode == `OPCODE_OP_IMM) ||(opcode == `OPCODE_LOAD) ) && ( (ID_rd_add_i == IF_instr_i[19:15]) )) begin
                stall_o = 1'b1;
            end     
            else begin 
              stall_o = 1'b0;   
            end
        end
        else begin 
          stall_o = 1'b0;
        end
    end

    assign IF_ID_flush_o = (IF_ID_flush1 || IF_ID_flush2);
//    assign IF_ID_flush_o = (IF_ID_flush1);
      

    always@* begin
      if((zero) || (ID_jump)) begin 
          IF_ID_flush1 = 1'b1;
      end
      else begin                                      
          IF_ID_flush1 = 1'b0;
      end
    end
    
    always@(posedge clk) begin
      if(!rst_n) begin
          IF_ID_flush2 <= 1'b0;
					hazard       <= 1'b0;
      end
      else begin                 
          IF_ID_flush2 <= IF_ID_flush1;
      end
    end

    // flush EX if a branch is taken
    always@* begin
      EX_flush_o = (zero) ? 1'b1 : 1'b0 ;
    end

endmodule

   
