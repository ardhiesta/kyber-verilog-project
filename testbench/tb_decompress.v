`timescale 1ns / 1ps

module tb_decompress;
    // Testbench signals
    reg clk;
    reg rst_n;
    
    reg [0:0] in_val_1;     // Input for D=1 (compressed value)
    reg [3:0] in_val_4;     // Input for D=4 (compressed value)
    reg [9:0] in_val_10;    // Input for D=10 (compressed value)

    wire [11:0] out_val_1;   // Output for D=1 (decompressed value)
    wire [11:0] out_val_4;   // Output for D=4 (decompressed value)
    wire [11:0] out_val_10;  // Output for D=10 (decompressed value)

    // Expected value arrays
    reg [11:0] expected_vals_1 [0:1];   // Only 2 values for D=1
    reg [11:0] expected_vals_4 [0:15];  // 16 values for D=4
    reg [11:0] expected_vals_10 [0:1023];  // 1024 values for D=10

    // Instantiate the decompress module for D=10
    decompress #(.D(10)) dut_D10 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val_10),
        .out_val(out_val_10)
    );

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

    // Clock
    task automatic c1;
        begin
            @(posedge clk);
            #0.1;
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        clk         = 0;
        rst_n       = 0;
        in_val_1    = 0;
        in_val_4    = 0;
        in_val_10   = 0;

        // Reset the DUT
        RESETn();
        c1;
    end

    initial begin
        integer i;
        
        repeat(3) c1;
        
        // for (i = 0; i < `N_OF_TEST; i = i + 1) begin
        //         APPLY_INPUT_D1(i);
        //         APPLY_INPUT_D4(i);
        //         APPLY_INPUT_D10(i);
    
        //         $display("%d", out_val_10);
        //     c1;
        // end

        in_val_10 = 10'd124;
        $monitor("time=%3d, in=%d, out=%d, clk=%b", $time, in_val_10, out_val_10, clk);
        /* current output:
time= 25, in= 154, out=   0, clk=1
time= 30, in= 154, out=   0, clk=0
time= 35, in= 154, out=   0, clk=1
time= 40, in= 154, out=   0, clk=0
time= 45, in= 154, out=   0, clk=1
time= 50, in= 154, out=   0, clk=0
time= 55, in= 154, out=   0, clk=1
time= 60, in= 154, out=   0, clk=0
time= 65, in= 154, out= 501, clk=1
time= 70, in= 154, out= 501, clk=0
time= 75, in= 154, out= 501, clk=1
time= 80, in= 154, out= 501, clk=0
time= 85, in= 154, out= 501, clk=1
time= 90, in= 154, out= 501, clk=0
time= 95, in= 154, out= 501, clk=1
test_decompress.v:84: $finish called at 100000 (1ps)
time=100, in= 154, out= 501, clk=0
        */
    end

    // End simulation
    initial begin
        #100;
        $finish;
    end
endmodule