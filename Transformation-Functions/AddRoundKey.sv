module AddRoundKey #(parameter Nk = 4)(
    input clk, rst_n,
    input [31:0] State [4],
    input [31:0] W[4],
    output [31:0] AddRound_Out [4]
);

genvar i,j;
generate;
    //i = 1, j = 3
    //W[1][31:24] ^ State[1][31:24]
    for (i = 0; i < 4; i += 1) begin
        for (j = 0; j < 4; j +=1) begin
            assign AddRound_Out[i][j*8 + 7:j*8] = W[i][j*8 + 7:j*8] ^ State[i][j*8 + 7:j*8];
        end
    end
endgenerate
    
endmodule