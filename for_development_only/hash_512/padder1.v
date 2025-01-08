/* 
original code from ...
modified by Ardhi Wijayanto
*/
module padder1(in, byte_num, out);
    input      [511:0] in;
    input      [1:0]  byte_num; // 0, 1=32byte, 2=64byte
    output reg [519:0] out;

    always @ (*)
      case (byte_num)
        0: out = {8'h6, 568'h0}; // 0 byte message
        1: out = {in[255:0], 8'h06, 248'h0}; //32B 
        2: out = {in, 8'h06}; //64B
      endcase
endmodule