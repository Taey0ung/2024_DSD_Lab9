module uart_rx(
    input wire clk,
    input wire reset,
    input wire rxd,
    output reg [7:0] rx_data,
    output wire rx_complete,
    output wire rx_error,
    output reg [15:0] led
);

parameter sys_freq = 50000000; // 시스템 주파수, 50MHz 
parameter bps = 19200; // 보드레이트, 19200bps 
parameter division = 16; // 분주비, 16배

// State definition
parameter idle            = 4'd0;
parameter start_check     = 4'd1;
parameter cnt_2_rst       = 4'd2;
parameter first_wait      = 4'd3;
parameter first_sample    = 4'd4;
parameter second_wait     = 4'd5;
parameter second_sample   = 4'd6;
parameter third_wait      = 4'd7;
parameter third_sample    = 4'd8;
parameter data_decision   = 4'd9;
parameter stop_decision   = 4'd10;
parameter receive_complete = 4'd11;
parameter receive_error   = 4'd12;

reg [3:0] state, next_state;
reg [12:0] cnt_1;
reg [4:0] cnt_2;
reg [3:0] cnt_3;
reg b1, b2, b3;

// State register
always @(posedge clk or negedge reset) begin
    if (~reset)
        state <= idle;
    else
        state <= next_state;
end

// State transition logic
always @(state or cnt_1 or rxd or cnt_2 or cnt_3) begin
    case(state)
        idle : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1) && (rxd == 1'b0))
                next_state = start_check;
            else
                next_state = idle;
        start_check : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1) && (rxd == 1'b1))
                next_state = idle;
            else if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1) && (rxd == 1'b0))
                next_state = state;
            else if (cnt_2 == 5'd8)
                next_state = cnt_2_rst;
            else
                next_state = start_check;
        cnt_2_rst : 
            next_state = first_wait;
        first_wait : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1))
                next_state = state;
            else if (cnt_2 == 5'd14)
                next_state = first_sample;
            else
                next_state = first_wait;
        first_sample : 
            next_state = second_wait;
        second_wait : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1))
                next_state = state;
            else if (cnt_2 == 5'd16)
                next_state = second_sample;
            else
                next_state = second_wait;
        second_sample : 
            next_state = third_wait;
        third_wait : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1))
                next_state = state;
            else if (cnt_2 == 5'd16)
                next_state = third_sample;
            else
                next_state = third_wait;
        third_sample : 
            if (cnt_3 == 4'd8) // Include 8 data and 0 parity
                next_state = stop_decision;
            else
                next_state = data_decision;
        data_decision : 
            next_state = cnt_2_rst;
        stop_decision : 
            if (catch_bit == 1'b1)
                next_state = receive_complete;
            else
                next_state = receive_error;
        receive_complete : 
            next_state = idle;
        receive_error : 
            next_state = idle;
        default : next_state = state;
    endcase
end

//counter 1 Baudrate 보다 16배 빠른 속도로 데이터를 샘플링하기 위한 카운터
always @ (posedge clk or negedge reset) begin
    if (~reset)
        cnt_1 <= 0;
    else if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1))
        cnt_1 <= 0;
    else
        cnt_1 <= cnt_1 + 1'b1;
end

//counter 2 데이터를 몇 개나 샘플링하였는지 확인하기 위한 용도
always @ (posedge clk or negedge reset) begin
    if (~reset)
        cnt_2 <= 0;
    else begin
    case(state)
        idle : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1) && (rxd == 1'b0))
                cnt_2 <= cnt_2 + 1'b1;
            else
                cnt_2 <= cnt_2;
        start_check : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1) && (rxd == 1'b0))
                cnt_2 <= cnt_2 + 1'b1;
            else
                cnt_2 <= cnt_2;
        first_wait : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1))
                cnt_2 <= cnt_2 + 1'b1;
            else
                cnt_2 <= cnt_2;
        second_wait : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1))
                cnt_2 <= cnt_2 + 1'b1;
            else
                cnt_2 <= cnt_2;
        third_wait : 
            if ((cnt_1 == (sys_freq/(bps*division)) - 1'b1))
                cnt_2 <= cnt_2 + 1'b1;
            else
                cnt_2 <= cnt_2;
        cnt_2_rst : 
            cnt_2 <= 0;
        stop_decision : 
            cnt_2 <= 0;
        default : cnt_2 <= cnt_2;
    endcase
    end
end

// Counter 3
always @ (posedge clk or negedge reset) begin
    if (~reset)
        cnt_3 <= 0;
    else if (state == data_decision)
        cnt_3 <= (cnt_3 + 1'b1);
    else if (state == stop_decision)
        cnt_3 <= 0;
    else
        cnt_3 <= cnt_3;
end

// Sampling bits
always @ (posedge clk) begin

    if (state == cnt_2_rst)
        b1 <= 1'b0;
    else if (state == idle)
        b1 <= 1'b0;
    else if (state == first_sample)
        b1 <= rxd;
    else
        b1 <= b1;
end

always @ (posedge clk) begin
    if (state == cnt_2_rst)
        b2 <= 1'b0;
    else if (state == idle)
        b2 <= 1'b0;
    else if (state == second_sample)
        b2 <= rxd;
    else
        b2 <= b2;
end

always @ (posedge clk) begin
    if (state == cnt_2_rst)
        b3 <= 1'b0;
    else if (state == idle)
        b3 <= 1'b0;
    else if (state == third_sample)
        b3 <= rxd;
    else
        b3 <= b3;
end

assign catch_bit = b1 & b2 | b1 & b3 | b2 & b3;

// Data registers
always @ (posedge clk or negedge reset) begin
    if (~reset)
        rx_data <= 8'b0000_0000;
    else begin
        if(state == idle)
            rx_data <= 8'd0;
        else if(state == data_decision)
            rx_data[cnt_3] <= catch_bit;
        else;
    end
end

// Complete bits
assign rx_complete = (state == receive_complete) ? 1'b1 : 1'b0;
assign rx_error = (state == receive_error) ? 1'b1 : 1'b0;

// LED 출력 제어
always @(posedge clk or negedge reset) begin
    if (~reset) begin
        led <= 16'b0000_0000_0000_0000;
    end else if (rx_complete) begin
        led <= rx_data;
    end
end

endmodule
