// Binary to DIGITS hex digits, least significant digit in the low four bits
module to_digits
  #(parameter WIDTH = 8,
    parameter DIGITS = 2)
  (input wire [WIDTH-1:0]     bin,
   output wire [4*DIGITS-1:0] digits);

   wire [4*DIGITS+WIDTH-1:0] padded = {{4*DIGITS{1'b0}}, bin};

   assign digits = padded[4*DIGITS-1:0];

endmodule
