module testbench();
  reg          clk       ;
  reg          rst_n     ;
  wire         RD        ;
  wire         WR        ;
  wire  [31:0] A_DMEM    ;
  wire  [31:0] A_IMEM    ;
  reg   [31:0] Instr_in  ;
  wire   [31:0] D_in      ;
  wire  [31:0] D_out     ;
  wire         DMEM_rst  ;
  wire  [3:0 ] byte_mark ;
  reg   [31:0] boot_add  ;

 parameter boot_add_radix = 32'd0;
 	
 
  CPU_EDABK_TOP #( .DATA_WIDTH(32)) top (
   .clk        (clk             )     
  ,.rst_n      (rst_n           )  
  ,.RD         (RD              )   
  ,.WR         (WR              )    
  ,.A_DMEM     (A_DMEM          )     
  ,.A_IMEM     (A_IMEM          )        
  ,.Instr_in   (Instr_in        )       
  ,.D_in       (D_in            )      
  ,.D_out      (D_out           )     
  ,.DMEM_rst   (DMEM_rst        )        
  ,.byte_mark  (byte_mark       )          
  ,.boot_add   (boot_add_radix  ) 
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
   
 wire [31:0] reg_file_2;
 assign reg_file_2 = top.id_stage.reg_file.reg_file[2];
 reg enable;

 initial begin
 	$dumpfile("cpu.VCD");
	$dumpvars(0, testbench);
 end
  reg [31:0] IMEM [99:0 ];
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

  always @(Instr_in) begin
    $display("instr  %h" , Instr_in);
  end
integer j;

// print DMEM
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

  initial begin
    $readmemh("../init/test_1.dat", IMEM);
  end
  initial begin
    $readmemh("../init/dmem.dat", DMEM);
  end
  initial begin
    $readmemh("../init/reg_file_1.dat", REG_FILE);
  end
 initial begin 
   #20 
   Instr_in = 32'd0;
   rst_n = 0;
   clk = 0;
   #5 
   rst_n = 1;
   #10 
    $display("instr  %h" , Instr_in);
   #50 
    $display("instr in  0 %h" , IMEM[0]);
    $display("instr in  1 %h" , IMEM[1]);
    $display("instr  %h" , Instr_in);


 end
 initial begin
   #10000  $finish;
 end


endmodule
