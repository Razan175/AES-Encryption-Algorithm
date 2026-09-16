module KeyExpansion #(parameter Nk = 4, Nr = 10)(
    input clk,rst_n,en,
    input [31:0] Key[4],
    output reg [31:0] W[Nr + 1][4]
);
/*
    Nk = 4 -> 4 words 32bits, 44 words total
    Nk = 6 -> 6 words 48bits, 78 words total
    Nk = 8 -> 8 words 64bits, 120 words total 
*/

//Input key converted to words
wire [31:0] Key_Words[Nk];

reg [31:0] Prev_Words[Nk], Xor_Words[4], G_Out;
reg [$ceil($clog2(Nr)) - 1:0] count;

G_Function #(.Nr(Nr)) g (.W(Prev_Words[Nk - 1]), .Round({28'd0,count}), .W_Dash(G_Out));
genvar i,j;
generate
    //Iterate over each word
    for (i = 0; i < Nk; i+=1) begin
        //Iterate over the key rows taking the words in the ith position
        for (j = 0; j < 4; j += 1) begin
            assign Key_Words[i][j*8+7:j*8] = Key[j][i*8+7:i*8];
        end 
    end
endgenerate

genvar k;
generate;
    assign Xor_Words[0] = G_Out ^ Prev_Words[0];
    for (k = Nk - 1; k > 0; k -= 1) begin
        assign Xor_Words[k] = Xor_Words[k - 1] ^ Prev_Words[k];
    end
endgenerate


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        //W <= {0,0,0,0};
        Prev_Words <= {0,0,0,0};
    end else begin
        if (en) begin
            if (count == 0) begin
                //Initial key is the input key converted to words
                W[0] <= Key_Words;
                Prev_Words <= Key_Words;
            end
            else begin
                Prev_Words <= Xor_Words;
                W[count] <= Xor_Words;
            end
        end
    end
    
end



//Counter logic
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        count <= 0;
    end else if (en) begin
        count <= count + 1;
        if (count == Nr - 1)
            count <= 0;
    end
end

    
endmodule