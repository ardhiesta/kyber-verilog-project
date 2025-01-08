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

`include "padder1x.v"
`timescale 1ns / 1ps
`define P 20

module tb_padder1;
    // Inputs
    reg clk;
    reg reset;
    reg [511:0] in;
    reg [1:0] byte_num;

    // Outputs
    wire [575:0] out;
    wire    out_ready;
    
    reg [575:0] wish;

    // Instantiate the Unit Under Test (UUT)
    padder1x uut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .byte_num(byte_num),
        .out(out),
        .out_ready(out_ready)
    );

    initial begin
        // monitor will display the value of variables whenever they change
        $monitor("time=%3d, clk=%b, reset=%b, in=%h, byte_num=%h,  out=%h, out_ready=%h \n", $time, clk, reset, in, byte_num, out, out_ready);

        // Initialize Inputs
        clk = 0;
        reset = 1;
        in = 0;
        byte_num = 0;

        // Wait 100 ns for global reset to finish
        // #100;

        // Add stimulus here
        // @ (negedge clk);

        in = {16{32'h90ABCDEF}};
        byte_num = 0;
        wish = {8'h6, 560'h0, 8'h80};
        check;

        in = {16{32'h90ABCDEF}};
        byte_num = 2;
        wish = {{16{32'h90ABCDEF}}, 8'h06, 48'h0, 8'h80};
        check;

        // #100
        in = {16{32'h90ABCDEF}};
        byte_num = 1;
        wish = {{8{32'h90ABCDEF}}, 8'h06, 304'h0, 8'h80};
        check;

        $display("Good!");
        $finish;
    end

    task check;
      begin
        // #(`P);
        #2;
        $display("out=%h", out);
        if (out !== wish)
          begin
            $display("E");
            $finish;
          end
      end
    endtask
endmodule

`undef P
