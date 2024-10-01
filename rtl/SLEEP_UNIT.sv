module SLEEP_UNIT (
   clk_i
  ,rst_n
  ,core_sleep_i
  ,clk_gated_o
  );

  input logic clk_i;
  input logic rst_n;
  input logic core_sleep_i;
  output logic clk_gated_o;

  always @(posedge clk_i or rst_n) begin
    if(~rst_n) begin
      clk_gated_o <= 1'b0;
    end else if(core_sleep_i) begin
    clk_gated_o <= ~core_sleep_i;
    end else begin
      clk_gated_o <= clk_i;
    end
  end 

endmodule

    
