module MixColumns (
    input [31:0] State [4],
    output reg[31:0] Mix_Out [4]  
);
/*
    x.02 = x <<1, 
    X.03 = (X<<1)^X
    if X[7] xor the result with 8'1b
*/
genvar i,j;
generate;
    //Iterating over the column byte by byte
    for (i = 0; i < 32; i += 8) begin
        reg [7:0] Mult_GF2[4],Mult_GF3[4];
        
        //Calculating the multiplication by 2,3 for each element in the column
        for (j = 0; j < 4; j+=1) begin
            assign Mult_GF2[j] = Mult_2(State[j][i+7:i]);
            assign Mult_GF3[j] = Mult_3(State[(j+1)%4][i+7:i]);
        end
        
        //Calculating the value of each column element
        assign Mix_Out[0][i+7:i] = Mult_GF2[0] ^ Mult_GF3[0] ^ State[2][i+7:i] ^ State[3][i+7:i];
        assign Mix_Out[1][i+7:i] = Mult_GF2[1] ^ Mult_GF3[1]  ^ State[0][i+7:i] ^ State[3][i+7:i];
        assign Mix_Out[2][i+7:i] = Mult_GF2[2] ^ Mult_GF3[2] ^ State[0][i+7:i] ^ State[1][i+7:i];
        assign Mix_Out[3][i+7:i] = Mult_GF2[3] ^ Mult_GF3[3] ^ State[1][i+7:i] ^ State[2][i+7:i];
    end
endgenerate

function [7:0] Mult_2 (input [7:0] mult);
    //GF(2^8) multiplication by 2
    Mult_2 = mult[7]? (mult << 1) :(mult << 1) ^ 8'h1b;
endfunction

function [7:0] Mult_3 (input [7:0] mult);
    //GF(2^8) multiplication by 3
    //Here we don't need to check mult[7] because the function Mult_2 handles it
    Mult_3 =  Mult_2(mult) ^ mult;
endfunction
    
endmodule