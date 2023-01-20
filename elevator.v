`include "register.v"

module elevator (
    input F1, F2, F3, F4,
    input U1, U2, U3, U4,
    input D1, D2, D3, D4,
    input S1, S2, S3, S4,
    input CLK, RESET,
    output [1:0] AC, 
    output [2:0] DISP,
    output Open
);

reg [1:0] counter;
reg [2:0] state;

wire F1_, F2_, F3_, F4_;
wire U1_, U2_, U3_, U4_;
wire D1_, D2_, D3_, D4_;
reg clrF1, clrF2, clrF3, clrF4;
reg clrU1, clrU2, clrU3, clrU4;
reg clrD1, clrD2, clrD3, clrD4;

register regF1(.in(F1), .clr(clrF1), .out(F1_));
register regF2(.in(F2), .clr(clrF2), .out(F2_));
register regF3(.in(F3), .clr(clrF3), .out(F3_));
register regF4(.in(F4), .clr(clrF4), .out(F4_));

register regU1(.in(U1), .clr(clrU1), .out(U1_));
register regU2(.in(U2), .clr(clrU2), .out(U2_));
register regU3(.in(U3), .clr(clrU3), .out(U3_));
register regU4(.in(U4), .clr(clrU4), .out(U4_));

register regD1(.in(D1), .clr(clrD1), .out(D1_));
register regD2(.in(D2), .clr(clrD2), .out(D2_));
register regD3(.in(D3), .clr(clrD3), .out(D3_));
register regD4(.in(D4), .clr(clrD4), .out(D4_));

wire B1, B2, B3, B4, NA;
assign B1 = F1_ | U1_ | D1_;
assign B2 = F2_ | U2_ | D2_;
assign B3 = F3_ | U3_ | D3_;
assign B4 = F4_ | U4_ | D4_;
assign NA = ~(B1 | B2 | B3 | B4);

assign DISP = (S1 == 1) ? 1 : ((S2 == 1) ? 2 : ((S3 == 1) ? 3 : 4));
assign AC = (state > 2) ? 2 : state;
assign Open = (state == 4 || state == 5);

initial begin
    clrF1 <= 0; clrF2 <= 0; clrF3 <= 0; clrF4 <= 0;
    clrU1 <= 0; clrU2 <= 0; clrU3 <= 0; clrU4 <= 0;
    clrD1 <= 0; clrD2 <= 0; clrD3 <= 0; clrD4 <= 0;

    counter <= 0;
    state <= 2;
end

always @(posedge CLK) begin
    if (Open == 1)
        counter <= counter + 1;
    else
        counter <= 0;
end

always @(posedge CLK or negedge RESET) begin
    if (!RESET) begin 
        {clrF1, clrF2, clrF3, clrF4} <= 4'b1111;
        {clrU1, clrU2, clrU3, clrU4} <= 4'b1111;
        {clrD1, clrD2, clrD3, clrD4} <= 4'b1111;
        state <= 2;
    end
    else begin
        case (state) 
            0: begin  //up
                if ((S2 && (!F2_ && !U2_ && (B3 || B4))) ||
                    (S3 && (!F3_ && !U3_ && B4)))
                    state <= 0;
                
                else if ((S2 && (F2_ || U2_ || (!B3 && !B4 && D2_))) ||
                        (S3 && (F3_ || U3_ || (!B4 && D3_))))
                    state <= 2;
                
                else if (S4 && (B4))
                    state <= 3;
            end
            1: begin  //down
                if ((S3 && (!F3_ && !D3_ && (B1 || B2))) ||
                    (S2 && (!F2_ && !D2_ && B1)))
                    state <= 1;

                else if ((S3 && (F3_ || D3_ || (!B1 && !B2 && U3_))) ||
                        (S2 && (F2_ || D2_ || (!B1 && U2_))))
                    state <= 3;
                
                else if (S1 && (B1))
                    state <= 2;
            end
            2: begin  //stopu
                {clrF1, clrU1, clrD1} = 3'b000;
                {clrF2, clrU2, clrD2} = 3'b000;
                {clrF3, clrU3, clrD3} = 3'b000;
                if (NA)
                    state <= 2;
                
                else if ((S1 && B1) || (S2 && B2) ||
                        (S3 && B3) || (S4 && B4))
                    state <= 4;

                else if ((S2 && !B2 && !B3 && !B4 && (B1)) || 
                        (S3 && !B3 && !B4 && (B1 || B2)))
                    state <= 3;
                
                else if ((S1 && !B1 && (B2 || B3 || B4)) ||
                        (S2 && !B2 && (B3 || B4)) || 
                        (S3 && !B3 && (B4)))
                    state <= 0;
            end
            3: begin  //stopd
                {clrF2, clrU2, clrD2} = 3'b000;
                {clrF3, clrU3, clrD3} = 3'b000;
                {clrF4, clrU4, clrD4} = 3'b000;

                if (NA)
                    state <= 3;

                else if ((S1 && B1) || (S2 && B2) ||
                        (S3 && B3) || (S4 && B4))
                    state <= 5;

                else if ((S2 && !B2 && !B1 && (B3 || B4)) ||
                        (S3 && !B3 && !B2 && !B1 && (B4)))
                    state <= 2;

                else if ((S2 && !B2 && (B1)) ||
                        (S3 && !B3 && (B1 || B2)) ||
                        (S4 && !B4 && (B1 || B2 || B3)))
                    state <= 1;
            end
            4: begin //stopu door
                wait(counter == 3)

                if (S1)
                    {clrF1, clrU1, clrD1} = 3'b111;
                else if (S2)
                    {clrF2, clrU2, clrD2} = 3'b111;
                else if (S3)
                    {clrF3, clrU3, clrD3} = 3'b111;

                state <= 2;
            end
            5: begin //stopd door
                wait(counter == 3)

                if (S2)
                    {clrF2, clrU2, clrD2} = 3'b111;
                else if (S3)
                    {clrF3, clrU3, clrD3} = 3'b111;
                else if (S4)
                    {clrF4, clrU4, clrD4} = 3'b111;
                
                state <= 3;
            end
        endcase
    end
end

endmodule