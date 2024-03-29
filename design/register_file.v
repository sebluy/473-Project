module register_file (

  input [4:0] read_address_1, read_address_2,

  input write_enable, reset, clock,
  input [4:0] write_address,
  input [31:0] write_data_in,
  
  input clock_debug,
  input [4:0] read_address_debug,

  output reg [31:0] data_out_1, data_out_2, data_out_debug

) ;
  
  integer i ;
  reg [31:0] registers [31:0] ;

  initial
  begin
    for (i = 0 ; i < 29 ; i = i + 1)
      registers[i] = 0 ;
    registers[29] <= 32'h7c ;
    for (i = 30 ; i < 32 ; i = i + 1)
      registers[i] = 0 ;
  end 

  always @(posedge clock)
  begin

    if (reset == 1)

      for(i = 0 ; i < 32 ; i = i + 1)
        registers[i] <= i ;

    else if (write_enable == 1 && write_address != 0)

        registers[write_address] = write_data_in ;

  end

  always @(negedge clock)
  begin
    data_out_1 <= registers[read_address_1] ;
    data_out_2 <= registers[read_address_2] ;
  end

  always @(posedge clock_debug)
    data_out_debug = registers[read_address_debug] ;

endmodule

  
