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
    reg [191:0] in;
    reg in_ready;
    reg is_last;
    reg [5:0] byte_num;
    reg f_ack;

    // Outputs
    wire buffer_full;
    wire [575:0] out;
    wire out_ready;

    // Var
    integer i;

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
        $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, is_last=%b, byte_num=%d, buffer_full=%b, out=%h, out_ready=%b, f_ack=%b, uut.out=%h, uut.v0=%h, uut.v1=%h, uut.i=%b, uut.update=%b \n", $time, clk, reset, in, in_ready, is_last, byte_num, buffer_full, out, out_ready, f_ack, uut.out, uut.v0, uut.v1, uut.i, uut.update);

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
        /* //misal mau input 3 byte
        byte_num = 3; 
        in = 32'h90ABCDEF; 
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;*/

        //misal mau input 1 byte
        byte_num = 23; 
        in = 192'h90ABCDEF1a1b1c1d90ABCDEF1a1b1c1d90ABCDEF1a1b1c1d; 
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;

        while (out_ready !== 1) // ini yg bikin bit ngisi ke depan
            #(`P);
        check(576'h01);

        // // pad an (576-8) bit string //last 8 bit become 'h86
        // reset = 1; #(`P); reset = 0;
        // #(4*`P); // wait some cycles
        // in_ready = 1; is_last = 0;
        // byte_num = 3; 
        // for (i=0; i<8; i=i+1)
        //   begin
        //     in = 32'h12345678; #(`P);
        //     in = 32'h90ABCDEF; #(`P);
        //   end
        // in = 32'h12345678; #(`P);
        // in = 32'h90ABCDEF; is_last = 1; #(`P);
        // in_ready = 0;
        // is_last = 0;
        // check({ {8{64'h1234567890ABCDEF}}, 64'h1234567890ABCD81 });

        // // pad an (576-64) bit string
        // reset = 1; #(`P); reset = 0;
        // // don't wait any cycle
        // in_ready = 1; is_last = 0;
        // byte_num = 1; /* should have no effect */
        // for (i=0; i<8; i=i+1)
        //   begin
        //     in = 32'h12345678; #(`P);
        //     in = 32'h90ABCDEF; #(`P);
        //   end
        // is_last = 1;
        // byte_num = 0;
        // #(`P);
        // in_ready = 0;
        // is_last = 0;
        // #(`P);
        // check({ {8{64'h1234567890ABCDEF}}, 64'h0600000000000080 });

        // // pad an (576*2-16) bit string
        // reset = 1; #(`P); reset = 0;
        // in_ready = 1;
        // byte_num = 7; /* should have no effect */
        // is_last = 0;
        // for (i=0; i<9; i=i+1)
        //   begin
        //     in = 32'h12345678; #(`P);
        //     in = 32'h90ABCDEF; #(`P);
        //   end
        // if (out_ready !== 1) error;
        // check({9{64'h1234567890ABCDEF}});
        // #(`P/2);
        // if (buffer_full !== 1) error; // should not eat
        // #(`P/2);
        // in = 64'h999; // should not eat this
        // #(`P/2);
        // if (buffer_full !== 1) error; // should not eat
        // #(`P/2);
        // f_ack = 1; #(`P); f_ack = 0;
        // if (out_ready !== 0) error;
        // // feed next (576-16) bit
        // for (i=0; i<8; i=i+1)
        //   begin
        //     in = 32'h12345678; #(`P);
        //     in = 32'h90ABCDEF; #(`P);
        //   end
        // in = 32'h12345678; #(`P);
        // byte_num = 2;
        // is_last = 1;
        // in = 32'h90ABCDEF; #(`P);
        // if (out_ready !== 1) error;
        // check({ {8{64'h1234567890ABCDEF}}, 64'h1234567890AB0680 });
        // is_last = 0;
        // // eat these bits
        // f_ack = 1; #(`P); f_ack = 0;
        // // should not provide any more bits, if user provides nothing
        // in_ready = 0;
        // is_last = 0;
        // for (i=0; i<10; i=i+1)
        //   begin
        //     if (out_ready === 1) error;
        //     #(`P);
        //   end
        // in_ready = 0;

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
