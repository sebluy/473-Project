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
      PC <= 0 ;
    else if (jr_decode)
      PC <= read_value_1_decode ;
    else if (branch_decode && branch_taken_decode)
      PC <= PC + branch_address_decode ;
    else
      PC <= PC + 4 ;
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
  wire funct_valid_decode ;
  wire shamt_valid_decode ;
  
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
  wire [31:0] immediate_sign_extend_decode ;
  assign immediate_sign_extend_decode = 
    { {16{immediate_decode[15]}}, immediate_decode } ;

  /* create branch address from immediate number */
  wire [31:0] branch_address_decode ;
  assign branch_address_decode = 
    { {14{immediate_decode[15]}}, immediate_decode, 2'b0 } ;

  `define BEQ 6'h4
  `define BNE 6'h5
  `define ADDIU 6'h9 
  `define ORI 6'hd 
  `define ANDI 6'hc 
  `define SLTI 6'ha 
  `define ADDI 6'h8 
  `define LUI 6'hf 
  /* assign instruction type */
  assign r_type_decode = opcode_decode == 6'h0 ;
  assign i_type_decode = 
    opcode_decode == `BEQ ||
    opcode_decode == `BNE ||
    opcode_decode == `ADDIU ||
    opcode_decode == `ORI ||
    opcode_decode == `ANDI ||
    opcode_decode == `SLTI ||
    opcode_decode == `ADDI ||
    opcode_decode == `LUI ;

  `define SLL 6'h00 
  `define SRL 6'h02 
  `define SRA 6'h03 
  wire shift_funct_decode ;
  assign shift_funct_decode = 
    funct_decode == `SLL ||
    funct_decode == `SRL ||
    funct_decode == `SRA ;

  `define ADD 6'h20 
  `define ADDU 6'h21 
  `define SUB 6'h22 
  `define SUBU 6'h23 
  `define AND 6'h24 
  `define OR 6'h25 
  `define NOR 6'h27 
  `define SLT 6'h2a 
  `define JR 6'h08 
  assign funct_valid_decode = 
    funct_decode == `ADD ||
    funct_decode == `ADDU ||
    funct_decode == `SUB ||
    funct_decode == `SUBU ||
    funct_decode == `AND ||
    funct_decode == `OR ||
    funct_decode == `NOR ||
    funct_decode == `SLT ||
    funct_decode == `JR ||
    shift_funct_decode ;

  assign shamt_valid_decode = shift_funct_decode || 
    (!shamt_decode && !shift_funct_decode) ;

  /* check to see if instruction is valid */
  wire valid_decode ;
  assign valid_decode = i_type_decode ||
        (r_type_decode && funct_valid_decode && shamt_valid_decode) ;

  `define ZERO 4'h0 
  `define ADD_OP 4'h1 
  `define SUB_OP 4'h2 
  `define AND_OP 4'h3 
  `define OR_OP 4'h4 
  `define NOR_OP 4'h5 
  `define LESS_THAN_OP 4'h6 
  `define LOGICAL_SHIFT_LEFT_OP 4'h7 
  `define LOGICAL_SHIFT_LEFT_16_OP 4'h8 
  `define LOGICAL_SHIFT_RIGHT_OP 4'h9 
  `define ARITHMETIC_SHIFT_RIGHT_OP 4'ha 

  /* decode operator */
  reg [3:0] op_decode ;

  always @(*)
  begin
    if (r_type_decode)
    begin
      case (funct_decode)
      `ADD: op_decode <= `ADD_OP ;
      `ADDU: op_decode <= `ADD_OP ;
      `SUB: op_decode <= `SUB_OP ;
      `SUBU: op_decode <= `SUB_OP ;
      `AND: op_decode <= `AND_OP ;
      `OR: op_decode <= `OR_OP ;
      `NOR: op_decode <= `NOR_OP ;
      `SLT: op_decode <= `LESS_THAN_OP ;
      `SLL: op_decode <= `LOGICAL_SHIFT_LEFT_OP ;
      `SRL: op_decode <= `LOGICAL_SHIFT_RIGHT_OP ;
      `SRA: op_decode <= `ARITHMETIC_SHIFT_RIGHT_OP ;
      default: op_decode <= `ZERO ;
      endcase
    end
    else if (i_type_decode)
    begin 
      case (opcode_decode)
      `ADDIU: op_decode <= `ADD_OP ;
      `ADDI: op_decode <= `ADD_OP ;
      `LUI: op_decode <= `LOGICAL_SHIFT_LEFT_16_OP ;
      `SLTI: op_decode <= `LESS_THAN_OP ;
      `ANDI: op_decode <= `AND_OP ;
      `ORI: op_decode <= `OR_OP ;
      default: op_decode <= `ZERO ;
      endcase
    end
    else
      op_decode <= `ZERO ;
  end

  /* check instruction to see if the pc will need to be changed */

  /* check if decoding a jr instruction */
  wire jr_decode ;
  assign jr_decode = 
    funct_decode == `JR && r_type_decode && valid_decode ;
  
  /* branch equal */
  wire branch_equal_decode ;
  assign branch_equal_decode = opcode_decode == `BEQ ;

  /* branch not equal */
  wire branch_not_equal_decode ;
  assign branch_not_equal_decode = opcode_decode == `BNE ;

  /* check if decoding a branch instruction */
  wire branch_decode ;
  assign branch_decode = branch_equal_decode || branch_not_equal_decode ;

  /* insert bubble if instruction invalid or jr */
  wire bubble_decode ;
  assign bubble_decode = !valid_decode || jr_decode || branch_decode ;

  /* assign inputs to register file */
  always @(*)
  begin
    read_address_1_decode <= rs_decode ;
    read_address_2_decode <= rt_decode ;
    if (r_type_decode)
      write_address_decode <= rd_decode ;
    else if (i_type_decode)
      write_address_decode <= rt_decode ;
  end

  /* read from register file */
  assign register_file_read_address_1 = read_address_1_decode ;
  assign register_file_read_address_2 = read_address_2_decode ;

  /* forwarding registers */
  reg [31:0] read_value_1_decode ;
  reg [31:0] read_value_2_decode ;

  /* register forwarding */
  always @(*)
  begin
    /* register 1 */
    case (read_address_1_decode)
      decode_execution_write_address:
        read_value_1_decode <= alu_result_execution ;
      execution_memory_address:
        read_value_1_decode <= execution_memory_value ;
      memory_writeback_address:
        read_value_1_decode <= memory_writeback_value ;
      default:
        read_value_1_decode <= register_file_read_value_1 ;
    endcase

    /* register 2 */
    case (read_address_2_decode)
      decode_execution_write_address:
        read_value_2_decode <= alu_result_execution ;
      execution_memory_address:
        read_value_2_decode <= execution_memory_value ;
      memory_writeback_address:
        read_value_2_decode <= memory_writeback_value ;
      default:
        read_value_2_decode <= register_file_read_value_2 ;
    endcase
  end

  /* compare decode values to see if they are equal */
  wire zero_decode ;
  assign zero_decode = read_value_1_decode == read_value_2_decode ;

  /* decide whether branch should be taken or not */
  wire branch_taken_decode ;
  assign branch_taken_decode = (zero_decode && branch_equal_decode) || 
    (!zero_decode && branch_not_equal_decode) ;

  /* decode execution pipeline registers */
  reg [31:0] decode_execution_read_value_1 ;
  reg [31:0] decode_execution_read_value_2 ;
  reg [31:0] decode_execution_immediate ;
  reg [3:0] decode_execution_op ;
  reg [4:0] decode_execution_shamt ;
  reg [4:0] decode_execution_write_address ;
  reg decode_execution_r_type ;
  reg decode_execution_i_type ;
  reg decode_execution_valid ;

  always @(posedge clock)
  begin
    decode_execution_read_value_1 <= read_value_1_decode ;
    decode_execution_read_value_2 <= read_value_2_decode ;
    decode_execution_immediate <= immediate_sign_extend_decode ;
    decode_execution_write_address <= write_address_decode ;
    decode_execution_op <= op_decode ;
    decode_execution_shamt <= shamt_decode ;
    decode_execution_r_type <= r_type_decode ;
    decode_execution_i_type <= i_type_decode ;
    decode_execution_valid <= !bubble_decode ;
  end

  /*******************/
  /* EXECUTION STAGE */
  /*******************/

  reg signed [31:0] alu_operand_1_execution ;
  reg signed [31:0] alu_operand_2_execution ;
  reg signed [31:0] alu_result_execution ;

    /* operand selection */
  always @(*)
  begin
    alu_operand_1_execution <= decode_execution_read_value_1 ;
    if (decode_execution_r_type)
      alu_operand_2_execution <= decode_execution_read_value_2 ;
    else if (decode_execution_i_type)
      alu_operand_2_execution <= decode_execution_immediate ;
  end

  /* alu operation */
  always @(*)
  begin
    case (decode_execution_op)

    `ADD_OP: alu_result_execution <=
      alu_operand_1_execution + alu_operand_2_execution ;

    `SUB_OP: alu_result_execution <=
      alu_operand_1_execution - alu_operand_2_execution ;

    `AND_OP: alu_result_execution <=
      alu_operand_1_execution & alu_operand_2_execution ;

    `OR_OP: alu_result_execution <=
      alu_operand_1_execution | alu_operand_2_execution ;

    `NOR_OP: alu_result_execution <=
      alu_operand_1_execution ^| alu_operand_2_execution ;

    `LESS_THAN_OP: alu_result_execution <=
      alu_operand_1_execution < alu_operand_2_execution ;

    `ARITHMETIC_SHIFT_RIGHT_OP: alu_result_execution <=
      alu_operand_2_execution >>> decode_execution_shamt ;

    `LOGICAL_SHIFT_RIGHT_OP: alu_result_execution <=
      alu_operand_2_execution >> decode_execution_shamt ;

    `LOGICAL_SHIFT_LEFT_OP: alu_result_execution <=
      alu_operand_2_execution << decode_execution_shamt ;

    `LOGICAL_SHIFT_LEFT_16_OP: alu_result_execution <=
      alu_operand_2_execution << 16 ;

    default: alu_result_execution <= 32'b0 ;
    endcase
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

endmodule

