// modified from from https://github.com/freecores/sha3
/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 *     in      byte_num     out
 * 0x11223344      0    0x06000000    input 0
 * 0x11223344      1    0x11060000    input 1 byte
 * 0x11223344      2    0x11220600    input 2 byte
 * 0x11223344      3    0x11223306    input 3 byte

 adjust with SHA3 input size
 SHA3-512:  256
            512
  r: 576
 SHA3-256:  6400
            256
            6144
  r: 1088

 how to handle SHA3-256 when input 6400 > r?
 breaking input into r-bit sized chunks, then absorb
 in the absorbing phase, message blocks are XORed into a subset of the state, then squeez
 in the squeezing phase, run permutation function

 in Kyber, SHA3-512 has 2 input sizes : 32 bytes and 64 bytes
 byte_num   in    out
 32
 64

 TODO: modify input SHA3-512 to take 32 or 64 bytes message
 but first create test, modify existing code to 64-bit, 128-bit input (previous version is 32-bit)
 is it better if input larger? or better if using buffer like existing code?

 this is experiment version to try 64-bit input
 */

module padder1ky(in, byte_num, out);
    input      [191:0] in;
    input      [5:0]  byte_num; // 3-bit, max value: 7
    output reg [191:0] out;
    
    always @ (*)
      case (byte_num)
      // change pad data to latest SHA3 specs from NIST 
      // original version
      // ex: 1 byte input --> {in[31:24], 24'h060000}; means [31:24] message + [23:0] 24'h060000

        // testing, 0: 0 byte, 1: 7 byte
        0: out = 192'h60000000000000000000000000000000000000000000000; // 0 byte message
        1: out = {in[191:184], 184'h0600000000000000000000000000000000000000000000};
        2: out = {in[191:176], 176'h06000000000000000000000000000000000000000000};
        3: out = {in[191:168], 168'h060000000000000000000000000000000000000000};
        4: out = {in[191:160], 160'h0600000000000000000000000000000000000000};
        5: out = {in[191:152], 152'h06000000000000000000000000000000000000};
        6: out = {in[191:144], 144'h060000000000000000000000000000000000};
        7: out = {in[191:136], 136'h0600000000000000000000000000000000};  // 7 byte: [191:8] message + [7:0] 8'h06
        8: out = {in[191:128], 128'h06000000000000000000000000000000};
        9: out = {in[191:120], 120'h060000000000000000000000000000};
        10: out = {in[191:112], 112'h0600000000000000000000000000};
        11: out = {in[191:104], 104'h06000000000000000000000000};
        12: out = {in[191:96], 96'h060000000000000000000000};
        13: out = {in[191:88], 88'h0600000000000000000000};
        14: out = {in[191:80], 80'h06000000000000000000};
        15: out = {in[191:72], 72'h060000000000000000};
        16: out = {in[191:64], 64'h0600000000000000};
        17: out = {in[191:56], 56'h06000000000000};
        18: out = {in[191:48], 48'h060000000000};
        19: out = {in[191:40], 40'h0600000000};
        20: out = {in[191:32], 32'h06000000};
        21: out = {in[191:24], 24'h060000};
        22: out = {in[191:16], 16'h0600};
        23: out = {in[191:8], 8'h06};
      endcase
endmodule
