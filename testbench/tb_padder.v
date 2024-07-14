`include "../rtl/pad/padder.v"
`include "../rtl/pad/padder1.v"
`timescale 1ns / 1ps
`define P 20

module tb_padder;
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

    // generate clock
    initial begin
        clk <= 1'b0;
        forever begin
            #1 clk = ~clk;
        end
    end

    // Test stimulus
    initial begin
        $monitor("time=%3d, clk=%b, reset=%b, in=%b, in_ready=%b, is_last=%b, byte_num=%b, buffer_full=%b, out=%b, out_ready=%b, f_ack=%b \n", $time, clk, reset, in, in_ready, is_last, byte_num, buffer_full, out, out_ready, f_ack);

        #3
        clk = 0;
        reset = 1;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;
        f_ack = 0;

        /* before 3s:
        * all values is unknown (x), then reset = 1 and other values become 0
        * https://github.com/ardhiesta/kyber-verilog-project/blob/main/docs/imgs/reset-effects.png?raw=true
        */

        // Wait 100 ns for global reset to finish
        #100;

        $finish;
    end

endmodule;