`timescale 1ns/1ps

// ============================================================
// 1-to-64 Deserializer (Full-rate, Counter-based)
// ============================================================
module deserializer_1to64 (
    input  wire        clk_serial,
    input  wire        reset_n,
    input  wire        data_in,
    output reg  [63:0] data_out,
    output reg         data_valid
);

    reg [5:0]  bit_count;     // 0–63 counter
    reg [63:0] shift_reg;

    always @(posedge clk_serial or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg  <= 64'b0;
            bit_count  <= 6'd0;
            data_out   <= 64'b0;
            data_valid <= 1'b0;
        end
        else begin
            // Shift serial data
            shift_reg <= {shift_reg[62:0], data_in};

            if (bit_count == 6'd63) begin
                data_out   <= {shift_reg[62:0], data_in};
                bit_count  <= 6'd0;
                data_valid <= 1'b1;   // One-cycle pulse
            end
            else begin
                bit_count  <= bit_count + 1;
                data_valid <= 1'b0;
            end
        end
    end

endmodule



// ============================================================
// Divide-by-2 and Divide-by-4 Clock Generator
// ============================================================
module divider_by2_quadrature (
    input  wire clk_in,
    input  wire reset_n,
    output reg  clk_half,
    output reg  clk_quarter
);

    // Divide by 2
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n)
            clk_half <= 1'b0;
        else
            clk_half <= ~clk_half;
    end

    // Divide by 4
    always @(posedge clk_half or negedge reset_n) begin
        if (!reset_n)
            clk_quarter <= 1'b0;
        else
            clk_quarter <= ~clk_quarter;
    end

endmodule
