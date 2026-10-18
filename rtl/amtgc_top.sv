`timescale 1ns/1ps

module amtgc_top #(
    parameter int COUNTER_WIDTH      = 8,
    parameter int A_GREEN_TIME       = 5,
    parameter int B_GREEN_TIME       = 5,
    parameter int A_MIN_GREEN_TIME   = 3,
    parameter int B_MIN_GREEN_TIME   = 3,
    parameter int A_MAX_GREEN_TIME   = 8,
    parameter int B_MAX_GREEN_TIME   = 8,
    parameter int GREEN_EXTENSION    = 1,
    parameter int YELLOW_TIME        = 2,
    parameter int RED_TIME           = 1,
    parameter int PED_TIME           = 3,
    parameter int WAVE_DELAY         = 3
)(
    input logic clk,
    input logic rst,
    input logic emergency,

    input logic ped_req_A,
    input logic ped_req_B,

    input logic [2:0] traffic_density_A,
    input logic [2:0] traffic_density_B,

    output logic A_ns_green,
    output logic A_ns_yellow,
    output logic A_ew_green,
    output logic A_ew_yellow,
    output logic A_all_red,
    output logic A_ped_walk,

    output logic B_ns_green,
    output logic B_ns_yellow,
    output logic B_ew_green,
    output logic B_ew_yellow,
    output logic B_all_red,
    output logic B_ped_walk,

    output logic ped_grant_A,
    output logic ped_grant_B,

    output logic [2:0] A_state,
    output logic [2:0] B_state,

    output logic [COUNTER_WIDTH-1:0] wave_counter_dbg,
    output logic B_run_enable_dbg,

    output logic [COUNTER_WIDTH-1:0] A_green_target_dbg,
    output logic [COUNTER_WIDTH-1:0] B_green_target_dbg
);

    logic ped_grant_A_int;
    logic ped_grant_B_int;

    logic B_run_enable;

    logic [COUNTER_WIDTH-1:0] wave_counter;


    // ========================================================
    // PEDESTRIAN ARBITER
    // ========================================================

    ped_arbiter u_ped_arbiter (
        .clk(clk),
        .rst(rst),
        .ped_req_A(ped_req_A),
        .ped_req_B(ped_req_B),
        .ped_grant_A(ped_grant_A_int),
        .ped_grant_B(ped_grant_B_int)
    );


    // ========================================================
    // GREEN WAVE
    // ========================================================

    always_ff @(posedge clk) begin

        if (rst)
            wave_counter <= '0;

        else if (emergency)
            wave_counter <= wave_counter;

        else if (wave_counter < WAVE_DELAY)
            wave_counter <= wave_counter + 1'b1;

        else
            wave_counter <= wave_counter;

    end


    always_comb begin

        if (wave_counter >= WAVE_DELAY)
            B_run_enable = 1'b1;
        else
            B_run_enable = 1'b0;

    end


    // ========================================================
    // JUNCTION A
    // ========================================================

    junction_controller #(
        .COUNTER_WIDTH(COUNTER_WIDTH),
        .GREEN_TIME(A_GREEN_TIME),
        .MIN_GREEN_TIME(A_MIN_GREEN_TIME),
        .MAX_GREEN_TIME(A_MAX_GREEN_TIME),
        .GREEN_EXTENSION(GREEN_EXTENSION),
        .YELLOW_TIME(YELLOW_TIME),
        .RED_TIME(RED_TIME),
        .PED_TIME(PED_TIME)
    ) u_junction_A (

        .clk(clk),
        .rst(rst),
        .run_enable(1'b1),
        .force_all_red(emergency),
        .ped_request(ped_grant_A_int),
        .traffic_density(traffic_density_A),

        .ns_green(A_ns_green),
        .ns_yellow(A_ns_yellow),
        .ew_green(A_ew_green),
        .ew_yellow(A_ew_yellow),
        .all_red(A_all_red),
        .ped_walk(A_ped_walk),

        .state_dbg(A_state),
        .green_target_dbg(A_green_target_dbg)
    );


    // ========================================================
    // JUNCTION B
    // ========================================================

    junction_controller #(
        .COUNTER_WIDTH(COUNTER_WIDTH),
        .GREEN_TIME(B_GREEN_TIME),
        .MIN_GREEN_TIME(B_MIN_GREEN_TIME),
        .MAX_GREEN_TIME(B_MAX_GREEN_TIME),
        .GREEN_EXTENSION(GREEN_EXTENSION),
        .YELLOW_TIME(YELLOW_TIME),
        .RED_TIME(RED_TIME),
        .PED_TIME(PED_TIME)
    ) u_junction_B (

        .clk(clk),
        .rst(rst),
        .run_enable(B_run_enable),
        .force_all_red(emergency || !B_run_enable),
        .ped_request(ped_grant_B_int),
        .traffic_density(traffic_density_B),

        .ns_green(B_ns_green),
        .ns_yellow(B_ns_yellow),
        .ew_green(B_ew_green),
        .ew_yellow(B_ew_yellow),
        .all_red(B_all_red),
        .ped_walk(B_ped_walk),

        .state_dbg(B_state),
        .green_target_dbg(B_green_target_dbg)
    );


    // ========================================================
    // DEBUG OUTPUTS
    // ========================================================

    always_comb begin

        ped_grant_A      = ped_grant_A_int;
        ped_grant_B      = ped_grant_B_int;

        wave_counter_dbg = wave_counter;
        B_run_enable_dbg = B_run_enable;

    end

endmodule
