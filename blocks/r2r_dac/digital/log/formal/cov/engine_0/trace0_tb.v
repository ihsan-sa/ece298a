`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [0:0] PI_ena;
  reg [0:0] PI_rst_n;
  reg [0:0] PI_slow;
  reg [7:0] PI_ui_in;
  wire [0:0] PI_clk = clock;
  reg [1:0] PI_mode;
  r2r_dac_digital_formal UUT (
    .ena(PI_ena),
    .rst_n(PI_rst_n),
    .slow(PI_slow),
    .ui_in(PI_ui_in),
    .clk(PI_clk),
    .mode(PI_mode)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$async2sync.\cc:107:execute$127  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$133  = 1'b0;
    // UUT.$auto$async2sync.\cc:116:execute$119  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$125  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$131  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$137  = 1'b1;
    UUT._witness_.anyinit_procdff_101 = 2'b00;
    UUT._witness_.anyinit_procdff_102 = 2'b00;
    UUT._witness_.anyinit_procdff_103 = 2'b00;
    UUT._witness_.anyinit_procdff_104 = 1'b0;
    UUT._witness_.anyinit_procdff_105 = 1'b0;
    UUT._witness_.anyinit_procdff_106 = 1'b0;
    UUT._witness_.anyinit_procdff_107 = 1'b0;
    UUT._witness_.anyinit_procdff_108 = 2'b00;
    UUT._witness_.anyinit_procdff_109 = 2'b00;
    UUT._witness_.anyinit_procdff_110 = 2'b00;
    UUT._witness_.anyinit_procdff_111 = 8'b00000000;
    UUT._witness_.anyinit_procdff_112 = 1'b0;
    UUT.dut.cnt = 8'b00000000;
    UUT.dut.cnt_p1 = 8'b00000000;
    UUT.dut.code_reg = 8'b00000000;
    UUT.dut.dac_code = 8'b00000000;
    UUT.dut.presc = 8'b00000000;
    UUT.dut.presc_tc = 1'b0;
    UUT.past_valid = 1'b0;
    UUT.past_valid2 = 1'b0;
    UUT.dut.$auto$proc_rom.\cc:155:do_switch$58 [8'b00000000] = 8'b10000000;

    // state 0
    PI_ena = 1'b0;
    PI_rst_n = 1'b0;
    PI_slow = 1'b0;
    PI_ui_in = 8'b00000000;
    PI_mode = 2'b00;
  end
  always @(posedge clock) begin
    genclock <= cycle < 0;
    cycle <= cycle + 1;
  end
endmodule
