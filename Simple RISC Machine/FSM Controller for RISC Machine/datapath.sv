module datapath #(
    parameter data_width = 15
  )
  (
    // INPUTS
    input logic [data_width - 1:0] mdata,
    input logic [data_width - 1:0] sximm8,
    input logic [data_width - 1:0] sximm5,
    input logic [7:0] PC,
    input logic [2:0] writenum,
    input logic [2:0] readnum,
    // ALU and Shift operations
    input logic [1:0] ALUop,
    input logic [1:0] shift,

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
    input logic [1:0] vsel,

    // OUTPUTS
    output logic [data_width - 1:0] datapath_out,

    // Flag Outputs
    output logic Z_out,  // Zero Flag
    output logic V_out,  // Overflow Flag
    output logic N_out   // Negative Flag
  );

  // Essential Signals
  logic [data_width - 1:0] data_in, data_out, out, Ain, Bin, in;
  logic [data_width - 1:0] sout, Aout;
  logic Z, N, V;
  // Mux #1
  always @ (*) begin
    case(vsel)
      2'b00: data_in = datapath_out; // C
      2'b01: data_in = {8'b0, PC};
      2'b10: data_in = sximm8;
      2'b11: data_in = mdata;
      default: data_in = data_in;
    endcase
  end

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
    .data_width(3)
  )
  status(
    .clk(clk),
    .in({Z, N, V}),
    .load(loads),
    .out({Z_out, N_out, V_out})
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
  assign Bin = bsel ? sximm5 : sout;

  // ALU
  ALU #(
    .data_width(data_width)
  )
  U2(
    .Ain(Ain),
    .Bin(Bin),
    .ALUop(ALUop),
    .out(out),
    .Z(Z),
    .N(N),
    .V(V)
  );

endmodule
