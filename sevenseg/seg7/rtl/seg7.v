// Hex digit to seven segments, in the bit order of segments.vh
`include "segments.vh"
`include "seg7_style.vh"

module seg7
  (input wire [3:0] digit,
   output reg [6:0] segs);

   // The lit segments, a first
   reg [6:0] abcdefg;

   always @* begin
      case (digit)
        4'h0: abcdefg = 7'b1111110;
        4'h1: abcdefg = 7'b0110000;
        4'h2: abcdefg = 7'b1101101;
        4'h3: abcdefg = 7'b1111001;
        4'h4: abcdefg = 7'b0110011;
        4'h5: abcdefg = 7'b1011011;
        4'h6: abcdefg = `SEG7_TAILS ? 7'b1011111 : 7'b0011111;
        4'h7: abcdefg = `SEG7_TAILS ? 7'b1110010 : 7'b1110000;
        4'h8: abcdefg = 7'b1111111;
        4'h9: abcdefg = `SEG7_TAILS ? 7'b1111011 : 7'b1110011;
        4'ha: abcdefg = 7'b1110111;
        4'hb: abcdefg = 7'b0011111;
        4'hc: abcdefg = 7'b1001110;
        4'hd: abcdefg = 7'b0111101;
        4'he: abcdefg = 7'b1001111;
        4'hf: abcdefg = 7'b1000111;
      endcase
      segs[`SEG_A] = abcdefg[6];
      segs[`SEG_B] = abcdefg[5];
      segs[`SEG_C] = abcdefg[4];
      segs[`SEG_D] = abcdefg[3];
      segs[`SEG_E] = abcdefg[2];
      segs[`SEG_F] = abcdefg[1];
      segs[`SEG_G] = abcdefg[0];
   end

endmodule
