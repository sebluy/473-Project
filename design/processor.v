module processor (

  input clock,
  input current_instruction,
  output reg [31:0] PC

) ;
  
  always @(posedge clock)
    PC = PC + 4 ;

endmodule
  
