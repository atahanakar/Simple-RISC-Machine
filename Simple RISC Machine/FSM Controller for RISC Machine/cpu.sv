module cpu #(
  parameter data_width = 16
  )
  (
  // INPUTS
  input logic clk,
  input logic reset,
  input logic s,
  input logic load,
  input logic [data_width - 1:0] in,
  input logic [data_width - 1:0] mdata,
  input logic [7:0] PC,

  //OUTPUTS
  output logic [data_width - 1:0] out,
  output logic N,
  output logic V,
  output logic Z,
  output logic w
  );

  // Essential wires
  logic [data_width - 1:0] reg_out, sximm5, sximm8;
  logic [2:0] opcode;
  logic [1:0] op, shift, ALUop, vsel;
  logic [2:0] nsel;
  logic [2:0] readnum, writenum;


  // Instruction Register
  vDFFE #(
    .data_width(data_width)
  )
  Instruction_Register
  (
    .clk(clk),
    .load(load),
    .in(in),
    .out(reg_out)
  );

  //Instruction Decoder
  instruction_decoder INST_DEC (
    .instruction(reg_out),
    .nsel(nsel),

    .ALUop(ALUop),
    .sximm5(sximm5),
    .sximm8(sximm8),
    .shift(shift),
    .readnum(readnum),
    .writenum(writenum),
    .op(op),
    .opcode(opcode)
  );

  datapath #(
    .data_width(data_width)
  )
  DP(
    .clk         (clk), // clk

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
    .mdata       (mdata),
    .sximm8      (sximm8),
    .sximm5      (sximm5),
    .PC          (PC),

    // outputs
    .Z_out       (Z),
    .V_out       (V),
    .N_out       (N),
    .datapath_out(out)
  );

  fsm FSM_CONTROLLER(
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
  .vsel(vsel),        //100 010 001
  .nsel(nsel), // Rn, Rd, Rm
  .w(w),
  .write(write)
  );

endmodule
