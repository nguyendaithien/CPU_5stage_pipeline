module IF_stage #( parameter DATA_WIDTH = 32) (
    input              clk         ,
    input              rst_n       ,
    input              flush       ,
    input              stall       ,
    input              pc_sel      ,
    input pc_sel_e     pc_sel_mx   , 
    input exc_pc_sel_e exc_pc_sel_e, 
    input      [31:0]  boot_add    ,
    input      [31:0]  pc_dest     ,
    input      [31:0]  IMEM_data_i ,
    input      [31:0]  IF_instr_i  ,
    output reg [31:0]  IF_pc_o     ,
    output reg [31:0]  IF_instr_o  ,
    output reg [31:0]  IMEM_add_o  ,

    output logic is_compressed_o,
    output logic illegal_instr_o
  );
  import package::*;

    reg [DATA_WIDTH-1:0] pc_next;
    logic [31:0] Instr;

  always @(posedge clk) begin
    if(!rst_n) begin
      IMEM_add_o <= 32'd0;
      IF_pc_o    <= 32'd0;
    end
		else if(pc_mux_i == PC_EXC) begin
      IMEM_add_o <= PC_EXC_ADDR;
    end
		else if(pc_mux_i == PC_DRET) begin
      IMEM_add_o <= PC_DRET_ADDR;
    end
		else if(pc_mux_i == PC_ERET) begin
      IMEM_add_o <= PC_ERET_ADDR;
    end
		else if(pc_mux_i == PC_BP) begin
      IMEM_add_o <= PC_BP_ADDR;
    end
    else begin
      IMEM_add_o <= pc_next;
      IF_pc_o    <=  (stall)? IF_pc_o : IMEM_add_o;
		end		
  end

  always @(*) begin
    if(
	 always @(posedge clk or posedge flush) begin
	 	 if(flush) begin
       IF_instr_o <= 32'd0;
		 end
		 else begin
       IF_instr_o <= Instr;
		 end
	 end
   always @(*) begin
     if(stall) begin
        pc_next = IMEM_add_o - 32'd4;
     end
     else if(pc_sel == 1'b1) begin
       pc_next = pc_dest;
     end
     else begin
       pc_next = IMEM_add_o + 32'd4;
     end
   end


   compressed_decoder  compress_decode(
      . clk_i          (clk           )
     ,. rst_ni         (rst_n         )
     ,. valid_i        (1'b1          )
     ,. instr_i        (IF_instr_i    )
     ,. instr_o        (Instr         )
     ,. is_compressed_o(is_compressed )
     ,. illegal_instr_o(illegal_instr )
   );
endmodule

 






