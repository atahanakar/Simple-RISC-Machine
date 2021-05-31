// Testbench for regfile
module regfile_tb();
reg clk, write;
reg[2:0] writenum, readnum;
reg[15:0] data_in;

wire[15:0] data_out;

// Testing regfile
regfile #(
  .data_width(16)
  )
  DUT(
  .clk(clk),
  .data_in(data_in),
  .write(write),
  .readnum(readnum),
  .writenum(writenum),
  .data_out(data_out)
  );

initial begin // Initialise the clk
  clk = 0; #5;
  forever begin // Forever loop
  clk = 1; #5;
  clk = 0; #5;
  end
end

initial begin // Test cases
  // Case # 1 data_in = 42, writenum = 4, readnum = 4, write = 1  :: Testing if it writes and reads the register 4
  data_in = 42;
  writenum = 4;
  readnum = 4;
  write = 1;
  #20;

  // Case # 2  ...


  // Stop the simulation
  $stop(0);
end

endmodule
