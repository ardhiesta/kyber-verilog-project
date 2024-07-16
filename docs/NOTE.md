# My Personal Note on Verilog

## Display Intermediate Values

for example:

```
module moduleName(in, out);
    input  [1599:0] in;
    output [1599:0] out;

    wire   [63:0]   a[4:0][4:0];

    // some code here
endmodule;
```

we can display the value of variable **a** in the testbench

use **module_instantiated_name.variable_name**

```
module tb;
    reg [1599:0] in;
    wire [1599:0] out;

    // Instantiate the Unit Under Test (UUT)
    round uut (
        .in(in),
        .out(out)
    );

    initial begin
        #3
        in = 16'h0600;
        $display("time=%3d, a=%h", $time, uut.a[0][0]);
        #250
        $display("time=%3d, a=%h", $time, uut.a[0][0]);
    end
endmodule;
```