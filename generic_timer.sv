`timescale 1ns/1ps

module generic_timer #(
    parameter int COUNTER_WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [COUNTER_WIDTH-1:0] count_target,
    output logic done,
    output logic [COUNTER_WIDTH-1:0] count_dbg
);

always_ff @(posedge clk) begin
    if (rst) begin
        count_dbg <= '0;
        done      <= 1'b0;
    end
    else begin
        done <= 1'b0;

        if (start) begin
            if (count_target == 0) begin
                count_dbg <= '0;
                done      <= 1'b1;
            end
            else if (count_dbg >= (count_target - 1'b1)) begin
                count_dbg <= '0;
                done      <= 1'b1;
            end
            else begin
                count_dbg <= count_dbg + 1'b1;
            end
        end
        else begin
            count_dbg <= '0;
        end
    end
end

endmodule
