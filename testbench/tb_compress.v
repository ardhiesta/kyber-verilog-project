`timescale 1ns / 1ps

module tb_compress;
    parameter Q = 3329;
    // Testbench signals
    reg clk;
    reg rst_n;

    reg [11:0] in_val;  

    wire [9:0] out_val_10;          // Output for D=10
    wire [3:0] out_val_4;           // Output for D=4
    wire        out_val_1;         // Output for D=1

    // Clock generation: 10ns clock period (100MHz)
    always #5 clk = ~clk;

    // Reset task
    task RESETn;
        begin
            rst_n = 0;
            repeat(2) c1;
            rst_n = 1;
        end
    endtask

    // Wait for one clock cycle
    task automatic c1;
        begin
            @(posedge clk);
            #0.1;
        end
    endtask

    // Instantiate the compress module for D=10
    compress #(.D(10), .Q(Q)) dut_D10 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val),
        .out_val(out_val_10)
    );

    // Test sequence
    initial begin
        $dumpfile("test_compress.vcd");
        $dumpvars(0, test_compress);

        // Initialize signals
        clk     = 0;
        rst_n   = 0;
        in_val  = 0;

        // // Reset the DUT
        // RESETn();

        #1
        rst_n   = 1;

        // c1;

        #1
        in_val = 12'd1310;
        #100;
        // $monitor("time=%3d, in=%d, out=%d, rst_n=%b, Q=%d, D=%d, temp=%d, out_val_temp=%d", $time, in_val, out_val_1, rst_n, Q, dut_D1.D, dut_D1.temp, dut_D1.out_val_temp);
        $monitor("time=%3d, in=%d, out=%d, clk=%b", $time, in_val, out_val_10, clk);
        // $monitor("time=%3d, clk=%b", $time, clk);
        $finish;
    end

    // initial begin
	//     integer i;
	   
    //     repeat(3) c1;

    //     // for ( i = 0; i < 4099; i = i + 1) begin
    //     //     //RANDOM_TEST(); 
	//     //     APPLY_INPUT(i);

    //     //     $display("%d", out_val_10);
    //     //     c1;
    //     // end

    //     #10
    //     in_val = 12'd8;
    //     $monitor("%d", out_val_10);
    // end

    // // Simulation finish
    // initial begin
    //     #50000;
    //     $finish;
    // end
endmodule