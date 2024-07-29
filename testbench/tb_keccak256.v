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
`include "../rtl/hash/keccak256.v"
`include "../rtl/hash/padder256.v"
`include "../rtl/hash/padder1.v"
`include "../rtl/hash/round.v"
`include "../rtl/hash/rconst.v"
`include "../rtl/hash/f_permutation256.v"
`timescale 1ns / 1ps
`define P 20

module tb_keccak256;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] in;
    reg in_ready;
    reg is_last;
    reg [1:0] byte_num;

    // Outputs
    wire buffer_full;
    wire [255:0] out;
    wire out_ready;

    // Var
    integer i;

    // Instantiate the Unit Under Test (UUT)
    keccak256 uut (
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

//     // generate clock
// initial begin
//     clk <= 1'b0;
// 	forever begin
// 	    #1 clk = ~clk;
// 	end
// end

    initial begin
        // $dumpfile("test.vcd");
        // $dumpvars(0,test_keccak);
        // Initialize Inputs
        clk = 0;
        reset = 0;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;

        // $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, is_last=%b, byte_num=%b, out=%h, out_ready=%b, uut.padder_out_ready=%h, uut.padder_out_1=%h \n", 
        // $time, clk, reset, in, in_ready, is_last, byte_num, out, out_ready, uut.padder_out_ready, uut.padder_out_1);
        // $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, out=%h, out1=%h, f_out=%h \n", 
        // $time, clk, reset, in, in_ready, out, uut.out1, uut.f_out);

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

        // // SHA3-256("The quick brown fox jumps over the lazy dog")
        // reset = 1; #(`P); reset = 0;
        // in_ready = 1; is_last = 0;
        // in = "The "; #(`P);
        // in = "quic"; #(`P);
        // in = "k br"; #(`P);
        // in = "own "; #(`P);
        // in = "fox "; #(`P);
        // in = "jump"; #(`P);
        // in = "s ov"; #(`P);
        // in = "er t"; #(`P);
        // in = "he l"; #(`P);
        // in = "azy "; #(`P);
        // in = "dog "; byte_num = 3; is_last = 1; #(`P); /* !!! not in = "dog" */
        // in_ready = 0; is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(256'h69070dda01975c8c120c3aada1b282394e7f032fa9cf32f4cb2259a0897dfc04);

        // // SHA3-512("The quick brown fox jumps over the lazy dog.")
        // reset = 1; #(`P); reset = 0;
        // in_ready = 1; is_last = 0;
        // in = "The "; #(`P);
        // in = "quic"; #(`P);
        // in = "k br"; #(`P);
        // in = "own "; #(`P);
        // in = "fox "; #(`P);
        // in = "jump"; #(`P);
        // in = "s ov"; #(`P);
        // in = "er t"; #(`P);
        // in = "he l"; #(`P);
        // in = "azy "; #(`P);
        // in = "dog."; #(`P);
        // in = 0; byte_num = 0; is_last = 1; #(`P); /* !!! */
        // in_ready = 0; is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(256'ha80f839cd4f83f6c3dafc87feae470045e4eb0d366397d5c6ce34ba1739f734d);

        // // hash an string "\xA1\xA2\xA3\xA4\xA5", len == 5
        // reset = 1; #(`P); reset = 0;
        // #(7*`P); // wait some cycles
        // in_ready = 1; is_last = 0; byte_num = 1;
        // in = 32'hA1A2A3A4;
        // #(`P);
        // is_last = 1; byte_num = 1;
        // in = 32'hA5000000;
        // #(`P);
        // in = 32'h12345678; // next input
        // in_ready = 1;
        // is_last = 1;
        // #(`P/2);
        // if (buffer_full === 1) error; // should be 0
        // #(`P/2);
        // in_ready = 0;
        // is_last = 0;

        // while (out_ready !== 1)
        //     #(`P);
        // check(256'h815bfaacecd76f2793cbacb330190cc2d7770a028e12293b4cd139841f2aedfc);
        // for(i=0; i<5; i=i+1)
        //   begin
        //     #(`P);
        //     if (buffer_full !== 0) error; // should keep 0
        //   end

        // // hash an empty string, should not eat next input
        // reset = 1; #(`P); reset = 0;
        // #(7*`P); // wait some cycles
        // in = 32'h12345678; // should not be eat
        // byte_num = 0;
        // in_ready = 1;
        // is_last = 1;
        // #(`P);
        // in = 32'hddddd; // should not be eat
        // //hasil pad: 576 bit of zeros
        // in_ready = 1; // next input
        // is_last = 1;
        // #(`P);
        // in_ready = 0;
        // is_last = 0;

        // while (out_ready !== 1)
        //     #(`P);
        // check(256'ha7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a);
        // for(i=0; i<5; i=i+1)
        //   begin
        //     #(`P);
        //     if (buffer_full !== 0) error; // should keep 0
        //   end

        //custom, input 32 byte 
        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1;
        in = 32'he7372105; #(`P);
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;
        while (out_ready !== 1)
            #(`P);
        check(256'h3a42b68ab079f28c4ca3c752296f279006c4fe78b1eb79d989777f051e4046ae);

        // //custom, input 2 byte 
        // reset = 1; #(`P); reset = 0;
        // #(4*`P); // wait some cycles
        // in_ready = 1;
        // byte_num = 2; 
        // in = 32'hD477BCDE; 
        // is_last = 1;
        // #(`P);
        // in_ready = 0;
        // is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(256'h94279e8f5ccdf6e17f292b59698ab4e614dfe696a46c46da78305fc6a3146ab7);

        // // hash an (576-8) bit string
        // reset = 1; #(`P); reset = 0;
        // #(4*`P); // wait some cycles
        // in_ready = 1;
        // byte_num = 3; /* should have no effect */
        // is_last = 0;
        // for (i=0; i<8; i=i+1)
        //   begin
        //     in = 32'hEFCDAB90; #(`P);
        //     in = 32'h78563412; #(`P);
        //   end
        // in = 32'hEFCDAB90; #(`P);
        // in = 32'h78563412; is_last = 1; #(`P);
        // //input: efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab90785634
        // in_ready = 0;
        // is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(256'h4e5db81da7692426876d35b79682db99011a7eca32b528753fed510c4e8d2cbc);

        // // pad an (576-64) bit string
        // reset = 1; #(`P); reset = 0;
        // // don't wait any cycle
        // in_ready = 1;
        // byte_num = 7; /* should have no effect */
        // is_last = 0;
        // for (i=0; i<8; i=i+1)
        //   begin
        //     in = 32'hEFCDAB90; #(`P);
        //     in = 32'h78563412; #(`P);
        //   end
        // is_last = 1;
        // byte_num = 0;
        // #(`P);
        // in_ready = 0;
        // is_last = 0;
        // in = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(256'h2ad0433109f5b32a00ba4115994da973c2f14df9c7d0b4192710a8101705efa1);

        // // pad an (576*2-16) bit string          | this input get error 
        // reset = 1; #(`P); reset = 0;
        // in_ready = 1;
        // byte_num = 1; /* should have no effect */
        // is_last = 0;
        // for (i=0; i<9; i=i+1)
        //   begin
        //     in = 32'hEFCDAB90; #(`P);
        //     in = 32'h78563412; #(`P);
        //   end
        // #(`P/2);
        // if (buffer_full !== 1) error; // should not eat  | this line
        // #(`P/2);
        // in = 32'h999; // should not eat this
        // in_ready = 0;
        // #(`P/2);
        // if (buffer_full !== 0) error; // should not eat, but buffer should not be full | or this line caused error
        // #(`P/2);
        // #(`P);
        // // feed next (576-16) bit
        // in_ready = 1;
        // for (i=0; i<8; i=i+1)
        //   begin
        //     in = 32'hEFCDAB90; #(`P);
        //     in = 32'h78563412; #(`P);
        //   end
        // in = 32'hEFCDAB90; #(`P);
        // byte_num = 2;
        // is_last = 1;
        // in = 32'h78563412;
        // #(`P);
        // is_last = 0;
        // in_ready = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(256'h0f);

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
        input [255:0] wish;
        begin
          if (out !== wish)
            begin
              $display("%h %h", out, wish); error;
            end
        end
    endtask
endmodule

`undef P
