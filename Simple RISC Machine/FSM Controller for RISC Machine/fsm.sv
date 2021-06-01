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
  output logic asel,
  output logic bsel,
  output logic [1:0] vsel,        //100 010 001
  output logic [2:0] nsel, // Rn, Rd, Rm
  output logic w,
  output logic write
  );

  // States
  parameter WAIT      = 18'b0_0_0_0_1_000_00_0_0_0__00000; // 0
  parameter DECODE    = 18'b0_0_0_0_0_000_00_0_0_0__00001; // 1
  parameter MOV_IMM   = 18'b0_0_0_1_0_100_10_0_0_0__00010; // 2
  parameter MOV_REG_1 = 18'b0_0_0_0_0_001_00_0_0_0__00011; // 3
  parameter MOV_REG_2 = 18'b0_0_0_0_0_001_00_0_1_0__00100; // 4
  parameter MOV_REG_3 = 18'b0_1_0_0_0_001_00_1_0_0__00101; // 5
  parameter MOV_REG_4 = 18'b0_0_0_1_0_010_00_0_0_0__00110; // 6
  parameter GET_A     = 18'b0_0_0_0_0_100_00_0_0_1__00111; // 7
  parameter GET_B     = 18'b0_0_0_0_0_001_00_0_1_0__01000; // 8
  parameter ADD       = 18'b0_0_0_0_0_000_00_1_0_0__01001; // 9
  parameter CMP       = 18'b0_0_1_0_0_000_00_0_0_0__01010; // 10
  parameter AND       = 18'b0_0_0_0_0_000_00_1_0_0__01011; // 11
  parameter MVN       = 18'b0_0_0_0_0_000_00_1_0_0__01100; // 12
  parameter WRITE_REG = 18'b0_0_0_1_0_010_00_0_0_0__01101; // 13

  logic [17:0] state;

  // Output logic
  assign bsel  = state[17];
  assign asel  = state[16];
  assign loads = state[15];
  assign write = state[14];
  assign w     = state[13];
  assign nsel  = state[12:10];
  assign vsel  = state[9:8];
  assign loadc = state[7];
  assign loadb = state[6];
  assign loada = state[5];



  // Wire for simulation
  wire [4:0] fake_state = state[4:0];

  always @ (posedge clk or posedge reset) begin
    if(reset)
      state <= WAIT;
    else begin
      case (state)
        WAIT: begin
                if(s)
                  state <= DECODE;
                else
                  state <= WAIT;
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
                end

        //Mov Rn, Sximm8()
        MOV_IMM: begin
                  state <= WAIT;
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
                    state <= WAIT;
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
              state <= WAIT;
             end

        AND: begin
              state <= WRITE_REG;
             end

        MVN: begin
              state <= WRITE_REG;
             end

        WRITE_REG: begin
                    state <= WAIT;
                   end
        default: state <= WAIT;
      endcase
    end
  end

endmodule
