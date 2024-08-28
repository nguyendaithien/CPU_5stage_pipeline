module IF_stage #( parameter DATA_WIDTH = 32) (
    clk         ,
    rst_n       ,
    IF_instr_i  ,
    flush       ,
    pc_dest     ,
    IMEM_data_i ,
    stall       ,
    pc_sel      ,
    IF_pc_o     ,
    IF_instr_o  ,
    IMEM_add_o  ,
    boot_add
  );
    input             clk         ;
    input             rst_n       ;
    input             flush       ;
    input             stall       ;
    input             pc_sel      ;
    input      [31:0] boot_add    ;
    input      [31:0] pc_dest     ;
    input      [31:0] IMEM_data_i ;
    input      [31:0] IF_instr_i  ;
    output reg [31:0] IF_pc_o     ;
    output reg [31:0] IF_instr_o  ;
    output reg [31:0] IMEM_add_o  ;

    reg [DATA_WIDTH-1:0] pc_next;

    always @(posedge clk) begin
        if(!rst_n) begin
            IMEM_add_o <= 32'd0;
            IF_pc_o    <= 32'd0;
        end
        else begin
            IMEM_add_o <= pc_next;
            IF_pc_o    <=  (stall)? IF_pc_o : IMEM_add_o;
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

     always @(*) begin
       if(flush) begin
          IF_instr_o = 32'd0;
       end 
			 else begin
         IF_instr_o = IMEM_data_i;
       end
     end
endmodule
