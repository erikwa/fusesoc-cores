// Prints ROWS x COLS pixels starting at (X0, Y0), stepping DX right and DY
// down. A Mandelbrot pixel is c with z0 = 0, a Julia pixel is z0 with c = C.
// Pixels that escape fast print as space, slower ones as later CHARS, and
// pixels inside the set as the last of CHARS.
module fractal_tb
  #(parameter BITS = 32,
    parameter FRAC = 26,
    parameter MAX_ITER = 64,
    parameter ITER_BITS = 7,
    parameter COLS = 80,
    parameter ROWS = 32,
    parameter X0 = 0,
    parameter Y0 = 0,
    parameter DX = 1,
    parameter DY = 1,
    parameter JULIA = 0,
    parameter C_RE = 0,
    parameter C_IM = 0,
    parameter CHARS = "#");

   localparam NCHARS = $bits(CHARS) / 8;

   reg                   clk;
   reg                   start = 1'b0;
   wire signed [BITS-1:0] zero = 0;
   wire                  done, escaped;
   wire [ITER_BITS-1:0]  iter;
   integer               row, col, idx, px, py;

   escape_time #(.BITS(BITS), .FRAC(FRAC), .MAX_ITER(MAX_ITER), .ITER_BITS(ITER_BITS)) dut
     (.clk(clk), .start(start),
      .z0_re(JULIA ? px[BITS-1:0] : zero), .z0_im(JULIA ? py[BITS-1:0] : zero),
      .c_re(JULIA ? C_RE[BITS-1:0] : px[BITS-1:0]), .c_im(JULIA ? C_IM[BITS-1:0] : py[BITS-1:0]),
      .done(done), .escaped(escaped), .iter(iter));

   initial begin
      clk = 1'b0;
      forever #5 clk = ~clk;
   end

   initial begin
      for (row = 0; row < ROWS; row = row + 1) begin
         for (col = 0; col < COLS; col = col + 1) begin
            px = X0 + col * DX;
            py = Y0 - row * DY;
            @(negedge clk) start = 1'b1;
            @(negedge clk) start = 1'b0;
            while (!done) @(negedge clk);
            idx = escaped ? iter * NCHARS / MAX_ITER : NCHARS;
            if (idx == 0)
              $write(" ");
            else
              $write("%s", CHARS[(NCHARS-idx)*8 +: 8]);
         end
         $write("\n");
      end
      $finish;
   end

endmodule
