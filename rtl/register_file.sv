module register_file #( parameter DATA_WIDTH = 32, NUM_REG = 32, ADD_WIDTH = 5)(
	,clk,
	,address_1
	,address_3
  ,address_2
	,data_write
	,reg_write
	,rst_n
	,read_data_1
	,read_data_2
);
  input                           clk         ;
  input                           rst_n       ;
  input [ADD_WIDTH-1:0]           address_1   ;
  input [ADD_WIDTH-1:0]           address_3   ;
  input [ADD_WIDTH-1:0]           address_2   ;
  input [DATA_WIDTH-1:0]          data_write  ;
  input                           reg_write   ;
  output wire [DATA_WIDTH - 1 :0 ]read_data_1 ;
  output wire [DATA_WIDTH - 1 :0 ]read_data_2 ;

	wire [4:0] sel_read_1;
	wire [4:0] sel_read_2;
	wire [4:0] sel_read_3;

	reg [31:0] reg_file [31:0];
// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    
    wire unused_reset = rst_n; // for ram32m synthesis
    


    assign read_data_1 = ((address_1 == address_3) &&
                         (address_3 != 0) &&
                         (reg_write))  
                         ? data_write : reg_file[address_1];
    
    assign read_data_2 = ((address_2 == address_3) &&
                         (address_3 != 0) &&
                         (reg_write))     
                         ? data_write : reg_file[address_2];

    integer i;

    initial begin
        for(i=0; i<31; i=i+1) begin
            reg_file[i] <= 0;
        end      
    end
    
    always@(posedge clk) begin
        if((reg_write) && (address_3 != 0)) begin
                reg_file[address_3] <= data_write;
        end 

    end 
    
endmodule
