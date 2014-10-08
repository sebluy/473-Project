module processor (

  input clock ;
  output reg [17:0] PC ;

) ;
  
  always @(posedge clock)
    PC = PC + 4 ;

endmodule
  
