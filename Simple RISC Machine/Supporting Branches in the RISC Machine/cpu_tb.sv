
// Testbench for cpu
module cpu_tb();
  parameter data_width = 16;
  // INPUTS
  reg clk;
  reg reset;
  reg [7:0] SW;

  //OUTPUTS
  wire [data_width - 1:0] out;
  wire [7:0] LEDR;
  wire [8:0] PC;
  wire N;
  wire V;
  wire Z;
  wire [8:0] mem_addr;
  wire [1:0] mem_cmd;
  wire w;

  cpu   #(
    .data_width(data_width),
    .filename("test3.txt")
  )
  DUT
  (
  // INPUTS
  .clk(clk),
  .reset(reset),
  .SW(SW),

  //OUTPUTS
  .out(out),
  .w(w),
  .LEDR(LEDR)
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
    SW = 8'b00011011;
    #3000;

    $stop(0);
  end


endmodule
