`include "elevator.v"

module elevator_test;
    reg F1, F2, F3, F4;
    reg U1, U2, U3, U4;
    reg D1, D2, D3, D4;
    reg S1, S2, S3, S4;
    reg RESET;
    reg CLK;

    wire [1:0] AC;
    wire [2:0] DISP;
    wire Open;

    elevator elev(
        .F1(F1), .F2(F2), .F3(F3), .F4(F4),
        .U1(U1), .U2(U2), .U3(U3), .U4(U4),
        .D1(D1), .D2(D2), .D3(D3), .D4(D4),
        .S1(S1), .S2(S2), .S3(S3), .S4(S4),
        .RESET(RESET), .CLK(CLK),
        .AC(AC), .DISP(DISP), .Open(Open)
    );

    initial begin
        $dumpfile("elevator_test.vcd");
        $dumpvars(0, elevator_test);

        F1 = 0; F2 = 0; F3 = 0; F4 = 0;
        U1 = 0; U2 = 0; U3 = 0; U4 = 0;
        D1 = 0; D2 = 0; D3 = 0; D4 = 0;
        S1 = 1; S2 = 0; S3 = 0; S4 = 0;
        RESET = 1;
        CLK = 0;

        #100 U1 = 1;
        #100 U1 = 0; F4 = 1;
        #100 F4 = 0; S1 = 0; S2 = 1; U3 = 1;
        #100 U3 = 0; S2 = 0; S3 = 1; D2 = 1;
        #100 D2 = 0; S3 = 0; S4 = 1; U3 = 1;
        #100 U3 = 0; S4 = 0; S3 = 1; F1 = 1;
        #100 F1 = 0; S3 = 0; S2 = 1;
        #100 S2 = 0; S1 = 1; U3 = 1;
        #100 RESET = 0;

        #100 $finish;
    end

    always #5 CLK = ~CLK;

endmodule