// Iterates z = z^2 + c in signed fixed point with FRAC fraction bits, from
// z0 until |z| > 2 (escaped) or MAX_ITER iterations. start loads z0 and c.
module escape_time
  #(parameter BITS = 32,
    parameter FRAC = 26,
    parameter MAX_ITER = 64,
    parameter ITER_BITS = 7)
  (input wire                  clk,
   input wire                  start,
   input wire signed [BITS-1:0] z0_re,
   input wire signed [BITS-1:0] z0_im,
   input wire signed [BITS-1:0] c_re,
   input wire signed [BITS-1:0] c_im,
   output reg                  done,
   output reg                  escaped,
   output reg [ITER_BITS-1:0]  iter);

   localparam signed [2*BITS-1:0] FOUR = 4 <<< FRAC;
   localparam [ITER_BITS-1:0]     LAST = MAX_ITER[ITER_BITS-1:0];

   reg signed [BITS-1:0]   zr, zi;
   wire signed [2*BITS-1:0] rr = zr * zr;
   wire signed [2*BITS-1:0] ii = zi * zi;
   wire signed [2*BITS-1:0] ri = zr * zi;
   // |z|^2 at full width, so it cannot overflow before the escape check
   wire signed [2*BITS-1:0] mag = (rr + ii) >>> FRAC;
   wire signed [2*BITS-1:0] sq_re = (rr - ii) >>> FRAC;
   wire signed [2*BITS-1:0] sq_im = ri >>> (FRAC - 1);
   // While |z| <= 2, z^2 + c fits in BITS
   wire signed [BITS-1:0]   next_re = sq_re[BITS-1:0] + c_re;
   wire signed [BITS-1:0]   next_im = sq_im[BITS-1:0] + c_im;

   always @(posedge clk)
     if (start) begin
        zr      <= z0_re;
        zi      <= z0_im;
        iter    <= 0;
        done    <= 1'b0;
        escaped <= 1'b0;
     end else if (!done) begin
        if (mag > FOUR) begin
           done    <= 1'b1;
           escaped <= 1'b1;
        end else if (iter == LAST) begin
           done <= 1'b1;
        end else begin
           zr   <= next_re;
           zi   <= next_im;
           iter <= iter + 1'b1;
        end
     end

endmodule
