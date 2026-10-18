`timescale 1ns/1ps

module tb_amtgc_top;
    logic clk = 1'b0;
    logic rst = 1'b1;
    logic emergency = 1'b0;
    logic ped_req_A = 1'b0;
    logic ped_req_B = 1'b0;
    logic [2:0] traffic_density_A = 3'd0;
    logic [2:0] traffic_density_B = 3'd0;

    logic A_ns_green, A_ns_yellow, A_ew_green, A_ew_yellow, A_all_red, A_ped_walk;
    logic B_ns_green, B_ns_yellow, B_ew_green, B_ew_yellow, B_all_red, B_ped_walk;
    logic ped_grant_A, ped_grant_B;
    logic [2:0] A_state, B_state;
    logic [7:0] wave_counter_dbg, A_green_target_dbg, B_green_target_dbg;
    logic B_run_enable_dbg;
    integer errors = 0;
    integer timeout_count;
    logic first_grant_A;

    amtgc_top #(
        .COUNTER_WIDTH(8), .A_GREEN_TIME(5), .B_GREEN_TIME(5),
        .A_MIN_GREEN_TIME(3), .B_MIN_GREEN_TIME(3),
        .A_MAX_GREEN_TIME(8), .B_MAX_GREEN_TIME(8), .GREEN_EXTENSION(1),
        .YELLOW_TIME(2), .RED_TIME(1), .PED_TIME(3), .WAVE_DELAY(3)
    ) dut (
        .clk(clk), .rst(rst), .emergency(emergency),
        .ped_req_A(ped_req_A), .ped_req_B(ped_req_B),
        .traffic_density_A(traffic_density_A), .traffic_density_B(traffic_density_B),
        .A_ns_green(A_ns_green), .A_ns_yellow(A_ns_yellow),
        .A_ew_green(A_ew_green), .A_ew_yellow(A_ew_yellow),
        .A_all_red(A_all_red), .A_ped_walk(A_ped_walk),
        .B_ns_green(B_ns_green), .B_ns_yellow(B_ns_yellow),
        .B_ew_green(B_ew_green), .B_ew_yellow(B_ew_yellow),
        .B_all_red(B_all_red), .B_ped_walk(B_ped_walk),
        .ped_grant_A(ped_grant_A), .ped_grant_B(ped_grant_B),
        .A_state(A_state), .B_state(B_state),
        .wave_counter_dbg(wave_counter_dbg), .B_run_enable_dbg(B_run_enable_dbg),
        .A_green_target_dbg(A_green_target_dbg), .B_green_target_dbg(B_green_target_dbg)
    );

    always #5 clk = ~clk;

    task automatic check(input logic condition, input string message);
        begin
            if (condition)
                $display("[PASS] %s", message);
            else begin
                $display("[FAIL] %s", message);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_amtgc_top.vcd");
        $dumpvars(0, tb_amtgc_top);
        repeat (2) @(negedge clk);
        check(A_ns_green && B_all_red && !B_run_enable_dbg,
              "Junction A starts while Junction B remains all-red during startup delay");
        rst = 1'b0;

        timeout_count = 0;
        while (!B_run_enable_dbg && timeout_count < 20) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end
        check(B_run_enable_dbg, "Green-wave startup delay enables Junction B");

        timeout_count = 0;
        while (!B_ns_green && timeout_count < 20) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end
        check(B_ns_green, "Junction B begins its NS green after enable");

        // Two simultaneous requests: only one grant may be asserted.
        @(negedge clk);
        ped_req_A = 1'b1;
        ped_req_B = 1'b1;
        @(negedge clk);
        #1;
        check(ped_grant_A ^ ped_grant_B,
              "Simultaneous pedestrian requests produce exactly one grant");
        first_grant_A = ped_grant_A;
        ped_req_A = 1'b0;
        ped_req_B = 1'b0;
        @(negedge clk);
        @(negedge clk);

        // Reassert both requests; round-robin tie handling should switch grant.
        ped_req_A = 1'b1;
        ped_req_B = 1'b1;
        @(negedge clk);
        #1;
        check(ped_grant_A ^ ped_grant_B,
              "Second simultaneous pedestrian request still has a single grant");
        check(ped_grant_A != first_grant_A,
              "Round-robin tie resolution alternates the next grant");
        ped_req_A = 1'b0;
        ped_req_B = 1'b0;

        emergency = 1'b1;
        #1;
        check(A_all_red && B_all_red && !A_ns_green && !A_ew_green &&
              !B_ns_green && !B_ew_green,
              "Emergency override forces both junctions to all-red");
        repeat (2) @(negedge clk);
        check(A_all_red && B_all_red,
              "Both junctions remain all-red while emergency is asserted");
        emergency = 1'b0;
        @(negedge clk);

        traffic_density_A = 3'd7;
        traffic_density_B = 3'd7;
        repeat (40) @(negedge clk);
        check(A_green_target_dbg >= 3 && A_green_target_dbg <= 8,
              "Junction A adaptive green target stays within configured limits");
        check(B_green_target_dbg >= 3 && B_green_target_dbg <= 8,
              "Junction B adaptive green target stays within configured limits");

        $display("AMTGC TOP TEST SUMMARY: errors=%0d", errors);
        if (errors == 0) $display("TB_AMTGC_TOP: PASS");
        else             $display("TB_AMTGC_TOP: FAIL");
        $finish;
    end
endmodule
