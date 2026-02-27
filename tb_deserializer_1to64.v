`timescale 1ns/1ps

module tb_deserializer_1to64;

    reg clk_serial;
    reg reset_n;
    reg data_in;

    wire [63:0] data_out;
    wire data_valid;

    // DUT
    deserializer_1to64 dut (
        .clk_serial(clk_serial),
        .reset_n(reset_n),
        .data_in(data_in),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    // 1GHz clock
    initial clk_serial = 0;
    always #0.5 clk_serial = ~clk_serial;

    // Reset
    initial begin
        reset_n = 0;
        data_in = 0;
        #5;
        reset_n = 1;
    end

    // Test patterns
    reg [63:0] pattern [0:1];
    integer i, j;

    initial begin
        pattern[0] = 64'hA5A5A5A5A5A5A5A5;
        pattern[1] = 64'hF0F0F0F0F0F0F0F0;

        wait(reset_n);

        for (i = 0; i < 2; i = i + 1) begin
            for (j = 63; j >= 0; j = j - 1) begin
                @(posedge clk_serial);
                data_in = pattern[i][j];
            end
        end

        #100;
        $finish;
    end

    // Self-checking
    integer word_index = 0;

    always @(posedge clk_serial) begin
        if (data_valid) begin
            if (data_out !== pattern[word_index])
                $display("ERROR @ %t  Exp=%h  Got=%h",
                         $time, pattern[word_index], data_out);
            else
                $display("PASS  @ %t  %h",
                         $time, data_out);

            word_index = word_index + 1;
        end
    end

    initial begin
        $dumpfile("deserializer_1to64.vcd");
        $dumpvars(0, tb_deserializer_1to64);
    end

endmodule
