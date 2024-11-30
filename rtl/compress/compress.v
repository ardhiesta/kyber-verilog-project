`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// get from https://github.com/grassnhi/crystal-kyber
// Company: HCMUT-CSE 
// Engineer: Grassnhi
// 
// Create Date: 10/22/2024 10:14:08 AM
// Design Name: compress
// Module Name: compress
// Project Name: crystal-kyber
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define PIPELINED

module compress#( 
    // Parameter for the bit-width of compressed output
    parameter D = 4, 
    // Kyber modulus q 
    parameter Q = 3329 
)(
    // Clock signal
    input clk, 
    // Reset signal      
    input rst_n,   
    // Input 12-bit value    
    input [11:0] in_val, 
    // Output compressed value with `d` bits 
    output reg [D-1:0] out_val  
);

`ifdef PIPELINED
    // Pipelined version of the compress module
    wire [D:0] t;
    wire [D:0] not_t;
    wire [11+D:0] x;
    wire [11:0] half_q;
    wire [12+D:0] temp;
    wire [D-1:0] out_val_temp;
    wire [11+D:0] div_q;

    reg [11+D:0] x_reg;
    reg [12+D:0] temp_stage1; 
    reg [11+D:0] temp_stage2; 
    
    assign t        = 1 << D;          // t = 2^D
    assign not_t    = t - 1;
    
    // temp = ((in_val << D) + (Q >> 1)) => Calculate (2^d * x + q//2) / q
    assign x            = (in_val << D);   
    assign half_q       = (Q >> 1); 
    assign temp         = x + half_q; 
    assign out_val_temp = temp_stage2 & not_t;
    assign div_q        = temp_stage1 / Q;

    // Stage 1: Load temp to FF
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            temp_stage1 <= 0;
            x_reg <= 0;
        end else begin
            x_reg <= x;
            temp_stage1 <= temp;
        end
    end

    // Stage 2: Divide temp by Q
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            temp_stage2 <= 0;
        end else begin
            temp_stage2 <= div_q;
        end
    end

    // Stage 4: Perform modulo operation (bitwise AND)
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            out_val     <= 0;
        end else begin
            out_val     <= out_val_temp;
        end
    end

`else
    // Non-pipelined version of the compress module
    reg [11+D:0] temp;  
    reg [D:0] t;        

    always @(*) begin
        // Compute t = 2^d
        t       = 1 << D;
        // Calculate (2^d * x + q//2) / q
        temp    = ((in_val << D) + (Q >> 1)) / Q;
        // Calculate modulo 2^d
        out_val = temp & (~t);
    end
`endif

endmodule
