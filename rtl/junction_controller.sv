`timescale 1ns/1ps

module junction_controller #(
    parameter int COUNTER_WIDTH    = 8,
    parameter int GREEN_TIME       = 5,
    parameter int MIN_GREEN_TIME   = 3,
    parameter int MAX_GREEN_TIME   = 8,
    parameter int GREEN_EXTENSION  = 1,
    parameter int YELLOW_TIME      = 2,
    parameter int RED_TIME         = 1,
    parameter int PED_TIME         = 3
)(
    input  logic clk,
    input  logic rst,
    input  logic run_enable,
    input  logic force_all_red,
    input  logic ped_request,
    input  logic [2:0] traffic_density,

    output logic ns_green,
    output logic ns_yellow,
    output logic ew_green,
    output logic ew_yellow,
    output logic all_red,
    output logic ped_walk,
    output logic [2:0] state_dbg,
    output logic [COUNTER_WIDTH-1:0] green_target_dbg
);

    typedef enum logic [2:0] {
        ST_NS_GREEN  = 3'd0,
        ST_NS_YELLOW = 3'd1,
        ST_ALL_RED_1 = 3'd2,
        ST_PED       = 3'd3,
        ST_EW_GREEN  = 3'd4,
        ST_EW_YELLOW = 3'd5,
        ST_ALL_RED_2 = 3'd6
    } state_t;

    state_t state;
    state_t next_state;

    logic ped_pending;

    logic timer_start;
    logic timer_done;
    logic [COUNTER_WIDTH-1:0] timer_target;

    logic [COUNTER_WIDTH-1:0] adaptive_green_time;

    // Density sampled at the beginning of each green phase
    // and held fixed during that green phase.
    logic [2:0] density_latched;

    // Used to detect B's transition from disabled to enabled.
    logic run_enable_d;


    // ========================================================
    // PEDESTRIAN REQUEST LATCH
    // ========================================================

    always_ff @(posedge clk) begin
        if (rst) begin
            ped_pending <= 1'b0;
        end
        else if (force_all_red) begin
            ped_pending <= 1'b0;
        end
        else begin
            if (ped_request)
                ped_pending <= 1'b1;

            if (state == ST_PED)
                ped_pending <= 1'b0;
        end
    end


    // ========================================================
    // RUN ENABLE HISTORY
    // ========================================================

    always_ff @(posedge clk) begin
        if (rst)
            run_enable_d <= 1'b0;
        else
            run_enable_d <= run_enable;
    end


    // ========================================================
    // TRAFFIC DENSITY SAMPLING
    //
    // Density is sampled when a new green phase starts.
    // The sampled value remains fixed during that green phase.
    // ========================================================

    always_ff @(posedge clk) begin
        if (rst) begin
            density_latched <= traffic_density;
        end
        else if ((next_state == ST_NS_GREEN) &&
                 (state != ST_NS_GREEN)) begin

            density_latched <= traffic_density;
        end
        else if ((next_state == ST_EW_GREEN) &&
                 (state != ST_EW_GREEN)) begin

            density_latched <= traffic_density;
        end
        else if (run_enable && !run_enable_d) begin
            density_latched <= traffic_density;
        end
    end


    // ========================================================
    // ADAPTIVE GREEN TIME
    // ========================================================

    always_comb begin

        adaptive_green_time =
            MIN_GREEN_TIME +
            (density_latched * GREEN_EXTENSION);

        if (adaptive_green_time < MIN_GREEN_TIME)
            adaptive_green_time = MIN_GREEN_TIME;

        if (adaptive_green_time > MAX_GREEN_TIME)
            adaptive_green_time = MAX_GREEN_TIME;

    end


    // ========================================================
    // STATE REGISTER
    // ========================================================

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= ST_NS_GREEN;
        end
        else if (force_all_red) begin
            state <= ST_ALL_RED_1;
        end
        else if (!run_enable) begin
            state <= ST_ALL_RED_1;
        end
        else if (run_enable && !run_enable_d) begin
            // Start Junction B with NS green after wave delay.
            state <= ST_NS_GREEN;
        end
        else begin
            state <= next_state;
        end
    end


    // ========================================================
    // TIMER TARGET
    // ========================================================

    always_comb begin

        timer_start  = 1'b1;
        timer_target = RED_TIME;

        case (state)

            ST_NS_GREEN:
                timer_target = adaptive_green_time;

            ST_NS_YELLOW:
                timer_target = YELLOW_TIME;

            ST_ALL_RED_1:
                timer_target = RED_TIME;

            ST_PED:
                timer_target = PED_TIME;

            ST_EW_GREEN:
                timer_target = adaptive_green_time;

            ST_EW_YELLOW:
                timer_target = YELLOW_TIME;

            ST_ALL_RED_2:
                timer_target = RED_TIME;

            default:
                timer_target = RED_TIME;

        endcase
    end


    // ========================================================
    // GENERIC TIMER INSTANCE
    // ========================================================

    generic_timer #(
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) u_timer (
        .clk(clk),
        .rst(rst),
        .start(timer_start),
        .count_target(timer_target),
        .done(timer_done),
        .count_dbg()
    );


    // ========================================================
    // FSM NEXT STATE
    // ========================================================

    always_comb begin

        next_state = state;

        case (state)

            ST_NS_GREEN: begin
                if (timer_done)
                    next_state = ST_NS_YELLOW;
            end

            ST_NS_YELLOW: begin
                if (timer_done)
                    next_state = ST_ALL_RED_1;
            end

            ST_ALL_RED_1: begin
                if (timer_done) begin
                    if (ped_pending || ped_request)
                        next_state = ST_PED;
                    else
                        next_state = ST_EW_GREEN;
                end
            end

            ST_PED: begin
                if (timer_done)
                    next_state = ST_EW_GREEN;
            end

            ST_EW_GREEN: begin
                if (timer_done)
                    next_state = ST_EW_YELLOW;
            end

            ST_EW_YELLOW: begin
                if (timer_done)
                    next_state = ST_ALL_RED_2;
            end

            ST_ALL_RED_2: begin
                if (timer_done) begin
                    if (ped_pending || ped_request)
                        next_state = ST_PED;
                    else
                        next_state = ST_NS_GREEN;
                end
            end

            default:
                next_state = ST_NS_GREEN;

        endcase
    end


    // ========================================================
    // OUTPUT LOGIC
    // ========================================================

    always_comb begin

        ns_green  = 1'b0;
        ns_yellow = 1'b0;
        ew_green  = 1'b0;
        ew_yellow = 1'b0;
        all_red   = 1'b0;
        ped_walk  = 1'b0;

        if (force_all_red || !run_enable) begin
            all_red = 1'b1;
        end
        else begin

            case (state)

                ST_NS_GREEN:
                    ns_green = 1'b1;

                ST_NS_YELLOW:
                    ns_yellow = 1'b1;

                ST_ALL_RED_1:
                    all_red = 1'b1;

                ST_PED: begin
                    all_red  = 1'b1;
                    ped_walk = 1'b1;
                end

                ST_EW_GREEN:
                    ew_green = 1'b1;

                ST_EW_YELLOW:
                    ew_yellow = 1'b1;

                ST_ALL_RED_2:
                    all_red = 1'b1;

                default:
                    all_red = 1'b1;

            endcase
        end
    end


    // ========================================================
    // DEBUG OUTPUTS
    // ========================================================

    always_comb begin
        state_dbg        = state;
        green_target_dbg = adaptive_green_time;
    end

endmodule
