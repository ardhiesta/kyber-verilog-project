# Note on Padder SHA3

I want to utilize SHA3 Verilog implementation from [FreeCores / OpenCores](https://github.com/freecores/sha3). This is my note on the testbench of [padder code](https://github.com/freecores/sha3/blob/master/low_throughput_core/rtl/padder.v).

```
// tb_padder.v
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
`include "../rtl/pad/padder.v"
`include "../rtl/pad/padder1.v"
`timescale 1ns / 1ps
`define P 20

module tb_padder_ori;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] in;
    reg in_ready;
    reg is_last;
    reg [1:0] byte_num;
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
        $monitor("time=%3d, clk=%b, reset=%b, in=%h, in_ready=%b, is_last=%b, byte_num=%b, buffer_full=%b, out=%h, out_ready=%b, f_ack=%b, uut.out=%h, uut.v0=%h, uut.v1=%h \n", $time, clk, reset, in, in_ready, is_last, byte_num, buffer_full, out, out_ready, f_ack, uut.out, uut.v0, uut.v1);

        // Initialize Inputs
        clk = 0;
        reset = 1;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;
        f_ack = 0;

        /*
        the value of out is still unknown 
        v0 in padder1 = 06000000, because byte_num = 0 means input discarded, all replaced with pad byte

        time=  0, clk=0, reset=1, in=00000000, in_ready=0, is_last=0, byte_num=00, buffer_full=x, 
        out=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx, 
        out_ready=x, f_ack=0, 
        uut.out=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx, uut.v0=06000000, uut.v1=00000000 
        */

        // Wait 100 ns for global reset to finish
        #100;
        /* 
        #100 : will wait until 100ns before finish, out will be 0

        tb_padder_ori.v:186: $finish called at 100000 (1ps)
        time=100, clk=0, reset=1, in=00000000, in_ready=0, is_last=0, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, uut.v0=06000000, uut.v1=00000000
        */

        // Add stimulus here
        @ (negedge clk);
        /*
        currently I have no idea what is "@ (negedge clk);"

        Negedge clock operation is also used in testbenches, to avoid race condition between DUT and Testbench, since both are driven at different clock edges.

        https://stackoverflow.com/questions/42664393/what-is-the-merit-to-using-the-negedge-clock-in-verilog
        */

        // pad an empty string, should not eat next input
        reset = 1; #(`P); reset = 0;
        /*
        on 120, the value of reset become 0

        tb_padder_ori.v:200: $finish called at 120000 (1ps)
        time=120, clk=0, reset=0, in=00000000, in_ready=0, is_last=0, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, uut.v0=06000000, uut.v1=00000000 
        */

        #(7*`P); // wait some cycles, nothing changed only timer move to 260ns (last time 120 + 7*20)
        if (buffer_full !== 0) error;
        in_ready = 1; //in_ready = 1 in 260ns
        is_last = 1;  
        /*
        is_last = 1 in 260ns, uut.v1 = uut.v0 = 06000000
        suppostly come from padder.v:85 (when is_last = 1)
        ...
        else if (is_last == 0)
          v1 = in;
        else
          begin
            v1 = v0; //this one
        ...

        tb_padder_ori.v:207: $finish called at 260000 (1ps)
        time=260, clk=0, reset=0, in=00000000, in_ready=1, is_last=1, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, uut.v0=06000000, uut.v1=06000000 
        */

        #(`P);
        /* timer move to 280s, at 270s uut.v1=00000000, v1 not saved
        
        tb_padder_ori.v:227: $finish called at 280000 (1ps)
        time=280, clk=0, reset=0, in=00000000, in_ready=1, is_last=1, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000, uut.v0=06000000, uut.v1=00000000 
        */
        in_ready = 1; // next input, nothing change
        is_last = 1; // nothing change
        #(`P);
        in_ready = 0; // in_ready become 0
        is_last = 0;  // is_last become 0
        /*
        tb_padder_ori.v:227: $finish called at 300000 (1ps)
        time=300, clk=0, reset=0, in=00000000, in_ready=0, is_last=0, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000, uut.v0=06000000, uut.v1=00000000 
        */

        while (out_ready !== 1)
            #(`P);
        /*
        timer will wait until out_ready = 1 at time=610

        time=610, clk=1, reset=0, in=00000000, in_ready=0, is_last=0, byte_num=00, buffer_full=1, out=060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080, out_ready=1, f_ack=0, uut.out=060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080, uut.v0=06000000, uut.v1=00000080

        stop at time=620 
 
        TODO: examine how out value change
        time = 260, out value = 0
        time = 270, out value change
        time=260, clk=0, reset=0, in=00000000, in_ready=1, is_last=1, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, uut.v0=06000000, uut.v1=06000000 

        time=270, clk=1, reset=0, in=00000000, in_ready=1, is_last=1, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000, uut.v0=06000000, uut.v1=00000000

        out value change again at time = 290
        time=280, clk=0, reset=0, in=00000000, in_ready=1, is_last=1, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000, uut.v0=06000000, uut.v1=00000000 

        time=290, clk=1, reset=0, in=00000000, in_ready=1, is_last=1, byte_num=00, buffer_full=0, out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000, out_ready=0, f_ack=0, uut.out=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000, uut.v0=06000000, uut.v1=00000000
        */

        // check({8'h1, 560'h0, 8'h80});
        // f_ack = 1; #(`P); f_ack = 0;
        // for(i=0; i<5; i=i+1)
        //   begin
        //     #(`P);
        //     if (buffer_full !== 0) error; // should be 0
        //   end

        // // pad an (576-8) bit string
        // reset = 1; #(`P); reset = 0;
        // #(4*`P); // wait some cycles
        // in_ready = 1; is_last = 0;
        // byte_num = 3; /* should have no effect */
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
        // check({ {8{64'h1234567890ABCDEF}}, 64'h0100000000000080 });

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
        // check({ {8{64'h1234567890ABCDEF}}, 64'h1234567890AB0180 });
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
```