INSTRUCTIONS:

DE1-SOC INTERFACE SPECIFICATION for lab6_top.v code in this file:

clk input to datpath has rising edge when KEY0 is *pressed*

HEX5 contains the status register output on the top (Z), middle (N) and
bottom (V) segment.

HEX3, HEX2, HEX1, HEX0 are wired to out which should show the contents
of your register C.

When SW[9] is set to 0, SW[7:0] changes the lower 8 bits of the 16-bit
input "in". LEDR[8:0] will show the upper 8-bits of 16-bit input "in".

When SW[9] is set to 1, SW[7:0] changes the upper 8 bits of the 16-bit
input "in". LEDR[8:0] will show the lower 8-bits of 16-bit input "in".

The rising edge of clk occurs at the moment when you press KEY0.
The input reset is 1 as long as you press (and hold) KEY1.
The input s is 1 as long as you press (and hold) KEY2.
The input load is 1 as long as you press (and hold) KEY3.
