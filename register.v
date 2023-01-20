module register (
    input in,
    input clr,
    output reg out
);
    initial begin
        out = 0;
    end
    
    always @(*) begin
        if (clr)
            out = 0;
        else if (in)
            out = 1;
    end

endmodule