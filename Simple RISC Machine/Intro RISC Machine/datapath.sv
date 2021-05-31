module datapath #(
    parameter data_width = 15
  )
  (
    // INPUTS
    input logic [data_width - 1:0] datapath_in,
    input logic [2:0] writenum,
    input logic [2:0] readnum,
    // ALU and Shift operations
    input logic [2:0] ALUop,
    input logic [2:0] shift,

    input logic write,
    input logic clk,
    // Load signals
    input logic loada,
    input logic loadb,
    input logic loadc,
    input logic loads,

    //Mux select signals
    input logic asel,
    input logic bsel,
    input logic vsel,

    // OUTPUTS
    output logic [data_width - 1:0] datapath_out,

    // Flag Outputs
    output logic Z_out  // Zero Flag

  );

  // Essential Signals
  logic [data_width - 1:0] data_in, data_out, out, Ain, Bin, in;
  logic [data_width - 1:0] sout, Aout;
  logic Z;
  // Mux #1
  assign data_in = vsel ? datapath_in : datapath_out;

  // Register File
  regfile #(
    .data_width(data_width)
  )
  U0(
    .data_in(data_in),
    .writenum(writenum),
    .write(write),
    .readnum(readnum),
    .clk(clk),
    .data_out(data_out)
  );

  // Load Registers A, B, C, and Status
  vDFFE #(
    .data_width(data_width)
  )
  A(
    .clk(clk),
    .in(data_out),
    .load(loada),
    .out(Aout)
  );

  vDFFE #(
    .data_width(data_width)
  )
  B(
    .clk(clk),
    .in(data_out),
    .load(loadb),
    .out(in)
  );

  vDFFE #(
    .data_width(data_width)
  )
  C(
    .clk(clk),
    .in(out),
    .load(loadc),
    .out(datapath_out)
  );

  vDFFE #(
    .data_width(1)
  )
  status(
    .clk(clk),
    .in(Z),
    .load(loads),
    .out(Z_out)
  );

  //Shifter
  shifter #(
    .data_width(data_width)
  )
  U1(
    .in(in),
    .shift(shift),
    .sout1(sout)
  );

  // 2 Mux's
  assign Ain = asel ? 16'b0 : Aout;
  assign Bin = bsel ? {11'b0, datapath_in[4:0]} : sout;

  // ALU
  ALU #(
    .data_width(data_width)
  )
  U2(
    .Ain(Ain),
    .Bin(Bin),
    .ALUop(ALUop),
    .out(out),
    .Z(Z)
  );

endmodule
