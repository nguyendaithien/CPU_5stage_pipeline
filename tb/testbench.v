module testbench();
  reg          clk       ;
  reg          rst_n     ;
  wire         RD        ;
  wire         WR        ;
  wire  [31:0] A_DMEM    ;
  wire         A_IMEM    ;
  reg  [31:0] Instr_in  ;
  wire  [31:0] D_in      ;
  wire  [31:0] D_out     ;
  wire         DMEM_rst  ;
  wire  [3:0 ] byte_mark ;
  reg          boot_add  ;

 CPU_EDABK_TOP #( .DATA_WIDTH(32)) top (
   .clk        (clk        )     
  ,.rst_n      (rst_n      )  
  ,.RD         (RD         )   
  ,.WR         (WR         )    
  ,.A_DMEM     (A_DMEM     )     
  ,.A_IMEM     (A_IMEM     )        
  ,.Instr_in   (Instr_in   )       
  ,.D_in       (D_in       )      
  ,.D_out      (D_out      )     
  ,.DMEM_rst   (DMEM_rst   )        
  ,.byte_mark  (byte_mark  )          
  ,.boot_add   (boot_add   ) 
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
   
  reg [31:0] IMEM [99:0 ];
  reg [31:0] DMEM [255:0];

  always #5 clk = ~clk;
  always @(A_IMEM) begin
    Instr_in = IMEM[A_IMEM >> 2];
  end
  always @(Instr_in) begin
    $display("instr  %h" , Instr_in);
  end

  initial begin
    $readmemh("../init/test_1.dat", IMEM);
  end
 initial begin 
   #2 
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
   #1000  $finish;
 end


endmodule
