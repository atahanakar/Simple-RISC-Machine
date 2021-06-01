// Testbench for fsm
/*
//INPUTS
input logic clk,
input logic reset,
input logic s,
input logic [1:0] op,
input logic [2:0] opcode,

//OUTPUTS
output logic loada,
output logic loadb,
output logic loadc,
output logic loads,
output logic asel,
output logic bsel,
output logic [1:0] vsel,        //100 010 001
output logic [2:0] nsel, // Rn, Rd, Rm
output logic w,
output logic write
);
*/
module fsm_tb();
  reg clk;
  reg reset;
  reg s;
  reg [1:0] op;
  reg [2:0] opcode;

  //OUTPUTS
  wire loada;
  wire loadb;
  wire loadc;
  wire loads;
  wire asel;
  wire bsel;
  wire [1:0] vsel;        //100 010 001
  wire [2:0] nsel; // Rn, Rd, Rm
  wire w;
  wire write;

  fsm DUT(
    .clk(clk),
    .reset(reset),
    .s(s),
    .op(op),
    .opcode(opcode),

    //OUTPUTS
    .loada(loada),
    .loadb(loadb),
    .loadc(loadc),
    .loads(loads),
    .asel(asel),
    .bsel(bsel),
    .vsel(),        //100 010 001
    .nsel(nsel), // Rn, Rd, Rm
    .w(w),
    .write(write)
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
    s = 0;
    reset = 0;
    op = 2'b00;
    opcode = 3'b000;
    #10;

    // Case #1 MOV Rn, #45
    s = 1;
    reset = 0;
    op = 2'b10;
    opcode = 3'b110;
    #10;
    s = 0;
    #10;
    #10;
    #10;

    // Case #2 MOV Rd, Rm
    s = 1;
    op = 2'b00;
    opcode = 3'b110;
    #20;
    s = 0;
    #10;
    #10;
    #10;
    #10;

    // Case #3 ADD Rd, Rn, Rm
    s = 1;
    op = 2'b00;
    opcode = 3'b101;
    #10;
    #10;
    s = 0;
    #10;
    #10;
    #10;
    #10;

    // Case #3 CMP Rn, Rm
    s = 1;
    op = 2'b01;
    opcode = 3'b101;
    #20;
    s = 0;
    #10;
    #10;
    #10;
    #10;

    // Case #4 AND Rd, Rn, Rm
    s = 1;
    op = 2'b10;
    opcode = 3'b101;
    #20;
    s = 0;
    #10;
    #10;
    #10;
    #10;
    #10;

    // Case #5 MVN Rd, Rn, Rm
    s = 1;
    op = 2'b11;
    opcode = 3'b101;
    #20;
    s = 0;
    #10;
    #10;
    #10;
    #10;

    // Stop the simulation
    $stop(0);
  end
endmodule
