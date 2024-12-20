module IF_stage #( parameter DATA_WIDTH = 32) (
    input              clk         ,
    input              rst_n       ,
    input              flush       ,
    input              stall       ,
    input              pc_sel      ,
    input pkg::pc_sel_e     IF_pc_sel_mux_i  , 
    input pkg::exc_pc_sel_e IF_exc_sel_i, 
    input      [31:0]  boot_addr_i    ,
    input      [31:0]  pc_dest     ,
    input      [31:0]  IMEM_data_i ,
    input      [31:0]  IF_instr_i  ,

    input             pc_set_i     ,
    input      [31:0] csr_mepc_i   ,
    input      [31:0] csr_depc_i   ,
    input      [31:0] csr_mtvec_i  ,


    output reg [31:0]  IF_pc_o     ,
    output reg [31:0]  IF_instr_o  ,
    output reg [31:0]  IMEM_add_o  ,

    output logic is_compressed_o,
    output logic illegal_instr_o,
    output logic IF_instr_fetch_err_o,
    output logic [15:0] IF_instr_compressed_o
  );
  import pkg::*;

  reg [DATA_WIDTH-1:0] pc_next;
  logic [31:0] Instr   ;
  logic [31:0] exc_add ;
  logic illegal_instr  ;
  logic is_compressed  ;

  assign illegal_instr_o = illegal_instr;
  assign is_compressed_o = is_compressed;
  assign Instr = IF_instr_i;

  always @(posedge clk) begin
    if(!rst_n) begin
      IMEM_add_o           <= 32'd0;
      IF_pc_o              <= 32'd0;
      IF_instr_fetch_err_o <= 1'b0 ;
    end
		else if(IF_pc_sel_mux_i == PC_EXC) begin
      IMEM_add_o <= exc_add;
    end
		else if(IF_pc_sel_mux_i == PC_DRET) begin
      IMEM_add_o <= csr_depc_i;
    end
		else if(IF_pc_sel_mux_i == PC_ERET) begin
      IMEM_add_o <= csr_mepc_i;
    end
		else if(IF_pc_sel_mux_i == PC_BP) begin
      IMEM_add_o <= { boot_addr_i[31:8], 8'h80 };
    end
    else begin
      IMEM_add_o <= pc_next;
      IF_pc_o    <=  (stall)? IF_pc_o : IMEM_add_o;
		end		
  end

  always @(*) begin
    exc_add = EXC_PC_EXC;
    if(IF_exc_sel_i == EXC_PC_EXC) begin
      exc_add = EXC_PC_EXC_ADDR; 
    end
    else if(IF_exc_sel_i == EXC_PC_IRQ) begin
      exc_add = EXC_PC_IRQ_ADDR; 
    end
    else if(IF_exc_sel_i == EXC_PC_DBD) begin
      exc_add = EXC_PC_DBD_ADDR; 
    end
    else begin
      exc_add = EXC_PC_DBD_EXC_ADDR; 
    end
  end


      
	 always @(posedge clk or posedge flush) begin
	 	 if(flush | ~pc_set_i) begin
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
       pc_next = (pc_set_i) ? IMEM_add_o + 32'd4 : IMEM_add_o;
     end
   end


   compressed_decoder  compress_decode(
      . clk_i            (clk                  )
     ,. rst_ni           (rst_n                )
     ,. valid_i          (1'b1                 )
     ,. instr_i          (IF_instr_i           )
     ,. instr_o          (                )
     ,. is_compressed_o  (is_compressed        )
     ,. illegal_instr_o  (illegal_instr        )
     ,.instr_compressed_o(IF_instr_compressed_o)
   );
endmodule
