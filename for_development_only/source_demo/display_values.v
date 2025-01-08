module display_values;
    reg [31:0] a;
    reg [7:0] b;
    reg [575:0] c, d, e;

    initial begin
        // Initialize values
        a = 31'h79;

        // Display values
        $display("a = %h", a);
        b = a[7:0];
        $display("b = %h", b);
        c = { 8'h90, 8'h06, 552'h0, 8'h80 };
        d = 576'h90abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef1111111190abcdef111111110600000000000000;
        $display("d = %h", d[575:32]);
        e = 512'h56ac4f6845a451dac3e8886f97f7024b64b1b1e9c5181c059b5755b9a6042be653a2a0d5d56a9e1e774be5c9312f48b4798019345beae2ffcc63554a3c69862e;
        $display("e = %h", e);

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