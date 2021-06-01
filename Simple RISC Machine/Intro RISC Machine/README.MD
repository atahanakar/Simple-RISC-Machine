INSTRUCTIONS:

DE1-SOC INTERFACE SPECIFICATION 

clk input to datpath has rising edge when KEY0 is *pressed* 

LEDR9 is the status register output (Z_out)

HEX3, HEX2, HEX1, HEX0 are wired to datapath_out.

When SW[9] is set to 1, SW[7:0] changes the lower 8 bits of datpath_in.
(The upper 8-bits are hardwired to zero.) The LEDR[8:0] will show the
current control inputs (LED "on" means input has logic value of 1).

When SW[9] is set to 0, SW[8:0] changes the control inputs to the datapath
as listed in the table below.  Note that the datapath has three main
stages: register read, execute and writeback.  On any given clock cycle,
you should only need to configure one of these stages so some switches are
reused.  LEDR[7:0] will show the lower 8-bits of datapath_in (LED "on"
means corresponding input has logic value of 1).

control signal(s)  switch(es)
~~~~~~~~~~~~~~~~~  ~~~~~~~~~       
<<register read stage>>
          readnum  SW[3:1]
            loada  SW[5]
            loadb  SW[6]
<<execute stage>>
            shift  SW[2:1]
             asel  SW[3]
             bsel  SW[4]
            ALUop  SW[6:5]
            loadc  SW[7]
            loads  SW[8]
<<writeback stage>>
            write  SW[0]      
         writenum  SW[3:1]
             vsel  SW[4]
