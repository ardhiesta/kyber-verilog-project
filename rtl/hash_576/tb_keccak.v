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
`include "keccak.v"
`include "padder.v"
`include "padder1.v"
`include "round.v"
`include "rconst.v"
`include "f_permutation.v"
`timescale 1ns / 1ps
`define P 20

module tb_keccak;

    // Inputs
    reg clk;
    reg reset;
    reg [575:0] in;
    reg in_ready;
    reg is_last;
    reg [9:0] byte_num;

    // Outputs
    wire buffer_full;
    wire [511:0] out;
    wire out_ready;

    // Var
    // integer i;

    // Instantiate the Unit Under Test (UUT)
    keccak uut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .in_ready(in_ready),
        .is_last(is_last),
        .byte_num(byte_num),
        .buffer_full(buffer_full),
        .out(out),
        .out_ready(out_ready)
    );

    initial begin
        $monitor("time=%3d, clk=%b, reset=%b, in=%h, out=%h,out_ready=%h, byte_num=%h, uut.i=%b, uut.padder_out=%h, uut.padder_out_1=%h \n", 
        $time, clk, reset, in, out, out_ready, byte_num, uut.i, uut.padder_out, uut.padder_out_1);

        $dumpfile("tb_keccak.vcd");
        $dumpvars(0, tb_keccak);

        // Initialize Inputs
        clk = 0;
        reset = 0;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1;
        // in = {9{64'h90ABCDEF1c1a1b1f}};
        in = 512'h56ac4f6845a451dac3e8886f97f7024b64b1b1e9c5181c059b5755b9a6042be653a2a0d5d56a9e1e774be5c9312f48b4798019345beae2ffcc63554a3c69862e;
        byte_num = 64;
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;
        while (out_ready !== 1)
            #(`P);
        check(512'h5fde5c57a31febb98061f27e4506fa5c245506336ee90d595c91d791a5975c712b3ab9b3b5868f941db0aeb4c6d2837c4447442f8402e0e150a9dc0ef178dca8);

        $display("Good!");
        $finish;
    end

    always #(`P/2) clk = ~ clk;

    task error;
        begin
              $display("E");
              $finish;
        end
    endtask

    task check;
        input [511:0] wish;
        begin
          if (out !== wish)
            begin
              $display("%h %h", out, wish); error;
            end
        end
    endtask
endmodule

`undef P