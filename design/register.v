module register (clock, reset, write, data_in, data_out) ;
  parameter n = 32 ;
  input clock, reset, write ;
  input [n - 1 : 0] data_in ;
  output reg [n - 1 : 0] data_out ;

  always @(posedge clock)
  begin

    if (reset == 1)
      data_out <= 0 ;

    else if (write == 1)
      data_out <= data_in ;

    else
      data_out <= data_out ;

  end

endmodule
