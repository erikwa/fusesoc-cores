// Prints GENERATIONS rows of the automaton, leftmost cell first
module automaton_tb
  #(parameter WIDTH = 80,
    parameter RULE = 90,
    parameter SEED_POS = 40,
    parameter GENERATIONS = 40,
    parameter GEN_BITS = 6,
    parameter TITLE = "automaton");

   reg               clk;
   reg               rst = 1'b1;
   reg [GEN_BITS-1:0] gen = 0;
   wire [WIDTH-1:0]  cells;
   integer           i;

   automaton #(.WIDTH(WIDTH), .RULE(RULE), .SEED_POS(SEED_POS)) dut
     (.clk(clk), .rst(rst), .cells(cells));

   initial begin
      clk = 1'b0;
      forever #5 clk = ~clk;
   end

   initial begin
      $display("%0s", TITLE);
      @(negedge clk) rst = 1'b0;
      repeat (GENERATIONS) begin
         for (i = WIDTH-1; i >= 0; i = i - 1)
           $write("%s", cells[i] ? "#" : " ");
         $write("\n");
         gen = gen + 1;
         @(negedge clk);
      end
      $display("%0d generations", gen);
      $finish;
   end

endmodule
