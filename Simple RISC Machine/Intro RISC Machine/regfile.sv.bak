/*********************
**Author: Atahan Akar
**File Name: regfile.sv
**Title: Simple RISC Machine
**Description: TBD
**********************/

module regfile #(
  parameter data_width = 16
  )(
  // INPUTS
  input logic[data_width - 1:0]  data_in,
  input logic[2:0]   writenum,
  input logic        write,
  input logic[2:0]   readnum,
  input logic        clk,

  //OUTPUTS
  output logic[data_width - 1:0] data_out
 );

 // 3 : 8 decoder
 logic [7:0] decoded_writenum = (2 ^ writenum);
 logic [7:0] decoded_readnum  = (2 ^ readnum);

 // ANDed writenum with write signal
 logic [7:0] anded_writenum; // also register_in

 generate
   for(genvar i = 0; i < 8; i = i + 1)begin
     assign anded_writenum[i] = decoded_writenum[i] & write;
   end
 endgenerate

// vDFFE for 8 registers
logic[data_width * 8 - 1:0] register_out;
  generate
    for(genvar i = 0; i < 8; i = i + 1) begin
        vDFFE #(
            .data_width(data_width)
          )
          R
          (
            .clk(clk),
            .in(data_in),
            .load(anded_writenum[i]),
            .out(register_out[data_width * (i + 1) - 1: data_width * i])
          );
        end
  endgenerate

// Data Out logic
  always_comb @(*) begin
    case(readnum)
      3'b000: data_out = register_out[15:0];
      3'b001: data_out = register_out[31:16];
      3'b010: data_out = register_out[47:32];
      3'b011: data_out = register_out[63:48];
      3'b100: data_out = register_out[79:64];
      3'b101: data_out = register_out[95:80];
      3'b110: data_out = register_out[111:96];
      3'b111: data_out = register_out[127:112];
      default: data_out = data_out;
    endcase
  end
//assign data_out = register_out[data_width * (readnum + 4'b1) - 1: data_width * readnum];

endmodule
