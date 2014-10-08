/* file hexdigit.v
 * converts a four bit number to its 
 * corresponding seven segment representation
 */

module hexdigit (in, out) ;

  input [3:0] in ;
  output reg [6:0] out ;

  always @* begin

    if (in == 4'h0)
      out = 7'b1000000 ;
    else if (in == 4'h1)
      out = 7'b1111001 ;
    else if (in == 4'h2)
      out = 7'b0100100 ;
    else if (in == 4'h3)
      out = 7'b0110000 ;
    else if (in == 4'h4)
      out = 7'b0011001 ;
    else if (in == 4'h5)
      out = 7'b0010010 ;
    else if (in == 4'h6)
      out = 7'b0000010 ;
    else if (in == 4'h7)
      out = 7'b1111000 ;
    else if (in == 4'h8)
      out = 7'b0000000 ;
    else if (in == 4'h9)
      out = 7'b0011000 ;
    else if (in == 4'ha)
      out = 7'b0001000 ;
    else if (in == 4'hb)
      out = 7'b0000011 ;
    else if (in == 4'hc)
      out = 7'b0100111 ;
    else if (in == 4'hd)
      out = 7'b0100001 ;
    else if (in == 4'he)
      out = 7'b0000110 ;
    else if (in == 4'hf)
      out = 7'b0001110 ;
    else
      out = 7'b1111111 ;

  end

endmodule
