/*********************
**Author: Atahan Akar
**File Name: vDFFE.sv
**Title: Register with Load Enable Circuit
**Description: TBD
**********************/
module vDFFE #(
  parameter data_width = 16
  )
  (
    //INPUTS
    input logic [data_width - 1:0] in,
    input logic load,
    input logic clk,

    //OUTPUTS
    output logic [data_width - 1:0] out
  );

  logic[data_width - 1:0] vDFF_in;

  assign vDFF_in = load ? in : out;

  always_ff @ (posedge clk) begin
    out <= vDFF_in;
  end

endmodule
