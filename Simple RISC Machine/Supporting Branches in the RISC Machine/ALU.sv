/*********************
**Author: Atahan Akar
**File Name: regfile.sv
**Title: ALU operations
**Description: TBD
**********************/

module ALU #(
  parameter data_width = 16
  )(
  // INPUTS
  input logic  [data_width - 1:0] Ain,
  input logic  [data_width - 1:0] Bin,
  input logic  [1:0]ALUop,

  // OUTPUTS
  output logic [data_width - 1:0] out,
  output logic Z,
  output logic N,
  output logic V
  );
  // Insert the code here

  // Main ALU Operations
  always @ (*) begin
    case(ALUop)
      2'b00: out = Ain + Bin;
      2'b01: out = Ain - Bin;
      2'b10: out = Ain & Bin;
      2'b11: out = ~Bin;
      default: out = out;
    endcase
  end

  // Z, N, V Flags
  assign Z = ({16{1'b0}} == out);
  assign N = out[15];
  assign V = (out[15] & Ain[15] & Bin[15] & (ALUop == 2'b00)) ||
             (out[15] & ~Ain[15] & Bin[15] & (ALUop == 2'b01));

endmodule
