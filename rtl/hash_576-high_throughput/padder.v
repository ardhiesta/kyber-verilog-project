// copied from https://github.com/freecores/sha3
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

/* "is_last" == 0 means byte number is 4, no matter what value "byte_num" is. */
/* if "in_ready" == 0, then "is_last" should be 0. */
/* the user switch to next "in" only if "ack" == 1. */

module padder(clk, reset, in, in_ready, is_last, byte_num, buffer_full, out, out_ready, f_ack);
    input              clk, reset;
    input      [575:0]  in;
    input              in_ready, is_last;
    input      [9:0]   byte_num;
    output             buffer_full; /* to "user" module */
    output reg [575:0] out;         /* to "f_permutation" module */
    output             out_ready;   /* to "f_permutation" module */
    input              f_ack;       /* from "f_permutation" module */
    
    reg                state;       /* state == 0: user will send more input data
                                     * state == 1: user will not send any data */
    reg                done;        /* == 1: out_ready should be 0 */
    reg        /*[2:0]*/  i;           /* length of "out" buffer */
    wire       [575:0]  v0;          /* output of module "padder1" */
    reg        [575:0]  v1;          /* to be shifted into register "out" */
    wire               accept,      /* accept user input? */
                       update;
    
    assign buffer_full = i/*[0]*/;
    assign out_ready = buffer_full;
    assign accept = (~ state) & in_ready & (~ buffer_full); // if state == 1, do not eat input
    assign update = (accept | (state & (~ buffer_full))) & (~ done); // don't fill buffer if done

    always @ (posedge clk)
      if (reset)
        out <= 0;
      else if (update)
        // out <= {out, v1}; //32'h00000080};
        out <= {v0[575:32], 32'h00000080}; //v1[31:0]};
        // code above is fastfix for the bug, it is still wrong
        /*
        wrong output
        time=1180, clk=0, reset=0, in=90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef11111111, out=2b418d4a12b23738151b7db4ebee56da9100b5dd557a83bb2373bac2f75bb4f74cb22934d50fa6be4fd96d88528d0686d6c740c64118cd8fc838fd5bdbe273c0,out_ready=1, byte_num=000, uut.i=00000000000000000000000, uut.padder_out=000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000, uut.padder_out_1=060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080

        right output
        time=860, clk=0, reset=0, in=fc7b8cdafc7b8cda, out=ee6c1aff1aed1aef9fb077a450d306335e22601de356ebcf8ac4d313fedc383f3bfda9bb8ce547d80f1e8c437cc9124358714fc8c52289a8e9f5f63eac449b76,out_ready=1, byte_num=0, uut.i=00000000000000000000000, uut.padder_out=da8c7bfcda8c7bfc00000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000, uut.padder_out_1=fc7b8cdafc7b8cda06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080 

        TODO: do something with padder_out and padder_out_1
        */

    always @ (posedge clk)
      if (reset)
        i <= 0;
      else if (f_ack | update)
        i <= {i/*[0]*/, 1'b1} & {~ f_ack};
/*    if (f_ack)  i <= 0; */
/*    if (update) i <= {i[16:0], 1'b1}; // increase length */

    always @ (posedge clk)
      if (reset)
        state <= 0;
      else if (is_last)
        state <= 1;

    always @ (posedge clk)
      if (reset)
        done <= 0;
      else if (state & out_ready)
        done <= 1;

    padder1 p0 (in, byte_num, v0);
    
    always @ (*)
      begin
        if (state)
          begin
            v1 = 0;
            //v1[7] = v1[7] | i/*[0]*/; // "v1[7]" is the MSB of the last byte of "v1"
            v1[7] = v1[7] | i;
          end
        else if (is_last == 0)
          v1 = in;
        else
          begin
            v1 = v0;
            v1[7] = v1[7] | i/*[0]*/;
            // v1 = v1 | i;
          end
      end
endmodule

/*
the output is missing 80 in the last digit
v1 contains 80
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080

v0
90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef111111110600000000000000
*/
