module StopWatch_FSM (
    input i_clk,
    input i_rstn,
    input i_run_not,
    output o_idle,
    output o_running,
    output reg o_done);
	
    // Pram. to define the states and stopwatch sec condition
    parameter IDLE = 2'b00;
    parameter RUN = 2'b01;
    parameter DONE = 2'b10;
    parameter CLK2SEC = 10;       		// supossed to 10Hz for simulation
    parameter WISHSEC = 5;      		// Choice your favorite number!
    
    // Declaration the reg and wire
    reg [3:0] r_clk_cnt;
    reg [2:0] r_sec;
    reg [1:0] state;
    reg [1:0] next;

    wire w_is_done;

    ////////Main////////
    // always block to count or reset the clock
    always@(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn) begin
        r_clk_cnt <= 0;
    end
    else begin
	    if (r_clk_cnt < CLK2SEC-1) r_clk_cnt <= r_clk_cnt + 1;
	    else r_clk_cnt <= 0;
    end
    end

    // always block to count or reset the sec
    always@(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn) begin
        r_sec <= 0;
    end
    else if (r_clk_cnt == CLK2SEC-1) begin
	    if (r_sec < WISHSEC) r_sec <= r_sec + 1;
	    else r_sec <= 0;
    end
    else r_sec <= r_sec;
    end
    
    ////////FSM////////
    // always block to update the current state
    always@(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn) begin
        state <= IDLE; 
    end
    else begin
        state <= next;
    end
    end

    // always block to update the next state and the output register(o_done)
    always@(*) begin
    o_done = 0;
    if (state == IDLE & i_run_not == 0) r_clk_cnt = 0;
    else r_clk_cnt = r_clk_cnt;
    case(state)
        IDLE : begin
            if(!i_run_not) next = RUN; 
            else next = IDLE;
        end
        RUN : begin
            if(w_is_done) next = DONE;
            else next = RUN;
        end
        DONE : begin
            o_done = 1;
            if(!r_sec) next = IDLE;
            else next = DONE;
        end
        default : next = IDLE;
    endcase
    end

    // continuous assignment statement to assign output and wire
    assign w_is_done = (state == RUN & r_sec == WISHSEC) ? 1 : 0;
    assign o_idle = state == IDLE ? 1 : 0;
    assign o_running = state == RUN ? 1 : 0;
    
endmodule
