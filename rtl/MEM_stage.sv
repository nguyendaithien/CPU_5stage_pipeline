`include "defi.vh"
module MEM_stage #( parameter DATA_WIDTH = 32) (
    input             clk               ,
    input             rst_n             ,
    input      [31:0] DMEM_data_i       ,
    input      [31:0] WB_data_i         ,
    input      [3:0 ] MEM_mem_op_i      ,
    input      [31:0] MEM_alu_result_i  ,
    input      [31:0] MEM_rs2_data_i    ,
    input             forward           ,
    input             MEM_RD_mem_i      ,
    input             MEM_WR_mem_i      ,
    input      [4:0]  MEM_rd_add_i      ,
    input             MEM_regwrite_i    ,
    input      [1:0 ] MEM_sel_to_reg_i  ,
    input      [31:0] MEM_pc_i          ,
    input      [31:0] MEM_imm_i         ,
    input      pkg::rf_wd_sel_e MEM_rf_wdata_sel_i,  
    output reg [31:0] MEM_imm_o         ,
    output reg        MEM_regwrite_o    ,
    output reg [31:0] DMEM_add_o        ,
    output reg [3: 0] DMEM_byte_mark_o  ,
    output reg [31:0] DMEM_data_write_o ,
    output reg [31:0] MEM_data_o        ,
    output reg [31:0] MEM_alu_result_o  ,
    output reg [4:0 ] MEM_rd_add_o      ,
    output reg [1:0 ] MEM_sel_to_reg_o  ,
    output reg        MEM_RD_mem_o      ,
    output reg        MEM_WR_mem_o      ,
    output reg        DMEM_rst_o        ,
    output  pkg::rf_wd_sel_e MEM_rf_wdata_sel_o , 
    output reg [31:0] MEM_pc_o,          
    output logic load_err_o,
    output logic store_err_o,
    output logic [31:0] last_add_o
  );
  import pkg::*;

    reg [3:0 ] byte_mark   ;
    reg [31:0] data_write  ;
    reg [1:0 ] byte_addr   ;
    reg [3:0 ] mem_op      ;

   always@(posedge clk or negedge rst_n) begin
     if(~rst_n) begin
       MEM_sel_to_reg_o      <= 2'd0     ;
       MEM_alu_result_o      <= 32'd0    ;
       MEM_regwrite_o        <= 1'd0     ;
       MEM_rd_add_o          <= 5'd0     ;
       MEM_RD_mem_o          <= 1'd0     ;
       MEM_WR_mem_o          <= 1'd0     ;
       MEM_pc_o              <= 32'd0    ;
       MEM_imm_o             <= 32'd0    ;
       byte_mark             <= 4'd0     ;
       MEM_rf_wdata_sel_o    <= RF_WD_EX ;
       load_err_o            <= 1'b0     ;
       store_err_o           <= 1'b0     ;
       last_add_o            <= 32'd0    ;
     end else begin
       MEM_sel_to_reg_o      <= MEM_sel_to_reg_i  ;
       MEM_alu_result_o      <= MEM_alu_result_i  ;
       MEM_regwrite_o        <= MEM_regwrite_i    ;
       MEM_rd_add_o          <= MEM_rd_add_i      ;
       MEM_RD_mem_o          <= MEM_RD_mem_i      ;
       MEM_WR_mem_o          <= MEM_WR_mem_i      ;
       MEM_pc_o              <= MEM_pc_i          ;
       MEM_imm_o             <= MEM_imm_i         ;
       MEM_rf_wdata_sel_o    <= MEM_rf_wdata_sel_i;
       last_add_o            <= DMEM_add_o        ;
       end
     end


    always@* begin
     //   DMEM_add_o       = {MEM_alu_result_i[31:2], 2'b0}    ;
        DMEM_rst_o       = ~rst_n                            ;
        DMEM_byte_mark_o = (MEM_WR_mem_i) ? byte_mark : 4'b0 ;
    end
		always @(posedge clk or negedge rst_n) begin 
			if(~rst_n) begin
				DMEM_add_o <= 32'd0;
			end
			else begin
        DMEM_add_o      <= {MEM_alu_result_i[31:2], 2'b0}    ;
			end
		end
    
    always@* begin
        if(forward)
        data_write = MEM_alu_result_o ;
        else
        data_write = MEM_rs2_data_i   ;
    end

    always@* begin
        DMEM_data_write_o   = 32'b0 ;
        byte_mark           = 4'd0  ;

        case(MEM_mem_op_i)

            `MEM_SW: begin
                DMEM_data_write_o = data_write;
                byte_mark     = 4'b1111;
            end

            `MEM_SB: begin
                case(MEM_alu_result_i[1:0]) 
                    2'b00: begin
                        DMEM_data_write_o = { {24{1'b0}}, data_write[7:0] }; 
                        byte_mark = 4'b0001;
                    end
                    2'b01: begin
                        DMEM_data_write_o = { {16{1'b0}}, data_write[7:0],  { 8{1'b0}} };
                        byte_mark = 4'b0010;
                    end
                    2'b10: begin
                        DMEM_data_write_o = { {8{1'b0}},  data_write[7:0], {16{1'b0}} };
                        byte_mark = 4'b0100;
                    end
                    2'b11: begin
                       DMEM_data_write_o = { data_write[7:0], {24{1'b0}} };
                       byte_mark = 4'b1000;
                    end
                endcase
            end 

            `MEM_SH: begin
                case(MEM_alu_result_i[1:0])
                    2'b00: begin
                       DMEM_data_write_o = { {16{1'b0}}, data_write[15:0] };
                       byte_mark = 4'b0011;
                    end
                    2'b10: begin
                       DMEM_data_write_o = { data_write[15:0], {16{1'b0}} };
                       byte_mark = 4'b1100;
                    end
                    default: byte_mark = 4'd0;
                endcase 
            end   

        endcase
    end
    

    //*********************************    
    //        DATA MEM LOADS
    //*********************************

    // loads have a one clock latency 
    // need to flop: 1) memory operation and 2) byte address

    // flop mem_op and MEM_alu_result_i 
    always@(posedge clk) begin
        if(rst_n == 1'b0) begin
            mem_op    <= 4'd0;
            byte_addr <= 2'd0;
        end else begin
            mem_op    <= MEM_mem_op_i; 
            byte_addr <= MEM_alu_result_i[1:0];
        end         
    end

    // combinatorial logic to 'snipe' the bits we want
    always@* begin
        case(mem_op)
            `MEM_LB: begin
                case(byte_addr)
                    2'b00: MEM_data_o = { {24{DMEM_data_i[7 ]}},  DMEM_data_i[7 :0 ] }; 
                    2'b01: MEM_data_o = { {24{DMEM_data_i[15]}},  DMEM_data_i[15:8 ] }; 
                    2'b10: MEM_data_o = { {24{DMEM_data_i[23]}},  DMEM_data_i[23:16] }; 
                    2'b11: MEM_data_o = { {24{DMEM_data_i[31]}},  DMEM_data_i[31:24] }; 
                endcase
            end

            `MEM_LH: begin
                case(byte_addr[1])
                    0: MEM_data_o = { {16{DMEM_data_i[15]}}, DMEM_data_i[15:0 ] };
                    1: MEM_data_o = { {16{DMEM_data_i[31]}}, DMEM_data_i[31:16] };
                endcase
            end

            `MEM_LB_U: begin
                case(byte_addr)
                    2'b00: MEM_data_o = { {24{1'b0}}, DMEM_data_i[7 :0 ] }; 
                    2'b01: MEM_data_o = { {24{1'b0}}, DMEM_data_i[15:8 ] }; 
                    2'b10: MEM_data_o = { {24{1'b0}}, DMEM_data_i[23:16] }; 
                    2'b11: MEM_data_o = { {24{1'b0}}, DMEM_data_i[31:24] }; 
                endcase

            end
            `MEM_LH_U: begin
                case(byte_addr[1])
                    0: MEM_data_o = { {16{1'b0}}, DMEM_data_i[15:0 ] };
                    1: MEM_data_o = { {16{1'b0}}, DMEM_data_i[31:16] };
                endcase
            end

            `MEM_LW: begin
                MEM_data_o = DMEM_data_i;
            end

            default: MEM_data_o = DMEM_data_i;
        endcase
    end
    
endmodule

