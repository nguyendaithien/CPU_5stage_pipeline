module WB_stage #( parameter DATA_WIDTH = 32) (
   clk
  ,rst_n
  ,WB_rd_add_i
  ,DMEM_data_i
  ,WB_alu_result_i
  ,WB_sel_to_reg_i
  ,WB_regwrite_i
  ,WB_pc_i
  ,WB_imm_i
  ,WB_rd_add_o
  ,WB_data_write_reg_o
  ,WB_regwrite_o
  );
    input             clk                 ;
    input             rst_n               ;
    input             WB_regwrite_i       ;
    input      [31:0] WB_pc_i             ; 
    input      [31:0] WB_imm_i            ;
    input      [4:0 ] WB_rd_add_i         ;
    input      [31:0] DMEM_data_i         ;
    input      [31:0] WB_alu_result_i     ;
    input      [1:0 ] WB_sel_to_reg_i     ;
    output reg [4:0 ] WB_rd_add_o         ;
    output reg [31:0] WB_data_write_reg_o ;
    output reg        WB_regwrite_o       ;

    reg [31:0] pc;

    always@* begin
        WB_rd_add_o        = WB_rd_add_i   ;
        WB_regwrite_o      = WB_regwrite_i ;
        pc                 = WB_pc_i       ;
        
    end
    always @* begin
         case(WB_sel_to_reg_i)
            2'b00: WB_data_write_reg_o = pc + 32'd4      ;
            2'b01: WB_data_write_reg_o = WB_alu_result_i ;
            2'b10: WB_data_write_reg_o = DMEM_data_i     ;
         default:
            WB_data_write_reg_o = (WB_imm_i << 12)       ;
         endcase
    end

endmodule
