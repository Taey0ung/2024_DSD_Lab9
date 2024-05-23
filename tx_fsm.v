module tx_fsm(clk, reset, z, d, en, baud_en, txd);
  input clk, reset, z, en;
  input [7:0] d;
  output reg baud_en;
  output reg txd;
  
  reg [3:0] state, next_state;
  
  parameter s0=4'b0000;
  parameter s1=4'b0001;
  parameter s2=4'b0010;
  parameter s3=4'b0011;
  parameter s4=4'b0100;
  parameter s5=4'b0101;
  parameter s6=4'b0110;
  parameter s7=4'b0111;
  parameter s8=4'b1000;
  parameter s9=4'b1001;
  parameter s10=4'b1010;
  
  // status register
  always@(posedge clk or negedge reset) begin
    if(~reset) state <= s0;
    else state <= next_state;
  end
  
  // next state logic
  always@(state or z or en) begin
    case(state)
      s0 : if(z == 0) next_state = s1;
           else next_state = s0;
      s1 : if(en == 1) next_state = s2;
           else next_state = s1;
      s2 : if(en == 1) next_state = s3;
           else next_state = s2;
      s3 : if(en == 1) next_state = s4;
           else next_state = s3;
      s4 : if(en == 1) next_state = s5;
           else next_state = s4;
      s5 : if(en == 1) next_state = s6;
           else next_state = s5;
      s6 : if(en == 1) next_state = s7;
           else next_state = s6;
      s7 : if(en == 1) next_state = s8;
           else next_state = s7;
      s8 : if(en == 1) next_state = s9;
           else next_state = s8;
      s9 : if(en == 1) next_state = s10;
           else next_state = s9;
      s10 : if(en == 1) next_state = s0;
            else next_state = s10;
      default : next_state = s0;
    endcase
  end
  
  // output logic
  always@(state) begin
    if(state==s0) begin
      txd=1;
      baud_en=0;
    end
    if(state==s1) begin
      txd=0;
      baud_en=1;
    end
    if(state==s2) begin
      txd=d[0];
      baud_en=1;
    end
    if(state==s3) begin
      txd=d[1];
      baud_en=1;
    end
    if(state==s4) begin
      txd=d[2];
      baud_en=1;
    end
    if(state==s5) begin
      txd=d[3];
      baud_en=1;
    end
    if(state==s6) begin
      txd=d[4];
      baud_en=1;
    end
    if(state==s7) begin
      txd=d[5];
      baud_en=1;
    end
    if(state==s8) begin
      txd=d[6];
      baud_en=1;
    end
    if(state==s9) begin
      txd=d[7];
      baud_en=1;
    end
    if(state==s10) begin
      txd=1;
      baud_en=1;
    end
  end
endmodule