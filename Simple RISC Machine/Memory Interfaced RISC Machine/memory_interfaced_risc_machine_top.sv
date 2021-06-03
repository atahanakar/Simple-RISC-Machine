
module memory_interfaced_risc_machine_top(
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

  wire [15:0] out, ir;
  // input_iface IN(
  //               CLOCK_50,
  //               SW,
  //               ir,
  //               LEDR[7:0]
  //               );

  wire Z, N, V;

  // Parameters
  parameter MWRITE = 2'b01;
  parameter MREAD  = 2'b11;
  parameter MEMORY_ADDRESS_1 = 9'h140;
  parameter MEMORY_ADDRESS_2 = 9'h100;

  // Essential wires
  logic [15:0] read_data;
  logic [9:0] mem_addr;
  logic [1:0] mem_cmd;
  logic switch_en;
  logic load_ledr;

  // CL 1
  always @ (*) begin
    if(mem_addr == MEMORY_ADDRESS_1 && mem_cmd == MREAD)
      switch_en = 1'b1;
    else
      switch_en = 1'b0;
  end

  assign read_data[15:8] = switch_en ? 8'h00 : {8{1'bz}};
  assign read_data[7:0]  = switch_en ? SW[7:0] : {8{1'bz}};

  // CL2
  always @ (*) begin
    if(mem_addr == MEMORY_ADDRESS_2 && mem_cmd == MWRITE)
      load_ledr = 1'b1;
    else
      load_ledr = 1'b0;
  end

  // LEDR Logic
  vDFFE #(
          .data_width(8)
          )
          LEDR_LOGIC
          (
          .clk (~KEY[0]),
          .load(load_ledr),
          .in  (out[7:0]),
          .out (LEDR[7:0])
          );

  cpu #(
         .data_width (16),
         .filename ("data.txt")
        ) U (
         .clk     (~KEY[0]), // recall from Lab 4 that KEY0 is 1 when NOT pushed
         .reset   (~KEY[1]),
         .s       (~KEY[2]),
         .load    (~KEY[3]),
         .mdata   (read_data),
         .mem_addr(mem_addr),
         .mem_cmd (mem_cmd),
         .out     (out),
         .Z       (Z),
         .N       (N),
         .V       (V),
         .w       (LEDR[9])
         );



  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(out[3:0],   HEX0);
  sseg H1(out[7:4],   HEX1);
  sseg H2(out[11:8],  HEX2);
  sseg H3(out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;
endmodule

module input_iface(clk, SW, ir, LEDR);
  input clk;
  input [9:0] SW;
  output [15:0] ir;
  output [7:0] LEDR;
  wire sel_sw = SW[9];
  wire [15:0] ir_next = sel_sw ? {SW[7:0],ir[7:0]} : {ir[15:8],SW[7:0]};
  vDFF #(16) REG(clk,ir_next,ir);
  assign LEDR = sel_sw ? ir[7:0] : ir[15:8];
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
