// FSM for controlling the datapath
module fsm(
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
  output logic load_ir,
  output logic load_pc,
  output logic load_addr,
  output logic asel,
  output logic bsel,
  output logic addr_sel,
  output logic reset_pc,
  output logic [1:0] mem_cmd,
  output logic [1:0] vsel,        //100 010 001
  output logic [2:0] nsel, // Rn, Rd, Rm
  output logic w,
  output logic write
  );

  // States
  parameter RESET     = 25'b00_1_0_0_1_0_0_0_0_0_1_000_00_0_0_0__000000; // 0
  parameter DECODE    = 25'b00_0_0_0_0_0_0_0_0_0_0_000_00_0_0_0__000001; // 1
  parameter MOV_IMM   = 25'b00_0_0_0_0_0_0_0_0_1_0_100_10_0_0_0__000010; // 2
  parameter MOV_REG_1 = 25'b00_0_0_0_0_0_0_0_0_0_0_001_00_0_0_0__000011; // 3
  parameter MOV_REG_2 = 25'b00_0_0_0_0_0_0_0_0_0_0_001_00_0_1_0__000100; // 4
  parameter MOV_REG_3 = 25'b00_0_0_0_0_0_0_1_0_0_0_001_00_1_0_0__000101; // 5
  parameter MOV_REG_4 = 25'b00_0_0_0_0_0_0_0_0_1_0_010_00_0_0_0__000110; // 6
  parameter GET_A     = 25'b00_0_0_0_0_0_0_0_0_0_0_100_00_0_0_1__000111; // 7
  parameter GET_B     = 25'b00_0_0_0_0_0_0_0_0_0_0_001_00_0_1_0__001000; // 8
  parameter ADD       = 25'b00_0_0_0_0_0_0_0_0_0_0_000_00_1_0_0__001001; // 9
  parameter CMP       = 25'b00_0_0_0_0_0_0_0_1_0_0_000_00_0_0_0__001010; // 10
  parameter AND       = 25'b00_0_0_0_0_0_0_0_0_0_0_000_00_1_0_0__001011; // 11
  parameter MVN       = 25'b00_0_0_0_0_0_0_0_0_0_0_000_00_1_0_0__001100; // 12
  parameter WRITE_REG = 25'b00_0_0_0_0_0_0_0_0_1_0_010_00_0_0_0__001101; // 13
  parameter IF1       = 25'b11_0_1_0_0_0_0_0_0_0_0_000_00_0_0_0__001110; // 14
  parameter IF2       = 25'b11_0_0_0_0_1_0_0_0_0_0_000_00_0_0_0__001111; // 15
  parameter UPDATE_PC = 25'b00_0_0_0_1_0_0_0_0_0_0_000_00_0_0_0__010000; // 16
  parameter LDR_1     = 25'b00_0_0_0_0_0_0_0_0_0_0_100_00_0_0_0__010001; // 17
  parameter LDR_2     = 25'b00_0_0_0_0_0_1_0_0_0_0_000_00_0_0_1__010010; // 18
  parameter LDR_3     = 25'b00_0_0_0_0_0_1_0_0_0_0_000_00_1_0_0__010011; // 19
  parameter LDR_4     = 25'b00_0_0_1_0_0_0_0_0_0_0_000_00_0_0_0__010100; // 20
  parameter LDR_5     = 25'b11_0_0_0_0_0_0_0_0_0_0_000_00_0_0_0__010101; // 21
  parameter LDR_6     = 25'b11_0_0_0_0_0_0_0_0_1_0_010_11_0_0_0__010110; // 22
  parameter STR_1     = 25'b00_0_0_0_0_0_0_0_0_0_0_100_00_0_0_0__010111; // 23
  parameter STR_2     = 25'b00_0_0_0_0_0_1_0_0_0_0_000_00_0_0_1__011000; // 24
  parameter STR_3     = 25'b00_0_0_0_0_0_1_0_0_0_0_000_00_1_0_0__011001; // 25
  parameter STR_4     = 25'b00_0_0_1_0_0_0_0_0_0_0_000_00_0_0_0__011010; // 26
  parameter STR_5     = 25'b00_0_0_0_0_0_0_0_0_0_0_010_00_0_0_0__011011; // 27
  parameter STR_6     = 25'b00_0_0_0_0_0_0_1_0_0_0_000_00_0_1_0__011100; // 28
  parameter STR_7     = 25'b00_0_0_0_0_0_0_1_0_0_0_000_00_1_0_0__011101; // 29
  parameter STR_8     = 25'b01_0_0_0_0_0_0_0_0_0_0_000_00_0_0_0__011110; // 30
  parameter HALT      = 25'b00_1_0_0_0_0_0_0_0_0_1_000_00_0_0_0__011111; // 31

  logic [25:0] state;

  // Output logic
  assign mem_cmd   = state[25:24];
  assign reset_pc  = state[23];
  assign addr_sel  = state[22];
  assign load_addr = state[21];
  assign load_pc   = state[20];
  assign load_ir   = state[19];
  assign bsel      = state[18];
  assign asel      = state[17];
  assign loads     = state[16];
  assign write     = state[15];
  assign w         = state[14]; // wait signal
  assign nsel      = state[13:11];
  assign vsel      = state[10:9];
  assign loadc     = state[8];
  assign loadb     = state[7];
  assign loada     = state[6];

  // Wire for simulation
  wire [5:0] fake_state = state[5:0];

  always @ (posedge clk or posedge reset) begin
    if(reset)
      state <= RESET;
    else begin
      case (state)
        RESET: begin
                  state <= IF1;
              end

        IF1: begin
              state <= IF2;
             end

        IF1: begin
              state <= UPDATE_PC;
             end

        UPDATE_PC: begin
                    state <= DECODE;
                   end

        DECODE: begin
                if(opcode == 3'b110)
                  if(op == 2'b10)
                    state <= MOV_IMM;
                  else
                    state <= MOV_REG_1;

                else if(opcode == 3'b101)
                  if(op != 2'b11)
                    state <= GET_A;
                  else
                    state <= GET_B;

                else if(opcode == 3'b011 && op == 2'b00)
                  state <= LDR_1;

                else if(opcode == 3'b100 && op == 2'b00)
                  state <= STR_1;

                else if(opcode == 3'b111)
                  state <= HALT;
                end

        //Mov Rn, Sximm8()
        MOV_IMM: begin
                  state <= IF1;
                 end

        //MOV Rd, Rm
        MOV_REG_1: begin
                  state <= MOV_REG_2;
                 end

        MOV_REG_2: begin
                    state <= MOV_REG_3;
                   end

        MOV_REG_3: begin
                    state <= MOV_REG_4;
                   end

        MOV_REG_4: begin
                    state <= IF1;
                   end

        GET_A: begin
                state <= GET_B;
               end
        GET_B: begin
                if(op == 2'b00)
                  state <= ADD;
                else if(op == 2'b01)
                  state <= CMP;
                else if(op == 2'b10)
                  state <= AND;
                else
                  state <= MVN;
               end
        ADD:  begin
                state <= WRITE_REG;
              end

        CMP: begin
              state <= IF1;
             end

        AND: begin
              state <= WRITE_REG;
             end

        MVN: begin
              state <= WRITE_REG;
             end

        WRITE_REG: begin
                    state <= IF1;
                   end

        // LDR Rd, [Rn]
        LDR_1: begin
                state <= LDR_2;
               end

        LDR_2: begin
               state <= LDR_3;
              end

        LDR_3: begin
               state <= LDR_4;
              end

        LDR_4: begin
               state <= LDR_5;
              end

        LDR_5: begin
               state <= LDR_6;
              end

        LDR_6: begin
               state <= IF1;
              end

        // STR Rd, [Rn]
        STR_1: begin
               state <= STR_2;
              end

        STR_2: begin
               state <= STR_3;
              end

        STR_3: begin
               state <= STR_4;
              end

        STR_4: begin
               state <= STR_5;
              end

        STR_5: begin
               state <= STR_6;
              end

        STR_6: begin
               state <= STR_7;
              end

        STR_7: begin
               state <= STR_8;
              end

        STR_8: begin
               state <= IF1;
              end

        // HALT State
        HALT: begin
                state <= HALT;
              end

        default: state <= RESET;
      endcase
    end
  end

endmodule
