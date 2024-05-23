module tx_baud_rate(
    clk, 
    reset, 
    baud_en, 
    en
);

    parameter N=12;
    input clk;
    input reset;
    input baud_en;
    output reg en;

    reg [N-1:0] count;

    always@(posedge clk or negedge reset) begin
        if(~reset) begin
            en <= 0;
            count <= 0;
        end
        else begin
            if(baud_en) begin
                count <= count + 1'b1;
                if(count == 12'd2604) begin
                    count <= 0;
                    en <= 1;
                end
                else begin
                    en <= 0;
                end
            end
            else begin
                en <= 0;
                count <= 0;
            end
        end
    end
endmodule
