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
	,read_data_3
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
  output wire [DATA_WIDTH - 1 :0 ]read_data_3 ;

	wire [4:0] sel_read_1;
	wire [4:0] sel_read_2;
	wire [4:0] sel_read_3;

	reg [31:0] reg_file [31:0];

	assign read_data_1 = reg_file[address_1];
	assign read_data_2 = reg_file[address_2];
	assign read_data_3 = reg_file[address_3];

	always @(posedge clk or negedge rst_n) begin
		if( ~rst_n ) begin
			reg_file[0]  = 31'd0; 
			reg_file[1]  = 31'd0; 
			reg_file[2]  = 31'd0; 
			reg_file[3]  = 31'd0; 
			reg_file[4]  = 31'd0; 
			reg_file[5]  = 31'd0; 
			reg_file[6]  = 31'd0; 
			reg_file[7]  = 31'd0; 
			reg_file[8]  = 31'd0; 
			reg_file[9]  = 31'd0; 
			reg_file[10] = 31'd0; 
			reg_file[11] = 31'd0; 
			reg_file[12] = 31'd0; 
			reg_file[13] = 31'd0; 
			reg_file[14] = 31'd0; 
			reg_file[15] = 31'd0; 
			reg_file[16] = 31'd0; 
			reg_file[17] = 31'd0; 
			reg_file[18] = 31'd0; 
			reg_file[19] = 31'd0; 
			reg_file[20] = 31'd0; 
			reg_file[21] = 31'd0; 
			reg_file[22] = 31'd0; 
			reg_file[23] = 31'd0; 
			reg_file[24] = 31'd0; 
			reg_file[25] = 31'd0; 
			reg_file[26] = 31'd0; 
			reg_file[27] = 31'd0; 
			reg_file[28] = 31'd0; 
			reg_file[29] = 31'd0; 
			reg_file[30] = 31'd0; 
			reg_file[31] = 31'd0; 
		end
		else if(reg_write) begin
			reg_file[address_1] = data_write;
		end
		else begin 
			reg_file[0 ] = reg_file[0 ];  
			reg_file[1 ] = reg_file[1 ];
			reg_file[2 ] = reg_file[2 ];
			reg_file[3 ] = reg_file[3 ];
			reg_file[4 ] = reg_file[4 ];
			reg_file[5 ] = reg_file[5 ];
			reg_file[6 ] = reg_file[6 ];
			reg_file[7 ] = reg_file[7 ];
			reg_file[8 ] = reg_file[8 ];
			reg_file[9 ] = reg_file[9 ];
			reg_file[10] = reg_file[10];
			reg_file[11] = reg_file[11];
			reg_file[12] = reg_file[12];
			reg_file[13] = reg_file[13];
			reg_file[14] = reg_file[14];
			reg_file[15] = reg_file[15];
			reg_file[16] = reg_file[16];
			reg_file[17] = reg_file[17];
			reg_file[18] = reg_file[18];
			reg_file[19] = reg_file[19];
			reg_file[20] = reg_file[20];
			reg_file[21] = reg_file[21];
			reg_file[22] = reg_file[22];
			reg_file[23] = reg_file[23];
			reg_file[24] = reg_file[24];
			reg_file[25] = reg_file[25];
			reg_file[26] = reg_file[26];
			reg_file[27] = reg_file[27];
			reg_file[28] = reg_file[28];
			reg_file[29] = reg_file[29];
			reg_file[30] = reg_file[30];
			reg_file[31] = reg_file[31];
		end
	end
endmodule
			
			
