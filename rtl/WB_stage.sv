module WB_stage #( parameter DATA_WIDTH = 32) (
    input             clk                 ,
    input             rst_n               ,
    input             WB_regwrite_i       ,
    input      [31:0] WB_pc_i             , 
    input      [31:0] WB_imm_i            ,
    input      [4:0 ] WB_rd_add_i         ,
    input      [31:0] DMEM_data_i         ,
    input      [31:0] WB_alu_result_i     ,
    input      [1:0 ] WB_sel_to_reg_i     ,
    input    pkg::rf_wd_sel_e WB_rf_wdata_sel_i,  
    output reg [4:0 ] WB_rd_add_o         ,
    output reg [31:0] WB_data_write_reg_o ,
    output  pkg::rf_wd_sel_e WB_rf_wdata_sel_o , 
    output reg        WB_regwrite_o       
  );
  import pkg::*;

    reg [31:0] pc;
		reg [1:0] WB_sel_to_reg;
		reg [31:1] WB_alu_result;
		reg [31:0] WB_imm;

    always @(posedge clk or negedge rst_n) begin
			if(~rst_n) begin
        WB_rd_add_o        <= 5'd0  ;
        WB_regwrite_o      <= 1'b0  ;
        pc                 <= 32'd0 ;
				WB_sel_to_reg      <= 1'b0  ;
				WB_alu_result      <= 32'd0 ;
				WB_imm             <= 32'd0 ;
        WB_rf_wdata_sel_o  <= RF_WD_EX;
		  end else begin
        WB_rd_add_o        <= WB_rd_add_i      ;
        WB_regwrite_o      <= WB_regwrite_i    ;
        pc                 <= WB_pc_i          ;
				WB_sel_to_reg      <= WB_sel_to_reg_i  ;
				WB_alu_result      <= WB_alu_result_i  ;
				WB_imm             <= WB_imm_i         ;
        WB_rf_wdata_sel_o  <= WB_rf_wdata_sel_i;
      end
	  end
    always @(*) begin
        if(WB_data_write_reg_o <= 32'd0) begin
			end else if(WB_sel_to_reg == 2'b00) begin
          WB_data_write_reg_o = pc + 32'd4        ;
			end else if(WB_sel_to_reg == 2'b01) begin
          WB_data_write_reg_o = WB_alu_result   ;
			end else if(WB_sel_to_reg == 2'b10) begin
          WB_data_write_reg_o = DMEM_data_i       ;
			end else begin
          WB_data_write_reg_o = WB_imm           ;
			end
		end

endmodule
