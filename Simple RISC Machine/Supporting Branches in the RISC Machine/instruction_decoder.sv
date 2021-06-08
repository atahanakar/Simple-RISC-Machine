module instruction_decoder(
    //INPUTS
    input logic [15:0] instruction,
    input logic [2:0] nsel,

    //OUTPUTS
    output logic [1:0]  ALUop,
    output logic [15:0] sximm5,
    output logic [15:0] sximm8,
    output logic [1:0]  shift,
    output logic [2:0]  readnum,
    output logic [2:0]  writenum,
    output logic [1:0]  op,
    output logic [2:0]  opcode,
    output logic [2:0]  cond
  );

  // ALUop
  assign ALUop = instruction[12:11];

  // Sximm's
  assign sximm5 = {{11{instruction[4]}}, instruction[4:0]};
  assign sximm8 = {{8{instruction[7]}}, instruction[7:0]};

  // Shift
  assign shift = instruction[4:3];

  // Readnum, Writenum
  always @ (*) begin
    case(nsel)
      3'b001: readnum = instruction[2:0]; // Rm
      3'b010: readnum = instruction[7:5]; // Rd
      3'b100: readnum = instruction[10:8]; // Rn
      default: readnum = {3'bxxx};
    endcase
  end

  assign writenum = readnum;

  // Condition (cond)
  assign cond = instruction[10:8];

  // Op, Opcode
  assign op = instruction[12:11];
  assign opcode = instruction[15:13];

endmodule
