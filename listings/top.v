// 通用接口示例，不对应具体实验工程。
module top (
  input  wire clk,
  input  wire rst_n,
  input  wire din,
  output wire dout
);
  assign dout = rst_n & din;
endmodule
