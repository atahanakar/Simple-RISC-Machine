
// Testbench for cpu
module cpu_tb();
  parameter data_width = 16;
  // INPUTS
  reg clk;
  reg reset;
  reg [7:0] PC;

  //OUTPUTS
  wire [data_width - 1:0] out;
  wire N;
  wire V;
  wire Z;
  wire [8:0] mem_addr;
  wire w;

  cpu   #(
    .data_width(data_width),
    .filename("data.txt")
  )
  DUT
  (
  // INPUTS
  .clk(clk),
  .reset(reset),
  .PC(PC),

  //OUTPUTS
  .out(out),
  .N(N),
  .V(V),
  .Z(Z),
  .mem_addr(mem_addr),
  .w(w)
  );

  initial begin // Initialise the clk
    clk = 0; #5;
    forever begin // Forever loop
    clk = 1; #5;
    clk = 0; #5;
    end
  end

  initial begin
    // Reset

    #500;

    $stop(0);
  end


endmodule
