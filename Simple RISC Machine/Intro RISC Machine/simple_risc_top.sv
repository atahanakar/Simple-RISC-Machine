module simple_risc_top(
  // INPUTS
  input logic  [3:0] KEY,
  input logic  [9:0] SW,
  input logic CLOCK_50,
  // OUTPUTS
  output logic [9:0] LEDR,
  output logic [6:0] HEX0,
  output logic [6:0] HEX1,
  output logic [6:0] HEX2,
  output logic [6:0] HEX3,
  output logic [6:0] HEX4,
  output logic [6:0] HEX5
  );

  logic [15:0] datapath_out, datapath_in;
  logic write, vsel, loada, loadb, asel, bsel, loadc, loads;
  logic [2:0] readnum, writenum;
  logic [1:0] shift, ALUop;

  input_iface IN(CLOCK_50, SW, datapath_in, write, vsel, loada, loadb, asel,
                 bsel, loadc, loads, readnum, writenum, shift, ALUop, LEDR[8:0]);

  datapath #(
    .data_width(16)
    )
    DP (
    .clk         (~KEY[0]), // recall from Lab 4 that KEY0 is 1 when NOT pushed

    // register operand fetch stage
    .readnum     (readnum),
    .vsel        (vsel),
    .loada       (loada),
    .loadb       (loadb),

    // computation stage (sometimes called "execute")
    .shift       (shift),
    .asel        (asel),
    .bsel        (bsel),
    .ALUop       (ALUop),
    .loadc       (loadc),
    .loads       (loads),

    // set when "writing back" to register file
    .writenum    (writenum),
    .write       (write),
    .datapath_in (datapath_in),

    // outputs
    .Z_out       (LEDR[9]),
    .datapath_out(datapath_out)
 );

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(datapath_out[3:0],   HEX0);
  sseg H1(datapath_out[7:4],   HEX1);
  sseg H2(datapath_out[11:8],  HEX2);
  sseg H3(datapath_out[15:12], HEX3);
  assign HEX4 = 7'b1111111;  // disabled
  assign HEX5 = 7'b1111111;  // disabled

endmodule


module input_iface(clk, SW, datapath_in, write, vsel, loada, loadb, asel, bsel,
                   loadc, loads, readnum, writenum, shift, ALUop, LEDR);
  input clk;
  input [9:0] SW;
  output [15:0] datapath_in;
  output write, vsel, loada, loadb, asel, bsel, loadc, loads;
  output [2:0] readnum, writenum;
  output [1:0] shift, ALUop;
  output [8:0] LEDR;

  wire sel_sw = SW[9];

  // When SW[9] is set to 1, SW[7:0] changes the lower 8 bits of datpath_in.
  wire [15:0] datapath_in_next = sel_sw ? {8'b0,SW[7:0]} : datapath_in;
  vDFF #(16) DATA(clk,datapath_in_next,datapath_in);

  // When SW[9] is set to 0, SW[8:0] changes the control inputs
  //
  wire [8:0] ctrl_sw;
  wire [8:0] ctrl_sw_next = sel_sw ? ctrl_sw : SW[8:0];
  vDFF #(9) CTRL(clk,ctrl_sw_next,ctrl_sw);

  assign {readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,writenum,write}={
    // register operand fetch stage
    //     readnum       vsel        loada       loadb
           ctrl_sw[3:1], ctrl_sw[4], ctrl_sw[5], ctrl_sw[6],
    // computation stage (sometimes called "execute")
    //     shift         asel        bse         ALUop         loadc       loads
           ctrl_sw[2:1], ctrl_sw[3], ctrl_sw[4], ctrl_sw[6:5], ctrl_sw[7], ctrl_sw[8],
    // set when "writing back" to register file
    //   writenum        write
           ctrl_sw[3:1], ctrl_sw[0]
  };

  // LEDR[7:0] shows other bits
  assign LEDR = sel_sw ? ctrl_sw : {1'b0, datapath_in[7:0]};
endmodule


module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  always @(posedge clk)
    Q <= D;
endmodule


// The sseg module below can be used to display the value of datpath_out on
// the hex LEDS the input is a 4-bit value representing numbers between 0 and
// 15 the output is a 7-bit value that will print a hexadecimal digit.  You
// may want to look at the code in Figure 7.20 and 7.21 in Dally but note this
// code will not work with the DE1-SoC because the order of segments used in
// the book is not the same as on the DE1-SoC (see comments below).

module sseg(
  // INPUT
  input logic [3:0]in,
  //OUTPUT
  output logic [6:0]segs
  );

  always@ (*) begin  //remember 0 means open
    case(in)
      4'b0000: segs = 7'b1000_000;		//0
      4'b0001: segs = 7'b1111_001;		//1
      4'b0010: segs = 7'b0100_100;		//2
      4'b0011: segs = 7'b0110_000;		//3
      4'b0100: segs = 7'b0011_001;		//4
      4'b0101: segs = 7'b0010_010;		//5
      4'b0110: segs = 7'b0000_010;		//6
      4'b0111: segs = 7'b1111_000;		//7
      4'b1000: segs = 7'b0000_000;		//8
      4'b1001: segs = 7'b0010_000;		//9
      4'b1010: segs = 7'b0001_000;		//10=A
      4'b1011: segs = 7'b0000_011;		//11=b
      4'b1100: segs = 7'b1000_110;		//12=C
      4'b1101: segs = 7'b0100_001;		//13=d
      4'b1110: segs = 7'b0000_110;		//14=E
      4'b1111: segs = 7'b0001_110;		//15F
      default: segs = 7'bxxxx_xxx;
    endcase
  end

endmodule
