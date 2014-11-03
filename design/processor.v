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
  wire [15:0] immediate_decode ;
  wire add_instruction_decode ;
  wire addiu_instruction_decode ;
  wire r_type_decode ;
  wire i_type_decode ;
  wire valid_decode ;
  wire funct_valid_decode ;
  wire shamt_valid_decode ;
  
  reg [31:0] immediate_sign_extend_decode ;
  reg [4:0] read_address_1_decode ;
  reg [4:0] read_address_2_decode ;
  reg [4:0] write_address_decode ;

  /* R format */
  assign opcode_decode = fetch_decode_instruction[31:26] ;
  assign rs_decode = fetch_decode_instruction[25:21] ;
  assign rt_decode = fetch_decode_instruction[20:16] ;
  assign rd_decode = fetch_decode_instruction[15:11] ;
  assign shamt_decode = fetch_decode_instruction[10:6] ;
  assign funct_decode = fetch_decode_instruction[5:0] ;

  /* I format exclusive */
  assign immediate_decode = fetch_decode_instruction[15:0] ;

  /* sign extend immediate number */
  always @(*)
    immediate_sign_extend_decode[31:0] = 
      {{16{immediate_decode[15]}}, immediate_decode} ;

  /* assign instruction type */
  assign r_type_decode = opcode_decode == 6'h0 ;
  assign i_type_decode = opcode_decode == 9'h9 ; /* addui */

  assign funct_valid_decode = 
    funct_decode == 6'h20 || /* add */
    funct_decode == 6'h22 ; /* subtract */

  assign shamt_valid_decode = shamt_decode == 5'b0 ;

  assign valid_decode = i_type_decode ||
    (r_type_decode && funct_valid_decode && shamt_valid_decode) ;

  /* assign inputs to register file */
  always @(*)
  begin
    if (r_type_decode)
    begin
      read_address_1_decode <= rs_decode ;
      read_address_2_decode <= rt_decode ;
      write_address_decode <= rd_decode ;
    end 
    else if (i_type_decode)
    begin
      read_address_1_decode <= rs_decode ;
      read_address_2_decode <= 5'b0 ;
      write_address_decode <= rt_decode ;
    end
    else
    begin
      read_address_1_decode <= 5'b0 ;
      read_address_2_decode <= 5'b0 ;
      write_address_decode <= 5'b0 ;
    end
  end

  assign register_file_read_address_1 = read_address_1_decode ;
  assign register_file_read_address_2 = read_address_2_decode ;
 
  /* decode execution pipeline registers */
  reg [4:0] decode_execution_read_address_1 ;
  reg [4:0] decode_execution_read_address_2 ;
  reg [31:0] decode_execution_read_value_1 ;
  reg [31:0] decode_execution_read_value_2 ;
  reg [31:0] decode_execution_immediate ;
  reg [5:0] decode_execution_funct ;
  reg [4:0] decode_execution_write_address ;
  reg decode_execution_r_type ;
  reg decode_execution_i_type ;
  reg decode_execution_valid ;

  always @(posedge clock)
  begin
    decode_execution_read_address_1 <= read_address_1_decode ;
    decode_execution_read_address_2 <= read_address_2_decode ;
    decode_execution_read_value_1 <= register_file_read_value_1 ;
    decode_execution_read_value_2 <= register_file_read_value_2 ;
    decode_execution_immediate <= immediate_sign_extend_decode ;
    decode_execution_write_address <= write_address_decode ;
    decode_execution_funct <= funct_decode ;
    decode_execution_r_type <= r_type_decode ;
    decode_execution_i_type <= i_type_decode ;
    decode_execution_valid <= valid_decode ;
  end

  /*******************/
  /* EXECUTION STAGE */
  /*******************/

  reg [31:0] register_value_1_execution ;
  reg [31:0] register_value_2_execution ;
  reg [31:0] alu_operand_1_execution ;
  reg [31:0] alu_operand_2_execution ;
  reg [31:0] alu_result_execution ;

  /* register forwarding */
  always @(*)
  begin
    /* register 1 */
    case (decode_execution_read_address_1)
      execution_memory_address:
        register_value_1_execution <= execution_memory_value ;
      memory_writeback_address:
        register_value_1_execution <= memory_writeback_value ;
      writeback_fetch_address:
        register_value_1_execution <= writeback_fetch_value ;
      default:
        register_value_1_execution <= decode_execution_read_value_1 ;
    endcase

    /* register 2 */
    case (decode_execution_read_address_2)
      execution_memory_address:
        register_value_2_execution <= execution_memory_value ;
      memory_writeback_address:
        register_value_2_execution <= memory_writeback_value ;
      writeback_fetch_address:
        register_value_2_execution <= writeback_fetch_value ;
      default:
        register_value_2_execution <= decode_execution_read_value_2 ;
    endcase
  end

  /* operand selection */
  always @(*)
  begin
    alu_operand_1_execution <= register_value_1_execution ;
    if (decode_execution_r_type)
      alu_operand_2_execution <= register_value_2_execution ;
    else
      alu_operand_2_execution <= decode_execution_immediate ;
  end

  /* alu operation */
  always @(*)
  begin
    /* addition */
    if (decode_execution_i_type || (decode_execution_funct == 6'h20))
      alu_result_execution <= 
        alu_operand_1_execution + alu_operand_2_execution ;
    /* subtraction */
    else if (decode_execution_funct == 6'h22)
      alu_result_execution <=
        alu_operand_1_execution - alu_operand_2_execution ;
    /* zero */
    else
      alu_result_execution <= 32'h0 ;
  end
  

  /* execution memory pipeline registers */
  reg [31:0] execution_memory_value ;
  reg [4:0] execution_memory_address ;
  reg execution_memory_valid ;

  always @(posedge clock)
  begin
    execution_memory_value <= alu_result_execution ;
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

  /* writeback fetch pipeline registers */
  reg [31:0] writeback_fetch_value ;
  reg [4:0] writeback_fetch_address ;

  always @(posedge clock)
  begin
    writeback_fetch_value <= memory_writeback_value ;
    writeback_fetch_address <= memory_writeback_address ;
  end

endmodule

