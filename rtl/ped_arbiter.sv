`timescale 1ns/1ps

module ped_arbiter (
    input  logic clk,
    input  logic rst,
    input  logic ped_req_A,
    input  logic ped_req_B,
    output logic ped_grant_A,
    output logic ped_grant_B
);

    logic [1:0] active_grant;
    logic last_grant;

    always_ff @(posedge clk) begin

        if (rst) begin
            active_grant <= 2'b00;
            last_grant   <= 1'b1;
        end
        else begin

            if (active_grant == 2'b00) begin

                if (ped_req_A && ped_req_B) begin

                    if (last_grant == 1'b0) begin
                        active_grant <= 2'b10;
                        last_grant   <= 1'b1;
                    end
                    else begin
                        active_grant <= 2'b01;
                        last_grant   <= 1'b0;
                    end

                end
                else if (ped_req_A) begin
                    active_grant <= 2'b01;
                    last_grant   <= 1'b0;
                end
                else if (ped_req_B) begin
                    active_grant <= 2'b10;
                    last_grant   <= 1'b1;
                end

            end
            else if (active_grant == 2'b01) begin

                if (!ped_req_A)
                    active_grant <= 2'b00;

            end
            else if (active_grant == 2'b10) begin

                if (!ped_req_B)
                    active_grant <= 2'b00;

            end
            else begin
                active_grant <= 2'b00;
            end
        end
    end


    always_comb begin

        ped_grant_A = 1'b0;
        ped_grant_B = 1'b0;

        case (active_grant)

            2'b01:
                ped_grant_A = 1'b1;

            2'b10:
                ped_grant_B = 1'b1;

            default: begin
            end

        endcase
    end

endmodule
