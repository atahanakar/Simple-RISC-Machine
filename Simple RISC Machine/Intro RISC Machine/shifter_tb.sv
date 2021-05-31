// Testbench for shifter
/*
module shifter #(
    data_width = 16
  )(
    // INPUTS
    input logic  [data_width - 1:0] in,
    input logic  [1:0] shift,
    // OUTPUTS
    output logic [data_width - 1:0] sout1
  );
*/
module shifter_tb();
  parameter data_width = 16;

  reg [data_width - 1:0] in;
  reg [1:0] shift;

  wire [data_width - 1:0] sout1;

  shifter #(
    .data_width(data_width)
  )
  DUT(
    .in(in),
    .shift(shift),
    .sout1(sout1)
  );

  initial begin
    // Case #1 shift = 00
    shift = 2'b00;
    in = 16'b1111_0000_1100_1111;
    #20;
    if(sout1 == 16'b1111_0000_1100_1111)
      $display("Passed");
    else
      $display("Failed");

    // Case #2 shift = 01
    shift = 2'b01;
    #20;
    if(sout1 == 16'b1110_0001_1001_1110)
      $display("Passed");
    else
      $display("Failed");


    // Case #3 shift = 10
    shift = 2'b10;
    #20;
    if(sout1 == 16'b0111_1000_0110_0111)
      $display("Passed");
    else
      $display("Failed");

    // Case #4 shift = 11
    shift = 2'b11;
    #20;
    if(sout1 == 16'b1111_1000_0110_0111)
      $display("Passed");
    else
      $display("Failed");

    //Stop the simulation
    $stop(0);
  end

endmodule
