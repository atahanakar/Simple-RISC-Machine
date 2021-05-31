// Testbench for datapath_in

module datapath_tb();
  parameter data_width = 16;
  // INPUTS
  reg [data_width - 1:0] datapath_in;
  reg [2:0] writenum;
  reg [2:0] readnum;
  // ALU and Shift operations
  reg [2:0] ALUop;
  reg [2:0] shift;

  reg write;
  reg clk;
  // Load signals
  reg loada;
  reg loadb;
  reg loadc;
  reg loads;

  //Mux select signals
  reg asel;
  reg bsel;
  reg vsel;

  // OUTPUTS
  wire [data_width - 1:0] datapath_out;

  // Flag Outputs
  wire Z_out;  // Zero Flag

  // Device Under Test
  datapath #(
    .data_width(data_width)
  )
  DUT(
  .datapath_in(datapath_in),
  .writenum(writenum),
  .readnum(readnum),
  // ALU and Shift operations
  .ALUop(ALUop),
  .shift(shift),

  .write(write),
  .clk(clk),
  // Load signals
  .loada(loada),
  .loadb(loadb),
  .loadc(loadc),
  .loads(loads),

  //Mux select signals
  .asel(asel),
  .bsel(bsel),
  .vsel(vsel),

  // OUTPUTS
  .datapath_out(datapath_out),

  // Flag Outputs
  .Z_out(Z_out)  // Zero Flag
  );

  initial begin // Initialise the clk
    clk = 0; #5;
    forever begin // Forever loop
    clk = 1; #5;
    clk = 0; #5;
    end
  end

  initial begin
    // Test case
    /*
    MOV R0, #7 ; this means, take the absolute number 7 and store it in R0
    MOV R1, #2 ; this means, take the absolute number 2 and store it in R1
    ADD R2, R1, R0, LSL#1 ; this means R2 = R1 + (R0 shifted left by 1) = 2+14=16
    */
    // Register 0 should contain 7
    datapath_in = 7;
    writenum = 0;
    vsel = 1;
    write = 1;
    #10;

    // Register 1 should contain 2
    datapath_in = 2;
    writenum = 1;
    vsel = 1;
    write = 1;
    #10;

    // Store R0 to B
    readnum = 0;
    write = 0;
    loadb = 1;
    #10;

    // Store R1 to A
    readnum = 1;
    loadb = 0;
    loada = 1;
    #10;

    // Give the outputs
    asel = 0;
    bsel = 0;
    shift = 2'b01;
    ALUop = 2'b00;
    loada = 0;
    loadc = 1;
    loads = 1;
    #10;

    if(datapath_out == 16)
      $display("Datapath out passed !");
    else
      $display("Datapath out failed !");

    if(Z_out == 0)
      $display("Z out passed !");
    else
      $display("Z out failed !");

    // Store it in R2
    vsel = 0;
    writenum = 2;
    readnum = 2;
    write = 1;
    #10;

    // Stop the simulation
    $stop(0);
  end
endmodule
