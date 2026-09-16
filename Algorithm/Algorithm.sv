 module Algorithm #(
    parameter K = 128, // Key length in bits
                      //Only values allowed are: 128, 192, 256
    parameter Nr = 10
) (
    input clk, rst_n, en,
    input [127:0] PlainText,
    input [K - 1:0] Key,
    output [127:0] CypherText
);

localparam Nk = K/32; //The number of 32-bit words in the cipher key

localparam Nb = 4; //Represents the number of 32-bit words in the state

//The number of rounds to be preformed by the algorithm, dependent on the key size.
generate
    case (Nk)
        4: localparam Nr = 10; 
        6: localparam Nr = 12; 
        8: localparam Nr = 14; 
        default: localparam Nr = 10;
    endcase
endgenerate

//PlainText and Key in Matrix Form
reg [31:0] State [Nb];
reg [31:0] Key_Matrix [Nb];

reg [31:0] W [Nr + 1][Nb];
KeyExpansion #(.Nk(Nk), .Nr(Nr)) KE (.clk(clk), .rst_n(rst_n), .en(en), .Key(Key_Matrix), .W(W));

//Mapping the PlainText and Key to their matrix form
genvar i,j;
generate
    for(i = 0; i < 4; i+=1) begin 
        for(j = 0; j < 4; j+=1) begin 
            assign State[i][j*8+7:j*8] = PlainText[(((3 -i) + (3-j)*4)*8+7):((3 -i) + (3-j)*4)*8];        
            assign Key_Matrix[i][j*8+7:j*8] = Key[(((3 -i) + (3-j)*Nk)*8+7):((3 -i) + (3-j)*Nk)*8];        
        end
    end
endgenerate

genvar k;    
    reg [31:0] Sub_State [Nr + 1][Nb], Shift_State[Nr][Nb], Mix_State[Nr + 2][Nb], Add_State[Nr][Nb];
    
    //For inital transformation
    assign Mix_State[0] = State;

    //Transformations loop
    for (k = 0; k < Nr; k+=1) begin
        reg [31:0] Add_State_Reg[Nb];
        always @(posedge clk or negedge rst_n) begin
            if (~rst_n) begin
                Add_State_Reg <= {0,0,0,0};
            end begin
                Add_State_Reg <= Mix_State[k];
            end
        end
        AddRoundKey #(.Nk(Nk)) AR0 (.clk(clk),.rst_n(rst_n),.State(Add_State_Reg), .W(W[k]), .AddRound_Out(Add_State[k]));
        SubBytes SB1(.State(Add_State[k]), .Sub_Out(Sub_State[k]));
        ShiftRows SR1(.State(Sub_State[k]), .Shift_Out(Shift_State[k]));
        MixColumns MC1(.State(Shift_State[k]),.Mix_Out(Mix_State[k + 1]));
    end
    
    AddRoundKey AR1 (.clk(clk),.rst_n(rst_n),.State(Mix_State[Nr + 1]), .W(W[Nr]), .AddRound_Out(Add_State[Nr + 1]));
    
    //Final Transformation
    SubBytes SB1(.State(Add_State[Nr + 1]), .Sub_Out(Sub_State[Nr]));
    ShiftRows SR1(.State(Sub_State[Nr]), .Shift_Out(Shift_State[Nr]));
    AddRoundKey AR2 (.clk(clk),.rst_n(rst_n),.State(Mix_State[Nr + 2]), .W(W[Nr + 1]), .AddRound_Out(Add_State[Nr + 2]));
    
 endmodule

/*
 force -freeze sim:/Algorithm/PlainText 128'h00112233445566778899aabbccddeeff 0
force -freeze sim:/Algorithm/Key 128'h000102030405060708090a0b0c0d0e0f 0
force -freeze sim:/Algorithm/PlainText 128'h00112233445566778899aabbccddeeff 0
run
force -freeze sim:/Algorithm/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/Algorithm/en 1'h1 0
force -freeze sim:/Algorithm/rst_n 1'h0 0
run
run
force -freeze sim:/Algorithm/rst_n 1'h1 0
run
run
run
run
run
run
run
 */