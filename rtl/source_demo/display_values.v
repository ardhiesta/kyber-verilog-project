module display_values;
    reg [31:0] a;
    reg [7:0] b;

    initial begin
        // Initialize values
        a = 31'h79;

        // Display values
        $display("a = %h", a);
        b = a[7:0];
        $display("b = %h", b);

        // Finish simulation
        $finish;
    end
endmodule

/*
a = 31'h79; output a = 00000079
a[7:0] = 79
a[31:24] = 00
*/