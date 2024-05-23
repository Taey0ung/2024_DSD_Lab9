module uart_tx(
    clk, 
    reset, 
    load, 
    d, 
    txd
);
    input clk, reset, load;
    input [7:0] d;
    output txd;

    wire z;
    wire en;
    wire baud_en;

    delay_load U0(
        .clk(clk), 
        .reset(reset), 
        .load(load), 
        .z(z)
    );
    
    tx_fsm U1(
        .clk(clk), 
        .reset(reset), 
        .z(z), 
        .d(d), 
        .en(en), 
        .baud_en(baud_en), 
        .txd(txd)
    );
    
    tx_baud_rate U2(
        .clk(clk), 
        .reset(reset), 
        .baud_en(baud_en), 
        .en(en)
    );

endmodule
