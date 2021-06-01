// Testbench for cpu
module cpu_tb();
  parameter data_width = 16;
  // INPUTS
  reg clk;
  reg reset;
  reg s;
  reg load;
  reg [data_width - 1:0] in;
  reg [data_width - 1:0] mdata;
  reg [7:0] PC;

  //OUTPUTS
  wire [data_width - 1:0] out;
  wire N;
  wire V;
  wire Z;
  wire w;

  cpu   #(
    .data_width(data_width)
  )
  DUT
  (
  // INPUTS
  .clk(clk),
  .reset(reset),
  .s(s),
  .load(load),
  .in(in),
  .mdata(mdata),
  .PC(PC),

  //OUTPUTS
  .out(out),
  .N(N),
  .V(V),
  .Z(Z),
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
    reset = 1;
    s = 0;
    load = 0;
    #10;

    //MOV R0, #7
    in = 16'b1101_0000_0000_0111;
    reset = 0;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #100;

    //MOV R1, #2
    in = 16'b1101_0001_0000_0010;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #50;

    //ADD R2, R1, R0, LSL#1
    in = 16'b1010000101001000;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #50;

    // MOV R2, R2
    in = 16'b1100_0000_0100_0010;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #50;

    // CMP R1, R2
    in = 16'b1010_1001_0000_0010;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #50;

    // CMP R2, R1
    in = 16'b1010_1010_0000_0001;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #50;

    // AND R0, R2, R1
    in = 16'b1011_0010_0000_0001;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #50;

    // MVN R0, R0
    in = 16'b1011_1000_0000_0000;
    s = 1;
    load = 1;
    #20;
    s = 0;
    #50;

    $stop(0);
  end


endmodule
