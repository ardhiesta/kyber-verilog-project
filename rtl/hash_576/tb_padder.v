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
`include "padder.v"
`include "padder1ky.v"
`timescale 1ns / 1ps
`define P 20

module tb_padder;

    // Inputs
    reg clk;
    reg reset;
    reg [575:0] in;
    reg in_ready;
    reg is_last;
    reg [9:0] byte_num;
    reg f_ack;

    // Outputs
    wire buffer_full;
    wire [575:0] out;
    wire out_ready;

    // Var
    // integer i;

    // Instantiate the Unit Under Test (UUT)
    padder uut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .in_ready(in_ready),
        .is_last(is_last),
        .byte_num(byte_num),
        .buffer_full(buffer_full),
        .out(out),
        .out_ready(out_ready),
        .f_ack(f_ack)
    );

    initial begin
        // monitor will display the value of variables whenever they change
        $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, is_last=%b, byte_num=%b, buffer_full=%b, out=%h, out_ready=%b, f_ack=%b \n", $time, clk, reset, in, in_ready, is_last, byte_num, buffer_full, out, out_ready, f_ack);

        // Initialize Inputs
        clk = 0;
        reset = 1;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;
        f_ack = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

        //custom length
        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1; is_last = 0;

        //misal mau input 1 byte
        byte_num = 64; 
        in = {9{64'h90ABCDEF11111111}};
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;

        while (out_ready !== 1) // ini yg bikin bit ngisi ke depan
            #(`P);
        check(576'h01);

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
        input [575:0] wish;
        begin
          if (out !== wish)
            begin
              $display("out:%h wish:%h", out, wish);
              error;
            end
        end
    endtask
endmodule

`undef P

/*
time=200, clk=0, reset=0, in=90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef11111111, in_ready=1, is_last=1, byte_num=0001000000, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, out_ready=0, f_ack=0 

time=210, clk=1, reset=0, in=90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef11111111, in_ready=1, is_last=1, byte_num=0001000000, buffer_full=1, out=90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef111111110600000000000080, out_ready=1, f_ack=0

time=220, clk=0, reset=0, in=90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef11111111, in_ready=0, is_last=0, byte_num=0001000000, buffer_full=1, out=90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef111111110600000000000080, out_ready=1, f_ack=0

from low throughput code
time=540, clk=0, reset=0, in=90abcdef, in_ready=0, is_last=0, byte_num=01, buffer_full=0, out=000000009006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, out_ready=0, f_ack=0 

time=550, clk=1, reset=0, in=90abcdef, in_ready=0, is_last=0, byte_num=01, buffer_full=1, out=900600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080, out_ready=1, f_ack=0

time=560, clk=0, reset=0, in=90abcdef, in_ready=0, is_last=0, byte_num=01, buffer_full=1, out=900600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080, out_ready=1, f_ack=0
*/