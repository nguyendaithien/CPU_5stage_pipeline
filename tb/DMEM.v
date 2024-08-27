module DMEM #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 8) (
    input wire                  clk,
    input wire                  rst_n,
    input wire                  RD,
    input wire                  WR,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [3:0]            byte_en // Byte enable
);

    reg [DATA_WIDTH-1:0] mem [255:0]; // RAM storage

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 32'b0;
        end else if (WR) begin
            case (byte_en)
                4'b1111: begin
                    mem[addr >> 2] <= data_in;
                end
                4'b0001: begin
                    mem[addr >> 2][7:0] <= data_in[7:0];
                end
                4'b0010: begin
                    mem[addr >> 2][15:8] <= data_in[7:0];
                end
                4'b0100: begin
                    mem[addr >> 2][23:16] <= data_in[7:0];
                end
                4'b1000: begin
                    mem[addr >> 2][31:24] <= data_in[7:0];
                end
                4'b0011: begin
                    mem[addr >> 2][15:0] <= data_in[15:0];
                end
                4'b1100: begin
                    mem[addr >> 2][31:16] <= data_in[15:0];
                end
                default: begin /* */ end
            endcase
        end else if (RD) begin
            data_out <= mem[addr >> 2];
        end
    end
endmodule

