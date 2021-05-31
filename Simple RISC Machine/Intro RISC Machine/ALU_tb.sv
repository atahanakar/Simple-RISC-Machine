// ALU Testbench
module ALU_tb();

parameter data_width = 16;

reg [data_width - 1:0] Ain, Bin;
reg [1:0] ALUop;

wire Z;
wire[data_width - 1:0] out;

// ALU
ALU #(
  .data_width(data_width)
)
DUT(
  .Ain(Ain),
  .Bin(Bin),
  .ALUop(ALUop),
  .out(out),
  .Z(Z)
);

initial begin

// Case # 1 : Test Zero Bit
ALUop = 2'b00;
Ain = 0;
Bin = 0;
$display("Expected Data Out %d", Ain + Bin);
$display("We got %d", out);
$display("Expected Zero Bit %b", (Ain + Bin) == 0);
$display("We got %d", Z);
#20;

// Case # 2 : Test Adding
ALUop = 2'b00;
Ain = 45;
Bin = 0;
$display("Expected Data Out %d", Ain + Bin);
$display("We got %d", out);
$display("Expected Zero Bit %b", (Ain + Bin) == 0);
$display("We got %d", Z);
#20;

// Case # 3 : Test Sub
ALUop = 2'b01;
Ain = 45;
Bin = 42;
$display("Expected Data Out %d", Ain - Bin);
$display("We got %d", out);
$display("Expected Zero Bit %b", (Ain - Bin) == 0);
$display("We got %d", Z);
#20;

// Case # 4 : Test Bitwise AND
ALUop = 2'b10;
Ain = 41;
Bin = 31;
$display("Expected Data Out %d", Ain & Bin);
$display("We got %d", out);
$display("Expected Zero Bit %b", (Ain & Bin) == 0);
$display("We got %d", Z);
#20;

// Case # 5 : Test NOT
ALUop = 2'b11;
Ain = 73;
Bin = 0;
$display("Expected Data Out %d", ~Bin);
$display("We got %d", out);
$display("Expected Zero Bit %b", (~Bin) == 0);
$display("We got %d", Z);
#20;

// Stop the siulation
$stop(0);
end

endmodule
