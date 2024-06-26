`timescale 10ns/1ns
module cactusMove_tb;
logic [3:0] in;
logic enable;
logic [6:0] ssX;
localparam clk_prd = 8;
logic tb_clk, tb_nRst;

cactusMove moveCactus(.clk(tb_clk), .nRst(tb_nRst));

task reset ();

@(negedge tb_clk);
tb_nRst = 1;
#clk_prd;
tb_nRst = 0;
#clk_prd;
tb_nRst = 1;

endtask


initial begin
  $dumpfile("sim.vcd");
  $dumpvars(0, cactusMove_tb);
  reset; 
  #(clk_prd * 20000000);
end

endmodule
