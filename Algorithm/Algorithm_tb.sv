module Algorithm_tb;
    reg clk, rst_n, en;
    reg [127:0] PlainText;
    reg [127:0] Key;
    wire [127:0] CypherText;

    Algorithm DUT(.*);

    initial forever clk = #10 ~clk;
    initial begin
        clk = 0; rst_n = 0; en = 1; PlainText = 128'h00112233445566778899aabbccddeeff; Key = 128'h000102030405060708090a0b0c0d0e0f;
        @(negedge clk);
        rst_n = 1;
        for (int i = 0; i < 10; i += 1) @(negedge clk);

        if (CypherText == 128'h000102030405060708090a0b0c0d0e0f)
            $display("Succes");
        else 
            $display("Fail");
    end
endmodule