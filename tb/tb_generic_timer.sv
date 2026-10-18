`timescale 1ns/1ps

module tb_generic_timer;
    logic clk = 1'b0;
    logic rst = 1'b1;

    logic start4 = 1'b0;
    logic start5 = 1'b0;
    logic start8 = 1'b0;
    logic [3:0] target4 = 4'd3;
    logic [4:0] target5 = 5'd5;
    logic [7:0] target8 = 8'd8;
    logic done4, done5, done8;
    logic [3:0] count4;
    logic [4:0] count5;
    logic [7:0] count8;

    integer errors = 0;
    integer cycle;

    generic_timer #(.COUNTER_WIDTH(4)) u_timer4 (
        .clk(clk), .rst(rst), .start(start4), .count_target(target4),
        .done(done4), .count_dbg(count4)
    );
    generic_timer #(.COUNTER_WIDTH(5)) u_timer5 (
        .clk(clk), .rst(rst), .start(start5), .count_target(target5),
        .done(done5), .count_dbg(count5)
    );
    generic_timer #(.COUNTER_WIDTH(8)) u_timer8 (
        .clk(clk), .rst(rst), .start(start8), .count_target(target8),
        .done(done8), .count_dbg(count8)
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
        $dumpfile("tb_generic_timer.vcd");
        $dumpvars(0, tb_generic_timer);

        repeat (2) @(negedge clk);
        check(count4 == 0 && count5 == 0 && count8 == 0,
              "Reset clears all parameterized timers");
        rst = 1'b0;
        start4 = 1'b1;
        start5 = 1'b1;
        start8 = 1'b1;

        // With targets 3, 5 and 8, each timer should pulse done
        // at multiples of its target while start remains asserted.
        for (cycle = 1; cycle <= 8; cycle = cycle + 1) begin
            @(posedge clk);
            #1;
            check(done4 == ((cycle % 3) == 0),
                  $sformatf("COUNTER_WIDTH=4 target=3 done timing at cycle %0d", cycle));
            check(done5 == ((cycle % 5) == 0),
                  $sformatf("COUNTER_WIDTH=5 target=5 done timing at cycle %0d", cycle));
            check(done8 == (cycle == 8),
                  $sformatf("COUNTER_WIDTH=8 target=8 done timing at cycle %0d", cycle));
        end

        // Target zero must complete on the next active clock.
        @(negedge clk);
        start4 = 1'b0;
        start5 = 1'b0;
        target8 = 8'd0;
        start8 = 1'b1;
        @(posedge clk);
        #1;
        check(done8 == 1'b1, "Zero target completes immediately when started");

        // Reset while counting must clear the debug counter and done flag.
        @(negedge clk);
        target8 = 8'd8;
        rst = 1'b1;
        @(posedge clk);
        #1;
        check(count8 == 0 && done8 == 0,
              "Reset asserted during operation clears count and done");

        $display("TIMER TEST SUMMARY: errors=%0d", errors);
        if (errors == 0) $display("TB_GENERIC_TIMER: PASS");
        else             $display("TB_GENERIC_TIMER: FAIL");
        $finish;
    end
endmodule
