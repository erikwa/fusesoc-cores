// Prints the first COUNT Fibonacci numbers on seven-segment digits
`include "segments.vh"
`include "ansi.vh"

module sevenseg_tb
  #(parameter COUNT = 20,
    parameter WIDTH = 14,
    parameter DIGITS = 5,
    parameter LEADING_ZEROS = 0);

   reg [WIDTH-1:0]     a, b, value;
   wire [4*DIGITS-1:0] digits;
   wire [7*DIGITS-1:0] segs;
   reg [6:0]           s;
   reg                 blank;
   integer             n, row, i;

   to_digits #(.WIDTH(WIDTH), .DIGITS(DIGITS)) conv
     (.bin(value), .digits(digits));

   genvar g;
   generate
      for (g = 0; g < DIGITS; g = g + 1) begin : digit
         seg7 dec (.digit(digits[4*g+:4]), .segs(segs[7*g+:7]));
      end
   endgenerate

   // A lit segment is drawn as `ch` in red, an unlit one as a space
   task draw(input lit, input [7:0] ch);
      if (lit)
        $write("%s", `ANSI("1;31", ch));
      else
        $write(" ");
   endtask

   initial begin
      a = 0;
      b = 1;
      for (n = 1; n <= COUNT; n = n + 1) begin
         value = b;
         b = a + b;
         a = value;
         #1;
         for (row = 0; row < 3; row = row + 1) begin
            blank = !LEADING_ZEROS;
            for (i = DIGITS-1; i >= 0; i = i - 1) begin
               // Blank the leading zeros, but never the last digit
               blank = blank && i > 0 && digits[4*i+:4] == 4'd0;
               s = blank ? 7'd0 : segs[7*i+:7];
               case (row)
                 0: begin
                    $write(" ");
                    draw(s[`SEG_A], "_");
                    $write(" ");
                 end
                 1: begin
                    draw(s[`SEG_F], "|");
                    draw(s[`SEG_G], "_");
                    draw(s[`SEG_B], "|");
                 end
                 default: begin
                    draw(s[`SEG_E], "|");
                    draw(s[`SEG_D], "_");
                    draw(s[`SEG_C], "|");
                 end
               endcase
               $write(" ");
            end
            if (row == 2)
              $write("  F(%0d)", n);
            $write("\n");
         end
      end
      $finish;
   end

endmodule
