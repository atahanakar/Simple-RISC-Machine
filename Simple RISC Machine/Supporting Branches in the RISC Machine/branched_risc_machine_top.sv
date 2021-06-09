
module branched_risc_machine_top(
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

  logic [15:0] out, ir;
  logic Z, N, V;
  logic [8:0] mem_addr;
  logic [1:0] mem_cmd;

  cpu #(
         .data_width (16),
         .filename ("test1.txt")
        ) 
        CPU_RAM 
        (
         .clk     (CLOCK_50), // recall from Lab 4 that KEY0 is 1 when NOT pushed
         .reset   (~KEY[1]),
         .SW      (SW[7:0]),
         .out     (out),
         .LEDR    (LEDR[7:0]),
         .w       (LEDR[9])
         );

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(out[3:0],   HEX0);
  sseg H1(out[7:4],   HEX1);
  sseg H2(out[11:8],  HEX2);
  sseg H3(out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign HEX5 = 7'b1111111;
  assign LEDR[8] = 1'b0;
endmodule

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
