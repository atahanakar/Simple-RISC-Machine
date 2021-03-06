// FSM for controlling the datapath
module fsm(
  //INPUTS
  input logic clk,
  input logic reset,
  input logic [1:0] op,
  input logic [2:0] opcode,

  //OUTPUTS
  output logic loada,
  output logic loadb,
  output logic loadc,
  output logic loads,
  output logic load_ir,
  output logic load_pc,
  output logic load_bpc,
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
  typedef enum logic [26:0] {
  RESET     = 27'b0_00_1_0_0_1_0_0_0_0_0_0_000_00_0_0_0__000000, // 0
  DECODE    = 27'b0_00_0_0_0_0_0_0_0_0_0_0_100_00_0_0_0__000001, // 1
  MOV_IMM   = 27'b0_00_0_0_0_0_0_0_0_0_1_0_100_10_0_0_0__000010, // 2
  MOV_REG_1 = 27'b0_00_0_0_0_0_0_0_0_0_0_0_001_00_0_0_0__000011, // 3
  MOV_REG_2 = 27'b0_00_0_0_0_0_0_0_0_0_0_0_001_00_0_1_0__000100, // 4
  MOV_REG_3 = 27'b0_00_0_0_0_0_0_0_1_0_0_0_001_00_1_0_0__000101, // 5
  MOV_REG_4 = 27'b0_00_0_0_0_0_0_0_0_0_1_0_010_00_0_0_0__000110, // 6
  GET_A     = 27'b0_00_0_0_0_0_0_0_0_0_0_0_100_00_0_0_1__000111, // 7
  GET_B     = 27'b0_00_0_0_0_0_0_0_0_0_0_0_001_00_0_1_0__001000, // 8
  ADD       = 27'b0_00_0_0_0_0_0_0_0_0_0_0_000_00_1_0_0__001001, // 9
  CMP       = 27'b0_00_0_0_0_0_0_0_0_1_0_0_000_00_0_0_0__001010, // 10
  AND       = 27'b0_00_0_0_0_0_0_0_0_0_0_0_000_00_1_0_0__001011, // 11
  MVN       = 27'b0_00_0_0_0_0_0_0_0_0_0_0_000_00_1_0_0__001100, // 12
  WRITE_REG = 27'b0_00_0_0_0_0_0_0_0_0_1_0_010_00_0_0_0__001101, // 13
  IF1       = 27'b0_11_0_1_0_0_0_0_0_0_0_0_000_00_0_0_0__001110, // 14
  IF2       = 27'b0_11_0_1_0_0_1_0_0_0_0_0_000_00_0_0_0__001111, // 15 
  UPDATE_PC = 27'b0_00_0_0_0_1_0_0_0_0_0_0_000_00_0_0_0__010000, // 16
  LDR_1     = 27'b0_00_0_0_0_0_0_0_0_0_0_0_100_00_0_0_1__010001, // 17
  LDR_2     = 27'b0_00_0_0_0_0_0_1_0_0_0_0_000_00_1_0_0__010010, // 18
  LDR_3     = 27'b0_00_0_0_1_0_0_0_0_0_0_0_000_00_0_0_0__010011, // 19
  LDR_4     = 27'b0_00_0_0_1_0_0_0_0_0_0_0_000_00_0_0_0__010100, // 20
  LDR_5     = 27'b0_11_0_0_0_0_0_0_0_0_1_0_010_11_0_0_0__010101, // 21
  STR_1     = 27'b0_00_0_0_0_0_0_0_0_0_0_0_100_00_0_0_1__010111, // 23
  STR_2     = 27'b0_00_0_0_0_0_0_1_0_0_0_0_000_00_1_0_0__011000, // 24
  STR_3     = 27'b0_00_0_0_1_0_0_0_0_0_0_0_000_00_0_0_0__011001, // 25
  STR_4     = 27'b0_00_0_0_1_0_0_0_0_0_0_0_000_00_0_0_0__011010, // 27
  STR_5     = 27'b0_01_0_0_0_0_0_1_1_0_1_0_010_00_0_1_0__011011, // 27
  STR_6     = 27'b0_01_0_0_0_0_0_0_1_0_0_0_000_00_1_0_0__011100, // 28
  STR_7     = 27'b0_01_0_0_0_0_0_0_0_0_0_0_000_00_0_0_0__011101, // 29
  HALT      = 27'b0_00_1_0_0_1_0_0_0_0_0_1_000_00_0_0_0__011111, // 31
  BRANCH    = 27'b1_00_0_0_0_1_0_0_0_0_0_0_000_00_0_0_0__100000, // 32
  BL_1      = 27'b0_00_0_0_0_0_0_0_0_0_1_0_100_01_0_0_0__100001,  // 33
  BL_2      = 27'b1_00_0_0_0_1_0_0_0_0_0_0_000_00_0_0_0__100010,
  BX_1      = 27'b1_00_0_0_0_1_0_0_0_0_0_0_010_00_0_0_0__100011,
  BLX_1     = 27'b0_00_0_0_0_0_0_0_0_0_1_0_100_01_0_0_0__100100,
  BLX_2     = 27'b1_00_0_0_0_1_0_0_0_0_0_0_010_00_0_0_0__100101
  } state_logic;
  //logic [25:0] state;

  state_logic state;

  // Output logic
  assign load_bpc  = state[26];
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

        IF2: begin
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

                else if(opcode == 3'b001)
                  state <= BRANCH;
                
                else if(opcode == 3'b010 && op == 2'b11)
                  state <= BL_1;
                
                else if(opcode == 3'b010 && op == 2'b00)
                  state <= BX_1;

                else if(opcode == 3'b010 && op == 2'b11)
                  state <= BLX_1;

                else if(opcode == 3'b111)
                  state <= HALT;

					 else 
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
               state <= IF1;
              end

        // SIMPLE BRANCH State
        BRANCH: begin
                    state <= IF1;
                  end
        
        // Branch and Link
        BL_1: begin
                state <= BL_2;
              end

        BL_2: begin
                state <= IF1;
              end
        
        // Branch and Return
        BX_1: begin
                state <= IF1;
              end

        // Branch and Indirect Call
        BLX_1: begin
                state <= BLX_2;
               end

        BLX_2: begin
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
