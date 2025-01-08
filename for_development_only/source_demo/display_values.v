module display_values;
    reg [31:0] a;
    reg [7:0] b;
    reg [575:0] c;

    initial begin
        // Initialize values
        a = 31'h79;

        // Display values
        $display("a = %h", a);
        b = a[7:0];
        $display("b = %h", b);
        // c = { 8'h90, 8'h06, 552'h0, 8'h80 };
        c = 576'h90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef111111110600000000000000;
        $display("c = %h", c[575:32]);

        // Finish simulation
        $finish;
    end
endmodule

/*
a = 31'h79; output a = 00000079
a[7:0] = 79
a[31:24] = 00
c = 900600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080
*/