module cpu #(
  parameter data_width = 16,
  parameter filename   = "data.txt"
  )
  (
  // INPUTS
  input logic clk,
  input logic reset,
  input logic s,
  input logic [data_width - 1:0] in,
  input logic [data_width - 1:0] mdata, //read_data
  input logic [7:0] PC,

  //OUTPUTS
  output logic [data_width - 1:0] out, //din, write_data
  output logic [8:0] mem_addr,
  output logic N,
  output logic V,
  output logic Z,
  output logic w
  );

  // Parameters
  parameter MWRITE = 2'b01;
  parameter MREAD  = 2'b11;

  // Essential wires
  logic [data_width - 1:0] reg_out, sximm5, sximm8, dout;
  logic [8:0] data_addr_out, next_pc, pc_out;
  logic [2:0] opcode;
  logic [1:0] op, shift, ALUop, vsel, mem_cmd;
  logic [2:0] nsel;
  logic [2:0] readnum, writenum;
  logic msel, ram_write, ram_read;

  // Instruction Register
  vDFFE #(
            .data_width(data_width)
          )
            Instruction_Register
            (
              .clk(clk),
              .load(load_ir),
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

  // FSM
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
                      .load_ir(load_ir),
                      .load_pc(load_pc),
                      .load_addr(load_addr),
                      .addr_sel(addr_sel),
                      .reset_pc(reset_pc),
                      .mem_cmd(mem_cmd),
                      .asel(asel),
                      .bsel(bsel),
                      .vsel(vsel),        //100 010 001
                      .nsel(nsel), // Rn, Rd, Rm
                      .w(w),
                      .write(write)
                      );

  // RAM
  RAM #(
        .data_width(data_width),
        .addr_width(4),
        .filename(filename)
        )
        RW_MEM
        (
          .clk(clk),
          .read_address(mem_addr),
          .write_address(read_address),
          .write(ram_write),
          .din(out),
          .dout(dout)
        );

  // Memory Select Logic
  assign msel = (1'b0 == mem_addr[8]);

  // Memory Write logic
  assign ram_write = (MWRITE == mem_cmd) & msel;

  // Memory Read Logic
  assign ram_read = (MREAD == mem_cmd) & msel;

  // Memory Data Logic
  assign mdata = ram_read ? dout : {16{1'bz}};

  // Next Program Counter Logic
  assign next_pc = reset_pc ? 9'b0 : pc_out + 9'b1;

  // Data Address
  vDFFE #(
            .data_width(9)
          )
          DATA_ADDRESS
          (
            .clk(clk),
            .load(load_addr),
            .in(out[8:0]),
            .out(data_addr_out)
          );

  // Program Counter
  vDFFE #(
            .data_width(9)
          )
          PROGRAM_COUNTER
          (
            .clk(clk),
            .load(load_pc),
            .in(next_pc),
            .out(pc_out)
          );

  // Memory Address Logic
  assign mem_addr = addr_sel ? pc_out : data_addr_out;




endmodule
