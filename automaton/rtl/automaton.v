// One-dimensional cellular automaton: each clock, every cell takes bit
// {left, self, right} of RULE. Cells beyond the edges are dead.
module automaton
  #(parameter WIDTH = 80,
    parameter RULE = 90,
    parameter SEED_POS = 40)
  (input wire             clk,
   input wire             rst,
   output reg [WIDTH-1:0] cells);

   localparam [7:0] TABLE = RULE[7:0];

   wire [WIDTH+1:0] padded = {1'b0, cells, 1'b0};
   integer          i;

   always @(posedge clk)
     if (rst)
       cells <= {{WIDTH-1{1'b0}}, 1'b1} << SEED_POS;
     else
       for (i = 0; i < WIDTH; i = i + 1)
         cells[i] <= TABLE[padded[i+:3]];

endmodule
