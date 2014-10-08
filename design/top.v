module top (

  input [17:0] SW,
  input [3:0] KEY,
  input CLOCK_50,
  inout [7:0] LCD_DATA,
  output LCD_RW, LCD_EN, LCD_RS, LCD_BLON, LCD_ON,
  output [6:0] HEX7, HEX6, HEX3, HEX2, HEX1, HEX0,
  output [17:0] LEDR

) ;
  
  wire [31:0] data_memory_value ;
  wire [31:0] data_memory_address ;
  wire [4:0] register_address ;
  wire [31:0] register_value ;
  wire [31:0] instruction_memory_value ;
  wire [31:0] instruction_memory_address ;
  wire [1:0] LCD_value_select ;
  wire clock_control ;
  wire manual_clock ;
  wire push_button_debounced ;
  wire clock_1hz ;
  wire clock_100hz ;
  wire clock_50Mhz ;

  reg clock ;
  reg [15:0] clock_count ;
  reg [31:0] value ;
  reg [31:0] address ;
  reg register_reset ;

  assign register_address = SW[4:0] ;
  assign data_memory_address = SW[9:5] ;
  assign instruction_memory_address = SW[14:10] ;
  assign clock_control = SW[17] ;
  assign clock_50Mhz = CLOCK_50 ;
  assign LCD_value_select = SW[16:15] ;
  assign LCD_ON = 1'b1 ;
  assign LCD_BLON = 1'b1 ;

  /* extract 1hz clock */
  clk_div(clock_50Mhz,,,,,clock_100hz,,clock_1hz) ;

  /* debounce pushbutton */
  debounce(KEY[1], clock_100hz, push_button_debounced) ;

  /* One pulse pushbutton */
  onepulse(push_button_debounced, clock_1hz, manual_clock) ;

  /* set clock */
  always @(clock_control)
  begin
    if (clock_control == 0)
      clock = manual_clock ;
    else
      clock = clock_1hz ;
  end

  /* update counter */
  always @(posedge clock or negedge KEY[0])
  begin
    if (~KEY[0])
      clock_count = 0 ;
    else
      clock_count = clock_count + 1 ;
  end

  /* reset register when clock count is zero */
  always @(clock_count)
  begin
    if (clock_count == 0)
      register_reset = 1 ;
    else
      register_reset = 0 ;
  end

  /* register file */
  register_file(5'b0, 5'b0, 1'b0, register_reset, clock, 5'b0, 32'b0, 
                  clock, register_address,,, register_value) ;
  
  /* data memory */
  ramlpm(data_memory_address, clock, 32'b0, 1'b0, data_memory_value) ;

  /* instruction memory */
  romlpm(instruction_memory_address, clock, instruction_memory_value) ;

  /* choose value and address */
  always @(LCD_value_select)
  begin
    if (LCD_value_select == 2'b00)
    begin
      address = {27'b0, register_address} ;
      value = register_value ;
    end
    else if (LCD_value_select == 2'b01)
    begin
      address = data_memory_address ;
      value = data_memory_value ;
    end
    else if (LCD_value_select == 2'b10)
    begin
      address = instruction_memory_address ;
      value = instruction_memory_value ;
    end
    else
    begin
      address = 32'b0 ;
      value = 32'b0 ;
    end
  end

  /* show memory address on HEX6 and HEX7 */
  hexdigit(address[3:0],HEX6[6:0]) ;
  hexdigit({3'b0,address[4]},HEX7[6:0]) ;

  /* show clock count on HEX3 through HEX0 */
  hexdigit(clock_count[3:0], HEX0[6:0]) ;
  hexdigit(clock_count[7:4], HEX1[6:0]) ;
  hexdigit(clock_count[11:8], HEX2[6:0]) ;
  hexdigit(clock_count[15:12], HEX3[6:0]) ;

  /* LCD Display */
  LCD_Display(1'b1, clock_50Mhz, {instruction_memory_value, value},
               LCD_RS, LCD_EN, LCD_RW, LCD_DATA[7:0]) ;
  
endmodule
