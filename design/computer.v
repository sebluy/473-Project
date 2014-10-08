module computer (

  input clock,
  input reset,
  input register_reset,
  input [5:0] display_register_address,
  output [31:0] display_register_value,
  input [5:0] display_data_memory_address,
  output [31:0] display_data_memory_value,
  input [5:0] display_instruction_memory_address,
  output [31:0] display_instruction_memory_value,
  output [31:0] PC,
  output [31:0] current_instruction

) ;

  /* register file */ 
  register_file(5'b0, 5'b0, 1'b0, register_reset, clock, 5'b0, 32'b0,
                clock, display_register_address,,, display_register_value) ;

  /* ram */
  ramlpm(32'b0, {27'b0, display_data_memory_address}, ~clock, 32'b0, 32'b0,
          1'b0, 1'b0, , display_data_memory_value) ;

  /* rom */
  romlpm(PC, display_instruction_memory_address, ~clock, 
          current_instruction, display_instruction_memory_value) ;
  
  /* processor */
  processor(clock, reset, PC, current_instruction) ;

endmodule
  
