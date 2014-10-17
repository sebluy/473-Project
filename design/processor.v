module processor (

  input clock,
  input reset,
  
  /* pc */
  output reg [31:0] PC,
  input [31:0] current_instruction,

  /* register file */
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

  /* update clock */
  always @(posedge clock)
  begin
    if (reset)
      PC = 0 ;
    else
      PC = PC + 4 ;
  end

  /* fetch_decode pipeline registers */
  reg [31:0] fetch_decode_instruction ;

  /* latch instruction coming out of instruction memory */
  always @(posedge clock)
  begin
    fetch_decode_instruction <= current_instruction ;
  end

  /****************/
  /* DECODE STAGE */
  /****************/

  wire [5:0] opcode_decode ;
  wire [4:0] rs_decode ;
  wire [4:0] rt_decode ;
  wire [4:0] rd_decode ;
  wire [4:0] shamt_decode ;
  wire [5:0] funct_decode ;
  wire [4:0] write_address_decode ;
  wire add_instruction_decode ;

  /* R format */
  assign opcode_decode = fetch_decode_instruction[31:26] ;
  assign rs_decode = fetch_decode_instruction[25:21] ;
  assign rt_decode = fetch_decode_instruction[20:16] ;
  assign rd_decode = fetch_decode_instruction[15:11] ;
  assign shamt_decode = fetch_decode_instruction[10:6] ;
  assign funct_decode = fetch_decode_instruction[5:0] ;

  assign register_file_read_address_1 = rs_decode ;
  assign register_file_read_address_2 = rt_decode ;
  assign write_address_decode = rd_decode ;
  assign add_instruction_decode = (funct_decode == 6'h20) &&
                                  (shamt_decode == 5'h00) &&
                                  (opcode_decode == 6'h00) ;
  
  /* decode execution pipeline registers */

  reg [31:0] decode_execution_read_value_1 ;
  reg [31:0] decode_execution_read_value_2 ;
  reg [4:0] decode_execution_write_address ;
  reg decode_execution_valid ;

  always @(posedge clock)
  begin
    decode_execution_read_value_1 <= register_file_read_value_1 ;
    decode_execution_read_value_2 <= register_file_read_value_2 ;
    decode_execution_write_address <= write_address_decode ;
    decode_execution_valid <= add_instruction_decode ;
  end

  /*******************/
  /* EXECUTION STAGE */
  /*******************/

  reg [31:0] execution_memory_value ;
  reg [4:0] execution_memory_address ;
  reg execution_memory_valid ;

  always @(posedge clock)
  begin
    execution_memory_value <= decode_execution_read_value_1 +
      decode_execution_read_value_2 ;
    execution_memory_address <= decode_execution_write_address ;
    execution_memory_valid <= decode_execution_valid ;
  end

  /****************/
  /* MEMORY STAGE */
  /****************/

  reg [31:0] memory_writeback_value ;
  reg [4:0] memory_writeback_address ;
  reg memory_writeback_valid ;

  always @(posedge clock)
  begin
    memory_writeback_value <= execution_memory_value ;
    memory_writeback_address <= execution_memory_address ;
    memory_writeback_valid <= execution_memory_valid ;
  end

  /********************/
  /* WRITE BACK STAGE */
  /********************/
  
  assign register_file_write_value = memory_writeback_value ;

  assign register_file_write_address = memory_writeback_address ;

  assign register_file_write_enable = memory_writeback_valid ;

endmodule

