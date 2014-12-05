module computer (

  input clock,
  input clock_50MHz,
  input reset,
  input register_reset,
  input [5:0] display_register_address,
  output [31:0] display_register_value,
  input [5:0] display_data_memory_address,
  output [31:0] display_data_memory_value,
  input [5:0] display_instruction_memory_address,
  output [31:0] display_instruction_memory_value,
  output [31:0] PC,
  output [31:0] current_instruction,
  output [17:0] LEDR
) ;
  
  wire [5:0] register_file_read_address_1 ;
  wire [5:0] register_file_read_address_2 ;
  wire [31:0] register_file_write_value ;
  wire [5:0] register_file_write_address ;
  wire register_file_write_enable ;
  wire [31:0] register_file_read_value_1 ;
  wire [31:0] register_file_read_value_2 ;

  /* register file */ 
  register_file(register_file_read_address_1, register_file_read_address_2,
    register_file_write_enable, register_reset, clock, 
    register_file_write_address, register_file_write_value, clock_50MHz,
    display_register_address, register_file_read_value_1,
    register_file_read_value_2, display_register_value) ;


  wire [31:0] processor_memory_address ;
  wire [31:0] processor_memory_read_value ;
  wire [31:0] processor_memory_write_value ;
  wire processor_memory_write_enable ;

  /* ram */
  ramlpm(processor_memory_address[9:0],
    {display_data_memory_address, 2'b0}, ~clock,
    processor_memory_write_value, 32'b0, processor_memory_write_enable,
    1'b0, processor_memory_read_value, display_data_memory_value) ;

  /* rom */
  romlpm(PC, {display_instruction_memory_address, 2'b0}, ~clock, 
    clock_50MHz, current_instruction, display_instruction_memory_value) ;
  
  /* processor */
  processor(clock, reset, PC, current_instruction, 
    register_file_read_address_1, register_file_read_address_2,
    register_file_write_value, register_file_write_address,
    register_file_write_enable, register_file_read_value_1, 
    register_file_read_value_2, processor_memory_address,
    processor_memory_read_value, processor_memory_write_value,
    processor_memory_write_enable, LEDR) ;

endmodule
  
