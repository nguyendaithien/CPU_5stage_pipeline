module csr #(
  parameter int unsigned    Width      = 32,
  parameter bit             ShadowCopy = 1'b0,
  parameter bit [Width-1:0] ResetValue = '0
 ) (
  input  logic             clk,
  input  logic             rst_n,

  input  logic [Width-1:0] wr_data_i,
  input  logic             wr_en_i,
  output logic [Width-1:0] rd_data_o,

  output logic             rd_error_o
);

  logic [Width-1:0] rdata_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rdata_q <= ResetValue;
    end else if (wr_en_i) begin
      rdata_q <= wr_data_i;
    end
  end

  assign rd_data_o = rdata_q;

  if (ShadowCopy) begin : gen_shadow
    logic [Width-1:0] shadow_q;

    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        shadow_q <= ~ResetValue;
      end else if (wr_en_i) begin
        shadow_q <= ~wr_data_i;
      end
    end

    assign rd_error_o = rdata_q != ~shadow_q;

  end else begin : gen_no_shadow
    assign rd_error_o = 1'b0;
  end


endmodule
