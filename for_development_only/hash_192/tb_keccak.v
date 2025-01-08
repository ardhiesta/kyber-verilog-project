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
`include "padder1ky.v"
`include "round.v"
`include "rconst.v"
`include "f_permutation.v"
`timescale 1ns / 1ps
`define P 20

module tb_keccak;

    // Inputs
    reg clk;
    reg reset;
    reg [191:0] in;
    reg in_ready;
    reg is_last;
    reg [5:0] byte_num;

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
        // correct output at time=850
        //TODO: cek out_ready
        $monitor("time=%3d, clk=%b, reset=%b, in=%h, out=%h,out_ready=%h, byte_num=%h, uut.i=%b \n", 
        $time, clk, reset, in, out, out_ready, byte_num, uut.i);

        $dumpfile("test.vcd");
        $dumpvars(0, tb_keccak);

        // Initialize Inputs
        clk = 0;
        reset = 0;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0; //input 23 byte (184 bit)

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

        //custom, input 32 byte 
        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1;
        in = 192'h90ABCDEF1a1b1c1d90ABCDEF1a1b1c1d90ABCDEF1a1b1c1d; 
        byte_num = 23;
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;
        while (out_ready !== 1)
            #(`P);
        check(512'h4ec801ad18daa74c1139259ec8b382e5a490dbe85fcedf81274557e1233a71c508397e467cae022488a3455e0acef98470300b6488154c8821011b959a6c611e);

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

/*

192
input
90ABCDEF1a1b1c1d90ABCDEF1a1b1c1d90ABCDEF1a1b1c1d
23 byte
90ABCDEF1a1b1c1d90ABCDEF1a1b1c1d90ABCDEF1a1b1c
sha3 512
19f017df29867d4bb6c80e738e61398f6570a94453334b81f75968eac7b87e008d0b7c2c22ce23a17e6dd44697b4b9e6428d7601b41a6ac855b2ddb98d480b6c
*/