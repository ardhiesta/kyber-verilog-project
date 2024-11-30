`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// get from https://github.com/grassnhi/crystal-kyber
// Company: HCMUT - CSE
// Engineer: Grassnhi
// 
// Create Date: 10/22/2024 02:32:18 PM
// Design Name: decompress
// Module Name: decompress
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Verified
// 
//////////////////////////////////////////////////////////////////////////////////


module decompress #( 
    parameter D = 4  
)(
    input wire          clk,   
    input wire          rst_n, 
    input wire  [D-1:0] in_val,  

    output wire [11:0]  out_val  
);
   
    reg [11+D:0] shift_11_stage1, shift_10_stage1, shift_8_stage1, shift_0_stage1;
    reg [11+D:0] sum_stage2_a, sum_stage2_b;
    reg [12+D:0] total, total_t;

    wire [11:0] temp_out;
    wire [D:0]  t;
    
    assign t = 1 << (D - 1);

    // Stage 1: Perform the shifts in parallel
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            shift_11_stage1 <= 16'b0;
            shift_10_stage1 <= 16'b0;
            shift_8_stage1  <= 16'b0;
            // shift_0_stage1  <= 16'b0;
        end
        else begin
            shift_11_stage1 <= (in_val << 11);   // X * 2^11
            shift_10_stage1 <= (in_val << 10);   // X * 2^10
            shift_8_stage1  <= (in_val << 8);    // X * 2^8
            // shift_0_stage1  <= (in_val << 0);    // X * 2^0 (no shift)
        end
    end

    // Stage 2: Add partial sums in parallel
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            sum_stage2_a    <= 16'b0;
            sum_stage2_b    <= 16'b0;
            total           <= 16'b0;
        end
        else begin
            sum_stage2_a    <= shift_11_stage1 + shift_10_stage1;  // (X * 2^11) + (X * 2^10)
            // sum_stage2_b    <= shift_8_stage1  + shift_0_stage1;   // (X * 2^8) + (X * 2^0)
            sum_stage2_b    <= shift_8_stage1  + in_val;
            total           <= sum_stage2_a + sum_stage2_b;
        end
    end

    // Stage 3: Final sum
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            total_t     <= 16'b0;
        end
        else begin
           total_t      <= total + t;   // Final result
        end
    end

    assign temp_out     = total_t >> D;
    assign out_val      = temp_out[11:0];  

endmodule


