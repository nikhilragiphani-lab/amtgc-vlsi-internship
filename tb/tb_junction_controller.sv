`timescale 1ns/1ps

module tb_junction_controller;
    logic clk = 1'b0;
    logic rst = 1'b1;
    logic run_enable = 1'b1;
    logic force_all_red = 1'b0;
    logic ped_request = 1'b0;
    logic [2:0] traffic_density = 3'd0;

    logic ns_green, ns_yellow, ew_green, ew_yellow, all_red, ped_walk;
    logic [2:0] state_dbg;
    logic [7:0] green_target_dbg;
    integer errors = 0;
    integer timeout_count;

    junction_controller #(
        .COUNTER_WIDTH(8), .GREEN_TIME(5),
        .MIN_GREEN_TIME(3), .MAX_GREEN_TIME(8), .GREEN_EXTENSION(1),
        .YELLOW_TIME(2), .RED_TIME(1), .PED_TIME(3)
    ) dut (
        .clk(clk), .rst(rst), .run_enable(run_enable),
        .force_all_red(force_all_red), .ped_request(ped_request),
        .traffic_density(traffic_density), .ns_green(ns_green),
        .ns_yellow(ns_yellow), .ew_green(ew_green), .ew_yellow(ew_yellow),
        .all_red(all_red), .ped_walk(ped_walk), .state_dbg(state_dbg),
        .green_target_dbg(green_target_dbg)
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
        $dumpfile("tb_junction_controller.vcd");
        $dumpvars(0, tb_junction_controller);

        repeat (2) @(negedge clk);
        check(state_dbg == 3'd0 && ns_green,
              "Reset initializes controller to NS green");
        check(green_target_dbg >= 3 && green_target_dbg <= 8,
              "Adaptive green target starts inside configured limits");
        rst = 1'b0;

        timeout_count = 0;
        while (ns_yellow !== 1'b1 && timeout_count < 40) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end
        check(ns_yellow, "NS green transitions to NS yellow");

        // Request pedestrians while the NS yellow phase is active.
        ped_request = 1'b1;
        @(negedge clk);
        ped_request = 1'b0;

        timeout_count = 0;
        while (ped_walk !== 1'b1 && timeout_count < 40) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end
        check(ped_walk && all_red,
              "Pedestrian request during yellow is serviced in pedestrian phase");
        check(!(ns_green && ew_green),
              "NS and EW green are never active together during pedestrian test");

        timeout_count = 0;
        while (ew_green !== 1'b1 && timeout_count < 40) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end
        check(ew_green, "Controller resumes to EW green after pedestrian service");

        timeout_count = 0;
        while (ew_yellow !== 1'b1 && timeout_count < 40) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end
        check(ew_yellow, "EW green transitions to EW yellow");

        timeout_count = 0;
        while (ns_green !== 1'b1 && timeout_count < 50) begin
            @(negedge clk);
            timeout_count = timeout_count + 1;
        end
        check(ns_green, "Controller completes cycle and returns to NS green");

        // Emergency/all-red override is an input to a single controller.
        force_all_red = 1'b1;
        #1;
        check(all_red && !ns_green && !ew_green && !ns_yellow && !ew_yellow,
              "Force-all-red overrides all vehicle signal outputs");
        @(negedge clk);
        force_all_red = 1'b0;

        $display("CONTROLLER TEST SUMMARY: errors=%0d", errors);
        if (errors == 0) $display("TB_JUNCTION_CONTROLLER: PASS");
        else             $display("TB_JUNCTION_CONTROLLER: FAIL");
        $finish;
    end
endmodule
