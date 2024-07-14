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

`include "../rtl/pad/padder1.v"
`timescale 1ns / 1ps
`define P 20

module tb_padder1;

    // Inputs
    reg [31:0] in;
    reg [1:0] byte_num;

    // Outputs
    wire [31:0] out;
    
    reg [31:0] wish;

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

        // in : 10010000101010111100110111101111
        // byte_num = 0, ganti semua input dengan pad 32'h06
        // out: 00000110000000000000000000000000

        // note (in Indonesian):
        // h06 = 00000110
        // tapi di sejumlah dokumentasi lain, penulisan dibalik jadi 01100000

        // byte_num = 1, ganti [31:24] (24 digit pertama dr kiri) dengan pad 24'h060000
        // out: 10010000000001100000000000000000
        // byte_num = 2, ganti [31:16] (16 digit pertama dr kiri) dengan pad 16'h06
        // out: 10010000101010110000011000000000
        // byte_num = 3, ganti [31:8] (8 digit pertama dr kiri) dengan pad 8'h06
        // out: 10010000101010111100110100000110

        // Add stimulus here
        in = 32'b10010000101010111100110111101111;
        byte_num = 0;
        wish = 32'b00000110000000000000000000000000;
        check;
        byte_num = 1;
        wish = 32'b10010000000001100000000000000000;
        check;
        byte_num = 2;
        wish = 32'b10010000101010110000011000000000;
        check;
        byte_num = 3;
        wish = 32'b10010000101010111100110100000110;
        check;
        $display("Good!");
        $finish;
    end

    task check;
      begin
        #(`P);
        if (out !== wish)
          begin
            $display("E");
            $finish;
          end
      end
    endtask
endmodule

`undef P
