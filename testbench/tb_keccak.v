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
        // $dumpfile("test.vcd");
        // $dumpvars(0,test_keccak);
        // Initialize Inputs
        clk = 0;
        reset = 0;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;

        // $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, is_last=%b, byte_num=%b, out=%h, out_ready=%b \n", 
        // $time, clk, reset, in, in_ready, is_last, byte_num, out, out_ready);
        
        // #3 // tambahan, not ori
        // reset = 1; #(`P); reset = 0;
        // in_ready = 1; is_last = 0;
        // // in = "The "; #(`P);
        // // in = "quic"; #(`P);
        // // in = "k br"; #(`P);
        // // in = "own "; #(`P);
        // // in = "fox "; #(`P);
        // // in = "jump"; #(`P);
        // // in = "s ov"; #(`P);
        // // in = "er t"; #(`P);
        // // in = "he l"; #(`P);
        // // in = "azy "; #(`P);
        // // in = "dog "; 
        // in = "abcd"; #(`P);
        // in = "abcd";
        // byte_num = 3;
        // is_last = 1; #(`P); /* !!! not in = "dog" */
        // in_ready = 0; is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // #2000 $finish;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

        // SHA3-512("The quick brown fox jumps over the lazy dog")
        reset = 1; #(`P); reset = 0;
        in_ready = 1; is_last = 0;
        in = "The "; #(`P);
        in = "quic"; #(`P);
        in = "k br"; #(`P);
        in = "own "; #(`P);
        in = "fox "; #(`P);
        in = "jump"; #(`P);
        in = "s ov"; #(`P);
        in = "er t"; #(`P);
        in = "he l"; #(`P);
        in = "azy "; #(`P);
        in = "dog "; byte_num = 3; is_last = 1; #(`P); /* !!! not in = "dog" */
        in_ready = 0; is_last = 0;
        while (out_ready !== 1)
            #(`P);
        //check(512'hd135bb84d0439dbac432247ee573a23ea7d3c9deb2a968eb31d47c4fb45f1ef4422d6c531b5b9bd6f449ebcc449ea94d0a8f05f62130fda612da53c79659f609);
        check(512'h01dedd5de4ef14642445ba5f5b97c15e47b9ad931326e4b0727cd94cefc44fff23f07bf543139939b49128caf436dc1bdee54fcb24023a08d9403f9b4bf0d450);

        // SHA3-512("The quick brown fox jumps over the lazy dog.")
        reset = 1; #(`P); reset = 0;
        in_ready = 1; is_last = 0;
        in = "The "; #(`P);
        in = "quic"; #(`P);
        in = "k br"; #(`P);
        in = "own "; #(`P);
        in = "fox "; #(`P);
        in = "jump"; #(`P);
        in = "s ov"; #(`P);
        in = "er t"; #(`P);
        in = "he l"; #(`P);
        in = "azy "; #(`P);
        in = "dog."; #(`P);
        in = 0; byte_num = 0; is_last = 1; #(`P); /* !!! */
        in_ready = 0; is_last = 0;
        while (out_ready !== 1)
            #(`P);
        //check(512'hab7192d2b11f51c7dd744e7b3441febf397ca07bf812cceae122ca4ded6387889064f8db9230f173f6d1ab6e24b6e50f065b039f799f5592360a6558eb52d760);
        check(512'h18f4f4bd419603f95538837003d9d254c26c23765565162247483f65c50303597bc9ce4d289f21d1c2f1f458828e33dc442100331b35e7eb031b5d38ba6460f8);

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
        // check(512'h12f4a85b68b091e8836219e79dfff7eb9594a42f5566515423b2aa4c67c454de83a62989e44b5303022bfe8c1a9976781b747a596cdab0458e20d8750df6ddfb);
        // // check(512'hedc8d5dd93da576838a856c71c5ba87d359445b0589e75e6f67bb8e41a05e78876835d5254d27e0b1445ab49599ff30952a83765858f1e47332835eee6af43f9);
        // for(i=0; i<5; i=i+1)
        //   begin
        //     #(`P);
        //     if (buffer_full !== 0) error; // should keep 0
        //   end

        // hash an empty string, should not eat next input
        reset = 1; #(`P); reset = 0;
        #(7*`P); // wait some cycles
        in = 32'h12345678; // should not be eat
        byte_num = 0;
        in_ready = 1;
        is_last = 1;
        #(`P);
        in = 32'hddddd; // should not be eat
        //hasil pad: 576 bit of zeros
        in_ready = 1; // next input
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;

        while (out_ready !== 1)
            #(`P);
        //check(512'h0eab42de4c3ceb9235fc91acffe746b29c29a8c366b7c60e4e67c466f36a4304c00fa9caf9d87976ba469bcbe06713b435f091ef2769fb160cdab33d3670680e);
        check(512'ha69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26);
        for(i=0; i<5; i=i+1)
          begin
            #(`P);
            if (buffer_full !== 0) error; // should keep 0
          end

        //custom, input 1 byte --> ok
        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1;
        byte_num = 2; 
        in = 32'hEF26BCDE; 
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;
        while (out_ready !== 1)
            #(`P);
        check(512'h150240baf95fb36f8ccb87a19a41767e7aed95125075a2b2dbba6e565e1ce8575f2b042b62e29a04e9440314a821c6224182964d8b557b16a492b3806f4c39c1);

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
        // // hasil pad: efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563412efcdab9078563486
        // in_ready = 0;
        // is_last = 0;
        // while (out_ready !== 1)
        //     #(`P);
        // check(512'hf7f6b44069dba8900b6711ffcbe40523d4bb718cc8ed7f0a0bd28a1b18ee9374359f0ca0c9c1e96fcfca29ee2f282b46d5045eff01f7a7549eaa6b652cbf6270);

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
        // // check(512'hccd91653872c106f6eea1b8b68a4c2901c8d9bed9c180201f8a6144e7e6e6c251afcb6f6da44780b2d9aabff254036664719425469671f7e21fb67e5280a27ed);

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
        // // check(512'h0f385323604e279251e80f928cfd9ce9492ba5df775063ea106eebe2a2c7785a3e33b4397fca66e90f67470334c66ea12016cb1f06170b9b033f158a7c01933e);

        // $display("Good!");
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
