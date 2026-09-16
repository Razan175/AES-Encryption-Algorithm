module ShiftRows (
    input [31:0] State [4],
    output reg[31:0] Shift_Out [4] 
);

/*
EXAMPLE
    Input:
    {
        00 01 02 03
        10 11 12 13
        20 21 22 23
        30 31 32 33
    }
    Output:
    {
        00 01 02 03
        11 12 13 10
        22 23 20 21
        33 30 31 32
    }
*/
genvar i;
generate;
    for (i = 0; i < 4; i+=1) begin
        reg [31:0] Round_Bytes;
        reg [31:0] Shifted_Bytes;

        //Shift right while ignoring the rounded bytes
        //Ex: {20 21 22 23} for i = 2 -> {22 23 00 00}
        assign Shifted_Bytes = {State[i] >> i*8};

        //Shift the bytes that are supposed to be rounded to the left to put them in their position
        //Ex: {20 21 22 23} for i = 2 -> {00 00 20 21}
        assign Round_Bytes = {State[i] << (4-i)*8};

        //Or the Result
        //Ex: {22 23 00 00} | {00 00 20 21} = {22 23 20 21}
        assign Shift_Out[i] = Shifted_Bytes | Round_Bytes;
    end
endgenerate
    
endmodule