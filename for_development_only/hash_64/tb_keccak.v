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
    reg [63:0] in;
    reg in_ready;
    reg is_last;
    reg [2:0] byte_num;

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
        $monitor("time=%3d, clk=%b, reset=%b, in=%h, out=%h,out_ready=%h, byte_num=%h, uut.i=%b, uut.padder_out=%h, uut.padder_out_1=%h \n", 
        $time, clk, reset, in, out, out_ready, byte_num, uut.i, uut.padder_out, uut.padder_out_1);

        $dumpfile("test.vcd");
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

        //custom, input 32 byte 
        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1;
        in = 64'hfc7b8cdafc7b8cda; #(`P);
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;
        while (out_ready !== 1)
            #(`P);
        check(512'h58a5422d6b15eb1f223ebe4f4a5281bc6824d1599d979f4c6fe45695ca89014260b859a2d46ebf75f51ff204927932c79270dd7aef975657bb48fe09d8ea008e);

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