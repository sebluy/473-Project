module processor (

  input clock,
  input reset,
  
  /* fetch */
  output reg [31:0] PC,
  input [31:0] current_instruction,

  /* decode */
  output [5:0] register_file_read_address_1,
  output [5:0] register_file_read_address_2,
  output [31:0] register_file_write_value,
  output [5:0] register_file_write_address,
  output register_file_write_enable,
  output register_file_reset,

  input [31:0] register_file_read_value_1,
  input [31:0] register_file_read_value_2

) ;
  

  /***************/
  /* FETCH STAGE */
  /***************/

  reg [31:0] fetch_decode_instruction ;
  reg fetch_decode_valid ;

  /* update clock */
  always @(posedge clock)
  begin
    if (~reset)
      PC = 0 ;
    else
      PC = PC + 4 ;
  end

  /* latch instruction coming out of instruction memory */
  always @(posedge clock)
  begin
    fetch_decode_instruction <= current_instruction ;
    fetch_decode_valid <= 1'b1 ;
  end

  /****************/
  /* DECODE STAGE */
  /****************/

  wire [4:0] rs_decode ;
  wire [4:0] rt_decode ;
  wire [4:0] rd_decode ;
  wire decode_write_address ;

  reg decode_execution_read_value_1 ;
  reg decode_execution_read_value_2 ;
  reg decode_execution_write_address ;
  reg decode_execution_valid ;
  
  assign rs_decode = fetch_decode_instruction[25:21] ;
  assign rt_decode = fetch_decode_instruction[20:16] ;
  assign rd_decode = fetch_decode_instruction[15:11] ;

  assign register_file_read_address_1 = rs_decode ;
  assign register_file_read_address_2 = rt_decode ;
  assign decode_write_address = rd_decode ;
  
  always @(posedge clock)
  begin
    decode_execution_read_value_1 <= register_file_read_value_1 ;
    decode_execution_read_value_2 <= register_file_read_value_2 ;
    decode_execution_write_address <= decode_write_address ;
    decode_execution_valid <= fetch_decode_valid ;
  end

  /*******************/
  /* EXECUTION STAGE */
  /*******************/

  assign register_file_write_value = decode_execution_read_value_1 
                  + decode_execution_read_value_2 ;

  assign register_file_write_address = decode_execution_write_address ;

  assign register_file_write_enable = decode_execution_valid ;

  
endmodule
  
