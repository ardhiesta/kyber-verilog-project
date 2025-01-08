/* 
original code from ...
modified by Ardhi Wijayanto
*/
module padder1x(clk, reset, in, byte_num, out, out_ready);
  input              clk, reset;
  input      [511:0] in;
  input      [1:0]   byte_num; // 0, 1=32byte, 2=64byte
  output reg [575:0] out;
  output reg    out_ready;

  always @ (posedge clk)
    begin
      if (reset) 
        out <= 0;
      /*if (out !== 0 && in !== 0 && in !== 'bx && in !== 'bz) //dibuat begini out_ready udah ok, tp malah ada looping forever
        out_ready <= 1;*/
    end

  always @ (*)
    case (byte_num)
    /*
      0: out = {8'h6, 560'h0, 8'h80}; // 0 byte message
      1: out = {in[255:0], 8'h06, 304'h0, 8'h80}; //32B 
      2: out = {in, 8'h06, 48'h0, 8'h80}; //64B
*/
      0: begin
        out = {8'h6, 560'h0, 8'h80}; // 0 byte message
        out_ready = 1;
      end
      1: begin 
        out = {in[255:0], 8'h06, 304'h0, 8'h80}; //32B 
        out_ready = 1;
      end
      2: begin 
        out = {in, 8'h06, 48'h0, 8'h80}; //64B
        out_ready = 1;
      end
    endcase
endmodule