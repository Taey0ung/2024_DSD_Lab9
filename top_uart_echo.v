module top_uart_echo(
    input wire clk,
    input wire reset,
    input wire rxd,
    output wire txd,
    output wire [15:0] led
);
    wire [7:0] rx_data;
    wire rx_complete;
    wire rx_error;
    wire load;
    reg [7:0] tx_data;
    
    // UART Receiver instance
    uart_rx U0 (
        .clk(clk),
        .reset(reset),
        .rxd(rxd),
        .rx_data(rx_data),
        .rx_complete(rx_complete),
        .rx_error(rx_error),
        .led(led)
    );
    
    // Load signal generation: It is generated when rx_complete is high
    assign load = rx_complete;

    // UART Transmitter instance
    uart_tx U1 (
        .clk(clk),
        .reset(reset),
        .load(load),
        .d(tx_data),
        .txd(txd)
    );
    
    // Transmit data register: It is updated when rx_complete is high
    always @(posedge clk or negedge reset) begin
        if (~reset)
            tx_data <= 8'b0;
        else if (rx_complete)
            tx_data <= rx_data;
    end

endmodule
