// Binary to DIGITS decimal digits by double dabble, least significant digit
// in the low four bits
module to_digits
  #(parameter WIDTH = 8,
    parameter DIGITS = 3)
  (input wire [WIDTH-1:0]    bin,
   output reg [4*DIGITS-1:0] digits);

   integer i, j;

   always @* begin
      digits = 0;
      for (i = WIDTH-1; i >= 0; i = i - 1) begin
         // Add 3 to every digit of 5 or more, so that the shift carries at 10
         for (j = 0; j < DIGITS; j = j + 1)
           if (digits[4*j+:4] >= 4'd5)
             digits[4*j+:4] = digits[4*j+:4] + 4'd3;
         digits = {digits[4*DIGITS-2:0], bin[i]};
      end
   end

endmodule
