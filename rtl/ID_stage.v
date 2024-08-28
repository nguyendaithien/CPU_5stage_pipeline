module ID_stage #( parameter DATA_WIDTH = 32) (
   clk             
  ,rst_n           
  ,stall           
  ,flush           
  ,ID_instr_i      
  ,EX_ALU_result_i 
  ,EX_rd_add_i
  ,WB_data_i       
  ,WB_regwrite_i  
  ,WB_rd_add_i     
  ,ID_pc_i         
  ,ID_rs1_add_o    
  ,ID_rs2_add_o    
  ,ID_rd_add_o     
  ,ID_rs1_data_o   
  ,ID_rs2_data_o   
  ,ID_pc_o         
  ,ID_imm_o        
  ,ID_alu_op_o 
  ,ID_sel_to_reg_o 
  ,ID_regwrite_o  
  ,ID_mem_op_o     
  ,ID_jump_o    
  ,ID_sel_to_reg_o 
  ,ID_RD_en_o        
  ,ID_WR_en_o        
  ,ID_branch_o       
  ,ID_alu_sel1_o
  ,ID_alu_sel2_o
  ,ID_pc_sel_o
);

    input             clk             ;
    input             rst_n           ;
    input             stall           ;
    input             flush           ;
    input      [31:0] ID_instr_i      ;
    input      [31:0] EX_ALU_result_i ;
    input      [31:0] WB_data_i       ;
    input             WB_regwrite_i   ;
    input      [4: 0] WB_rd_add_i     ;
    input      [4: 0] EX_rd_add_i     ;
    input      [31:0] ID_pc_i         ;

    output reg [4:0 ] ID_rs1_add_o    ;
    output reg [4:0 ] ID_rs2_add_o    ;
    output reg [4:0 ] ID_rd_add_o     ;
    output reg [31:0] ID_rs1_data_o   ;
    output reg [31:0] ID_rs2_data_o   ;
    output reg [31:0] ID_pc_o         ;
    output reg [31:0] ID_imm_o        ;
    output reg [3:0 ] ID_alu_op_o     ;
    output reg [1:0 ] ID_sel_to_reg_o ;
    output reg [3:0 ] ID_mem_op_o     ;
    output reg [1:0 ] ID_alu_sel1_o   ;
    output reg [1:0 ] ID_alu_sel2_o   ;
    output reg        ID_regwrite_o   ;
    output reg        ID_jump_o       ;
    output reg        ID_RD_en_o      ;
    output reg        ID_WR_en_o      ;
    output reg        ID_branch_o     ;
    output reg        ID_pc_sel_o     ;

   reg [31:0] rs1_data_temp;
   reg [31:0] rs2_data_temp;

   wire             [31:0] match_1     ;
   wire             [31:0] match_2     ;
   wire             [4:0 ] rd_add      ;
   wire             [4:0 ] rs1_add     ;
   wire             [4:0 ] rs2_add     ;
   wire             [31:0] rs1_data    ;
   wire             [31:0] rs2_data    ;
   wire             [31:0] imm         ;
   wire             [3:0 ] mem_op      ;
   wire             [1:0 ] alu_sel1    ;
   wire             [1:0 ] alu_sel2    ;
   wire             [3:0 ] alu_op      ;
   wire                    pc_sel      ;
   wire             [31:0] instr       ;
   wire             [31:0] pc          ;
   wire                    EX_zero     ;
   wire             [1:0 ] sel_to_reg  ;
   wire                    jump        ;
   wire                    branch      ;
   wire                    EX_jump     ;
   wire                    EX_branch   ;
   wire                    mem_rd_en   ;
   wire                    mem_wr_en   ;

   wire             [4:0 ] address_1   ;
   wire             [4:0 ] address_3   ;
   wire             [4:0 ] address_2   ;
   wire                    reg_write   ;
   wire             [31:0] read_data_1 ;
   wire             [31:0] data_write  ;
   wire             [31:0] read_data_2 ;
   wire             [31:0] read_data_3 ;

   decoder #(.DATA_WIDTH(32)) decode (
        .instr_i      (ID_instr_i) 
       ,.pc_i         (pc        )
       ,.rd_add_o     (rd_add    )
       ,.rs1_add_o    (rs1_add   )
       ,.rs2_add_o    (rs2_add   )
       ,.rs1_data_o   (rs1_data  )
       ,.rs2_data_o   (rs2_data  )
       ,.imm_o        (imm       )
       ,.reg_write_o  (reg_write )
       ,.alu_sel1_o   (alu_sel1  )
       ,.alu_sel2_o   (alu_sel2  )
       ,.alu_op_o     (alu_op    )
       ,.pc_sel_o     (pc_sel    )
       ,.EX_zero_i    (EX_zero   )
       ,.sel_to_reg_o (sel_to_reg)
       ,.jump_o       (jump      )
       ,.branch_o     (branch    )
       ,.EX_jump_i    (EX_jump   )
       ,.EX_branch_i  (EX_branch )
       ,.mem_op_o     (mem_op    )
       ,.mem_rd_en_o  (mem_rd_en )
       ,.mem_wr_en_o  (mem_wr_en )
     );
    
    register_file #(.DATA_WIDTH(32), .NUM_REG(32), .ADD_WIDTH(5)) reg_file(
     .clk        (clk           )
    ,.address_1  (rs1_add       )
    ,.address_3  (WB_rd_add_i   )
    ,.address_2  (rs2_add       )
    ,.data_write (WB_data_i     )
    ,.reg_write  (WB_regwrite_i )
    ,.rst_n      (rst_n         )
    ,.read_data_1(read_data_1   )
    ,.read_data_2(read_data_2   )
    ,.read_data_3(read_data_3   )
    );

    always@(posedge clk) begin
        if(~rst_n) begin
            ID_rd_add_o        <= 0;
            ID_rs1_add_o       <= 0;
            ID_rs2_add_o       <= 0;
            ID_imm_o           <= 0;
        end
        else begin
            ID_rd_add_o        <= rd_add ;
            ID_rs1_add_o       <= rs1_add;
            ID_rs2_add_o       <= rs2_add;
            ID_imm_o           <= imm    ;
        end
    end
always@(posedge clk) begin
        if((~rst_n) | (flush)) begin
            ID_pc_o             <= 32'd0 ;
            ID_alu_sel1_o       <= 2'd0  ;
            ID_alu_sel2_o       <= 2'd0  ;
            ID_alu_op_o         <= 4'd0  ;
            ID_branch_o         <= 1'b0  ;
            ID_branch_o         <= 1'b0  ;
            ID_WR_en_o          <= 1'b0  ;
            ID_RD_en_o          <= 1'b0  ;
            ID_regwrite_o       <= 1'b0  ;
            ID_sel_to_reg_o     <= 2'd0  ;
            ID_jump_o           <= 1'b0  ;
            ID_mem_op_o         <= 4'd0  ;
						ID_pc_sel_o         <= 1'b0  ;
        end
        else begin
            if(stall) begin
                ID_pc_o         <= ID_pc_o         ;
                ID_alu_sel1_o   <= ID_alu_sel1_o   ;
                ID_alu_sel2_o   <= ID_alu_sel2_o   ;
                ID_alu_op_o     <= ID_alu_op_o     ;
                ID_branch_o     <= ID_branch_o     ;
                ID_branch_o     <= ID_branch_o     ;
                ID_sel_to_reg_o <= ID_sel_to_reg_o ;
                ID_mem_op_o     <= ID_mem_op_o     ;
                ID_jump_o       <= 1'b0            ;
                ID_RD_en_o      <= 1'b0            ;
                ID_WR_en_o      <= 1'b0            ;
                ID_regwrite_o   <= 1'b0            ;
					    	ID_pc_sel_o     <= 1'b0            ;
            end
            else begin
                ID_pc_o         <= ID_pc_i    ;
                ID_alu_sel1_o   <= alu_sel1   ;
                ID_alu_sel2_o   <= alu_sel2   ;
                ID_alu_op_o     <= alu_op     ;
                ID_branch_o     <= branch     ;
                ID_WR_en_o      <= mem_rd_en  ;
                ID_RD_en_o      <= mem_wr_en  ;
                ID_regwrite_o   <= reg_write  ;
                ID_sel_to_reg_o <= sel_to_reg ;
                ID_jump_o       <= jump       ;
                ID_mem_op_o     <= mem_op     ;
						    ID_pc_sel_o     <= pc_sel     ;
            end
        end  
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
          rs1_data_temp <= 32'd0;
          rs2_data_temp <= 32'd0;
        end
        else begin
          rs1_data_temp <= read_data_1;
          rs2_data_temp <= read_data_2;
        end
    end

    assign match_1 = (WB_rd_add_i == ID_rs1_add_o) & |ID_rs1_add_o;
    assign match_2 = (WB_rd_add_i == ID_rs2_add_o) & |ID_rs2_add_o;

    always@(*) begin
        ID_rs1_data_o = (match_1 && WB_regwrite_i) ? WB_data_i : read_data_1;
        ID_rs2_data_o = (match_2 && WB_regwrite_i) ? WB_data_i : read_data_2;
    end
    
endmodule
