module delay_load(
    clk, 
    reset, 
    load, 
    z
);

input clk, reset, load;
output reg z;

reg [30:0] count;

// 초기 블록: z 신호를 1로 초기화
initial begin
    z <= 1;
end

// 항상 블록: 클록 상승 엣지 또는 리셋 하강 엣지에서 동작
always @(posedge clk or negedge reset) begin
    if (~reset) begin
        // 리셋 시 count와 z 초기화
        count <= 0;
        z <= 1;
    end else begin
        if (load == 0 & z == 1) begin
            // load 신호가 0이고 z가 1인 경우 count 증가
            count <= count + 1;
            if (count == 2500000) begin
                // count가 2500000에 도달하면 z를 0으로 설정
                z <= 0;
            end 
        end else begin
            // 그 외의 경우 count와 z를 초기화
            z <= 1;
            count <= 0;
        end
    end
end

endmodule
