module testbench();
  logic        clk            ;
  logic        rst_n          ;
  logic [31:0] boot_add       ;
  logic [31:0] Instr_in       ;
  logic [31:0] D_in           ;
  logic        irq_software_i ;
  logic        irq_timer_i    ;
  logic        irq_external_i ;
  logic [14:0] irq_fast_i     ;
  logic        irq_nm_i       ;      
  logic        debug_req_i    ;      
  logic        data_gnt_i     ;      
  logic        data_rvalid_i  ;      
  logic        data_rdata_i   ;      
  logic        data_err_i     ;      
  logic        instr_gnt_i    ;      
  logic        instr_rvalid_i ;      
  logic        instr_rdata_i  ;      
  logic        instr_err_i    ;      
  logic        instr_fetch_err_plus2_i;
  logic        mem_resp_intg_err_i;
  logic [31:0] A_DMEM         ;
  logic        instr_req      ;
  logic   data_req_o          ;
  logic [31:0] A_IMEM         ;
  logic [31:0] D_out          ;
  logic        RD             ;
  logic        WR             ;
  logic        irq_pending_o  ;
  logic        crash_dump_o   ;
  logic [3:0 ] byte_mark      ;
  logic        DMEM_rst       ;  
  logic        core_busy_o    ;  



 parameter boot_add_radix = 32'd0;
 	
 
  CPU_EDABK_TOP #( .DATA_WIDTH(32)) top (
     .clk                      ( clk                   )     
    ,.rst_n                    ( rst_n                 )  
    ,.boot_add                 ( boot_add              )   
    ,.Instr_in                 ( Instr_in              )    
    ,.D_in                     ( D_in                  )     
    ,.irq_software_i           ( irq_software_i        )        
    ,.irq_timer_i              ( irq_timer_i           )       
    ,.irq_external_i           ( irq_external_i        )      
    ,.irq_fast_i               ( irq_fast_i            )     
    ,.debug_req_i              ( debug_req_i           )          
    ,.irq_nm_i                 ( irq_nm_i              ) 
    ,.data_gnt_i               ( data_gnt_i            ) 
    ,.data_rvalid_i            ( data_rvalid_i         ) 
    ,.data_rdata_i             ( data_rdata_i          ) 
    ,.data_err_i               ( data_err_i            ) 
    ,.instr_gnt_i              ( instr_gnt_i           ) 
    ,.instr_rvalid_i           ( instr_rvalid_i        ) 
    ,.instr_rdata_i            ( instr_rdata_i         ) 
    ,.instr_err_i              ( instr_err_i           ) 
    ,.A_DMEM                   ( A_DMEM                ) 
    ,.instr_req                ( instr_req             ) 
    ,.data_req_o               ( data_req_o            ) 
    ,.A_IMEM                   ( A_IMEM                ) 
    ,.D_out                    ( D_out                 ) 
    ,.RD                       ( RD                    ) 
    ,.WR                       ( WR                    ) 
    ,.irq_pending_o            ( irq_pending_o         ) 
    ,.crash_dump_o             ( crash_dump_o          ) 
    ,.byte_mark                ( byte_mark             ) 
    ,.DMEM_rst                 ( DMEM_rst              ) 
    ,.core_busy_o              ( core_busy_o           ) 
    ,.instr_fetch_err_plus2_i  (instr_fetch_err_plus2_i)
    ,.mem_resp_intg_err_i      (mem_resp_intg_err_i    )
);

 DMEM #(.DATA_WIDTH(32)) ram (
    .clk       (clk       )
   ,.rst_n     (rst_n     )
   ,.RD        (RD        )
   ,.WR        (WR        )
   ,.data_in   (D_out     )
   ,.data_out  (D_in      )
   ,.addr      (A_DMEM    )
   ,.byte_en   (byte_mark )
);

 bind CPU_EDABK_TOP test_case check (
clk                    ,
rst_n                  ,
boot_add               ,
Instr_in               ,
D_in                   ,
irq_software_i         ,
irq_timer_i            ,
irq_external_i         ,
irq_fast_i             ,
debug_req_i            ,
irq_nm_i               ,
data_gnt_i             ,
data_rvalid_i          ,
data_rdata_i           ,
data_err_i             ,
instr_gnt_i            ,
instr_rvalid_i         ,
instr_rdata_i          ,
instr_err_i            ,
instr_fetch_err_plus2_i,
mem_resp_intg_err_i );
   
 wire [31:0] reg_file_2;
 assign reg_file_2 = top.id_stage.reg_file.reg_file[2];
 reg enable;
 wire [31:0] instr;
 assign instr = top.id_stage.ID_instr_i;
 wire [31:0] mem_34;
 wire [31:0] mem_35;
 wire [31:0] X_1;
 wire [31:0] X_10;
 wire [31:0] X_5;
 wire [31:0] X_4;
 wire [31:0] X_6;
 wire [31:0] X_7;
 wire [31:0] X_8;
 wire [31:0] X_9;
 wire [31:0] X_11;
 wire [31:0] X_12;
 wire [31:0] X_13;
 wire [31:0] X_14;
 wire [31:0] X_15;
 wire [31:0] X_16;
 wire [31:0] X_17;
 wire [31:0] X_18;
 wire [31:0] X_19;
 wire [31:0] X_20;
 wire [31:0] X_21;
 wire [31:0] X_22;
 wire [31:0] pc_next;
 assign pc_next = top.if_stage.pc_next;
 assign mem_34 = ram.mem[34];
 assign mem_35 = ram.mem[35];
 assign X_1 = top.id_stage.reg_file.reg_file[1];
 assign X_10 = top.id_stage.reg_file.reg_file[10];
 assign X_5 = top.id_stage.reg_file.reg_file[5];
 assign X_4 = top.id_stage.reg_file.reg_file[4];
 assign X_6 = top.id_stage.reg_file.reg_file[6];
 assign X_7 = top.id_stage.reg_file.reg_file[7];
 assign X_8 = top.id_stage.reg_file.reg_file[8];
 assign X_9 = top.id_stage.reg_file.reg_file[9];
 assign X_11 = top.id_stage.reg_file.reg_file[11];
 assign X_12 = top.id_stage.reg_file.reg_file[12];
 assign X_13 = top.id_stage.reg_file.reg_file[13];
 assign X_14 = top.id_stage.reg_file.reg_file[14];
 assign X_15 = top.id_stage.reg_file.reg_file[15];
 assign X_16 = top.id_stage.reg_file.reg_file[16];
 assign X_17 = top.id_stage.reg_file.reg_file[17];
 assign X_18 = top.id_stage.reg_file.reg_file[18];
 assign X_19 = top.id_stage.reg_file.reg_file[19];
 assign X_20 = top.id_stage.reg_file.reg_file[20];
 assign X_21 = top.id_stage.reg_file.reg_file[21];
 assign X_22 = top.id_stage.reg_file.reg_file[22];
 always @(instr) begin
 	if((instr[6:0] == 7'b1100011) & (instr[14:12] == 3'b001)) begin
	  $display("this is branch instruction %h", instr  );
	  $display("this is branch instruction IMM =  %d", top.id_stage.imm );

  end else 
 	if((instr[6:0] == 7'b0010011) & (instr[14:12] == 3'b000)) begin
	  $display("this is  ADDI  instruction %h", instr  );
#5
	  $display("this is ADDI instruction IMM =  %d", top.id_stage.imm );
 end
 end

		

 initial begin
 	$dumpfile("cpu.VCD");
	$dumpvars(0, testbench);
 end

 logic is_add_instr  ; assign is_add_instr  = (Instr_in[6:0] == 7'h33) && (Instr_in[14:12] == 3'b000) && (Instr_in[30] == 1'b0) ;

 initial begin
   if(is_add_instr) begin
     #20
     $display (" alu_result = %d", top.ex_stage.alu_result);
     #20
     $display (" data_write reg = %d", top.id_stage.data_write_reg);
   end
 end

  reg [31:0] IMEM [255:0 ];
  reg [31:0] DMEM [255:0];
	reg [31:0] REG_FILE [31:0];

  always #5 clk = ~clk;
  always @(A_IMEM) begin
    Instr_in = IMEM[A_IMEM >> 2];
  end

	// READ DATA MEMORY 
			
	integer i;
	initial begin
    #5
		for(i = 0; i < 32 ; i = i + 1) begin
			top.id_stage.reg_file.reg_file[i] = REG_FILE[i];
		end
	end
	integer k;

//	always (top.wb_stage.WB_regwrite_o) begin
//		if(top.wb_stage.WB_regwrite_o && 
//			top.id_stage.reg_file.reg_file[top.wb_stage.WB_rd_add_o] = 
//			top.wb_stage.WB_data_write_reg_o;

	initial begin
    #5
		for(k = 0; k < 256 ; k = k + 1) begin
			ram.mem[k] = DMEM[k];
		end
	end

//  always @(Instr_in) begin
//    $display("instr  %h" , Instr_in);
//  end
//  always @(pc_next) begin
//    $display("PC  %d" , pc_next);
//  end
integer j;

// print DMEM

`ifdef MEM
initial begin
  #800 // Đợi một thời gian ngắn để đảm bảo rằng các giá trị đã được khởi tạo
  $display("Values in dmem:");
  for (j = 0; j < 256; j = j + 1) begin
    $display("mem[%0d] = %h", j, ram.mem[j]);
  end
end
initial begin
  #10; // Đợi một thời gian ngắn để đảm bảo rằng các giá trị đã được khởi tạo
  $display("Values in reg_file:");
  for (j = 0; j < 32; j = j + 1) begin
    $display("reg_file[%0d] = %h", j, top.id_stage.reg_file.reg_file[j]);
  end
  #500; // Đợi một thời gian ngắn để đảm bảo rằng các giá trị đã được khởi tạo
  $display("Values in reg_file:");
  for (j = 0; j < 32; j = j + 1) begin
    $display("reg_file[%0d] = %h", j, top.id_stage.reg_file.reg_file[j]);
  end
end
`endif

  initial begin
    $readmemh("../init/test_1.dat", IMEM);
  end
  initial begin
    $readmemh("../init/dmem.dat", DMEM);
  end
  initial begin
    $readmemh("../init/reg_file_1.dat", REG_FILE);
  end
  wire [31:0] MEM_1 = IMEM[1];
  wire [31:0] A_MEM_1 = IMEM[1];

 initial begin 
   #5
     rst_n = 0;
     clk = 0;
     irq_software_i = 1'b0; 
     irq_timer_i    = 1'b0; 
     irq_external_i = 1'b0; 
     irq_fast_i     = 1'b0; 
     irq_nm_i       = 1'b0; 
     debug_req_i    = 1'b0; 
     data_gnt_i     = 1'b1; 
     data_rvalid_i  = 1'b1; 
     data_rdata_i   = 1'b1; 
     data_err_i     = 1'b0; 
     instr_gnt_i    = 1'b0; 
     instr_rvalid_i = 1'b1; 
     instr_rdata_i  = 1'b0; 
     instr_err_i    = 1'b0; 
     boot_add       = 32'd0;
     mem_resp_intg_err_i = 1'b0;

   #20 
   Instr_in = 32'd0;
   #5 

   rst_n = 1;
   #10 
    $display(" MEM_1  %h" , MEM_1);
    $display(" A_MEM_1  %h" , A_IMEM );
    $display("instr  %h" , Instr_in);
    $display("mem  %h" , ram.mem[2] );
    $display("mem  %h" , ram.mem[3] );
    $display("mem  %h" , ram.mem[4] );
    $display("mem  %h" , ram.mem[5] );
    $display("mem  %h" , ram.mem[6] );

 end
 initial begin
   #10000  $finish;
 end

  always @(testbench.top.check.is_add_instr) begin
    if(testbench.top.check.is_add_instr) begin
      $display (" ISSSSSS ADD INSTRUCTION");
    end
    else begin 
      $display (" NOT ISSSSSS ADDDD INSTRUCTION");
    end
  end

endmodule
