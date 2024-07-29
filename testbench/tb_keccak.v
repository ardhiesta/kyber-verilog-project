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
`include "../rtl/hash/keccak.v"
`include "../rtl/hash/padder.v"
`include "../rtl/hash/padder1.v"
`include "../rtl/hash/round.v"
`include "../rtl/hash/rconst.v"
`include "../rtl/hash/f_permutation.v"
`timescale 1ns / 1ps
`define P 20

module tb_keccak;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] in;
    reg in_ready;
    reg is_last;
    reg [1:0] byte_num;

    // Outputs
    wire buffer_full;
    wire [511:0] out;
    wire out_ready;

    // Var
    integer i;

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

//     // generate clock
// initial begin
//     clk <= 1'b0;
// 	forever begin
// 	    #1 clk = ~clk;
// 	end
// end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, tb_keccak);

        // Initialize Inputs
        clk = 0;
        reset = 0;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;

        // $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, is_last=%b, byte_num=%b, out=%h, out_ready=%b, uut.padder_out_ready=%h, uut.padder_out_1=%h, uut.padder_out=%h \n", 
        // $time, clk, reset, in, in_ready, is_last, byte_num, out, out_ready, uut.padder_out_ready, uut.padder_out_1, uut.padder_out);
        
        // $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, out=%h, out1=%h, f_out=%h \n", 
        // $time, clk, reset, in, in_ready, out, uut.out1, uut.f_out);

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

        // // SHA3-512("The quick brown fox jumps over the lazy dog")
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
        // check(512'h01dedd5de4ef14642445ba5f5b97c15e47b9ad931326e4b0727cd94cefc44fff23f07bf543139939b49128caf436dc1bdee54fcb24023a08d9403f9b4bf0d450);

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
        // check(512'h18f4f4bd419603f95538837003d9d254c26c23765565162247483f65c50303597bc9ce4d289f21d1c2f1f458828e33dc442100331b35e7eb031b5d38ba6460f8);

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
        // //hasil pad: 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a1a2a3a4a5060000
        // in_ready = 1;
        // is_last = 1;
        // #(`P/2);
        // if (buffer_full === 1) error; // should be 0
        // #(`P/2);
        // in_ready = 0;
        // is_last = 0;

        // while (out_ready !== 1)
        //     #(`P);
        // check(512'hedc8d5dd93da576838a856c71c5ba87d359445b0589e75e6f67bb8e41a05e78876835d5254d27e0b1445ab49599ff30952a83765858f1e47332835eee6af43f9);
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
        // check(512'ha69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26);
        // for(i=0; i<5; i=i+1)
        //   begin
        //     #(`P);
        //     if (buffer_full !== 0) error; // should keep 0
        //   end

        // //custom, input 2 byte --> ok
        // reset = 1; #(`P); reset = 0;
        // #(4*`P); // wait some cycles
        // in_ready = 1;
        // byte_num = 2; 
        // in = 32'hEF26BCDE; 
        // is_last = 1;
        // #(`P);
        // in_ready = 0;
        // is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(512'h809b4124d2b174731db14585c253194c8619a68294c8c48947879316fef249b1575da81ab72aad8fae08d24ece75ca1be46d0634143705d79d2f5177856a0437);

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
        // // input: efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab90785634
        // in_ready = 0;
        // is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(512'h6297e8688a3be8cd99b244147f001b0f1ad4667868e8ddfbc58ec0236bd8b2ad99418ba5fec47c3f0f787243958229da6eb48ce7c6c78a929497fddd098d1a28);

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
        // check(512'h2b276100c85f018d06c4549073e849e39eec1d0c2a4e9b1a98b1411d0b1ca86570201b284c0d9bf4680c5507fa28db6952d957e200b231ca878a7f2db0d1b851);

        // // pad an (576*2-16) bit string
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
        // if (buffer_full !== 1) error; // should not eat
        // #(`P/2);
        // in = 32'h999; // should not eat this
        // in_ready = 0;
        // #(`P/2);
        // if (buffer_full !== 0) error; // should not eat, but buffer should not be full
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
        // check(512'h2d9bb7afb83773be6d0d5a5518198b416bf283850bcaa8237a71a006558956ff1f8824eab7bf9b549cd273cc05adccd7e888ed2dda17cf07c32e0db1ffa1d3df);

        //custom, input 32 byte 
        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1;
        in = 32'hfc7b8cda; #(`P);
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
