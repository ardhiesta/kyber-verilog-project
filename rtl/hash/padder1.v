// copied from https://github.com/freecores/sha3
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
 */

module padder1(in, byte_num, out);
    input      [31:0] in;
    input      [1:0]  byte_num;
    output reg [31:0] out;
    
    always @ (*)
      case (byte_num)
      // change pad data to latest SHA3 specs from NIST 
        0: out = 32'h6000000;
        1: out = {in[31:24], 24'h060000};
        2: out = {in[31:16], 16'h0600};
        3: out = {in[31:8],   8'h06};
      endcase
endmodule
