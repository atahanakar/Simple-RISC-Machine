module cpu #(
  parameter data_width = 16,
  parameter filename   = "data.txt"
  )
  (
  // INPUTS
  input logic clk,
  input logic reset,
  input logic [7:0] SW,

  //OUTPUTS
  output logic [data_width - 1:0] out, //din, write_data
  output logic [7:0] LEDR,
  output logic w
  );

  // Parameters
  parameter MWRITE = 2'b01;
  parameter MREAD  = 2'b11;

  // Essential wires
  logic [data_width - 1:0] reg_out, sximm5, sximm8, dout, mdata;
  logic [8:0] data_addr_out, next_pc, PC, mem_addr;
  logic [2:0] opcode;
  logic [1:0] op, shift, ALUop, vsel, mem_cmd;
  logic [2:0] nsel;
  logic [2:0] readnum, writenum;
  logic msel, ram_read;
  logic tri_switch, led_load;
  logic load_ir, loada, loadb, asel, bsel, loadc, loads, write, load_pc, load_addr, addr_sel, reset_pc, ram_write;

  // CL 1
  always @ (*) begin
    if(mem_cmd == MREAD && mem_addr == 9'h140)
      tri_switch = 1'b1;
    else 
      tri_switch = 1'b0;
  end

  // CL 2
  always @ (*) begin
    if(mem_cmd == MWRITE && mem_addr == 9'h100)
      led_load = 1'b1;
    else 
      led_load = 1'b0;
  end

  vDFFE #(
          .data_width(8)
          )
          LED_REGISTER
          (
            .clk(clk),
            .load(led_load),
            .in(out[7:0]),
            .out(LEDR[7:0])
          );

  // Instruction Register
  vDFFE #(
            .data_width(data_width)
          )
            Instruction_Register
            (
              .clk(clk),
              .load(load_ir),
              .in(mdata),
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
              .datapath_out(out)
            );

  // FSM
  fsm FSM_CONTROLLER(
                      .clk(clk),
                      .reset(reset),
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
        .addr_width(8),
        .filename(filename)
        )
        RW_MEM
        (
          .clk(clk),
          .read_address(mem_addr[7:0]),
          .write_address(mem_addr[7:0]),
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
  always @ (*) begin
    case({ram_read, tri_switch})
      2'b10: mdata = dout;
      2'b01: mdata = {8'b0, SW[7:0]};
      2'b11: mdata = {8'b0, SW[7:0]};
      2'b00: mdata = {16{1'bz}};
      default: mdata = {16{1'bz}};
    endcase
  end

  // Next Program Counter Logic
  assign next_pc = reset_pc ? 9'b0 : PC + 9'b1;

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
            .out(PC)
          );

  // Memory Address Logic
  assign mem_addr = addr_sel ? PC : data_addr_out;

endmodule
