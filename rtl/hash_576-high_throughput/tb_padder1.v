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

`include "padder1.v"
`timescale 1ns / 1ps
`define P 20

module tb_padder1;

    // Inputs
    reg [575:0] in;
    reg [10:0] byte_num;

    // Outputs
    wire [575:0] out;
    
    reg [575:0] wish;

    // Instantiate the Unit Under Test (UUT)
    padder1 uut (
        .in(in),
        .byte_num(byte_num),
        .out(out)
    );

    initial begin
        // Initialize Inputs
        in = 0;
        byte_num = 0;

        // Wait 100 ns for global reset to finish
        #100;

        in = {9{64'h90ABCDEF11111111}};
        byte_num = 32; // 3 bytes / 24 bit
        wish = 575'h90ABCD0600000000;
        check;

        $display("Good!");
        $finish;
    end

    task check;
      begin
        #(`P);
        $display("in=%h out=%h", in, out);
        if (out !== wish)
          begin
            $display("E");
            $finish;
          end
      end
    endtask
endmodule

`undef P
