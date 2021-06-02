/*********************
**Author: Atahan Akar
**File Name: shifter.sv
**Title: Shifter operations
**Description: TBD
**********************/
module shifter #(
    data_width = 16
  )(
    // INPUTS
    input logic  [data_width - 1:0] in,
    input logic  [1:0] shift,
    // OUTPUTS
    output logic [data_width - 1:0] sout1
  );
  // Insert the code here

  always @(*) begin
    case(shift)
      2'b00:  sout1 = in;
      2'b01: begin
              sout1[data_width - 1:1] = in[data_width - 2:0];
              sout1[0]     = 1'b0;
             end
      2'b10: begin
              sout1[data_width - 2:0] = in[data_width - 1:1];
              sout1[data_width - 1]   = 1'b0;
             end
      2'b11: begin
              sout1[data_width - 2:0] = in[data_width - 1:1];
              sout1[data_width - 1]   = in[data_width - 1];
             end
      default: sout1 = sout1;
    endcase
  end

endmodule
