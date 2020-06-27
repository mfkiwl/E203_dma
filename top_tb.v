`include "e203_defines.v"

module dma_tb();

  reg clk;
  reg lfextclk;
  reg rst_n;

  wire hfclk = clk;

  `define CPU_TOP     u_e203_soc_top.u_e203_subsys_top.u_e203_cpu_top
  `define ITCM        `CPU_TOP.u_e200_srams.u_e200_itcm_ram.u_e200_itcm_gnrl_ram.u_sirv_sim_ram
  `define EXU         `CPU_TOP.u_e200_cpu.u_e200_core.u_e200_exu

  reg [8*300:1] testcase;
  reg [7:0]     itcm_mem [0 : (`E203_ITCM_RAM_DP * 8) - 1];

  integer dumpwave;
  integer i;

initial begin
  $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");  
  if ($value$plusargs("TESTCASE=%s",testcase))
    $display("TESTCASE=%s",testcase);

  clk         <= 0;
  lfextclk    <= 0;
  rst_n       <= 0;
  #120 rst_n  <= 1;
end
  
initial begin
  #40000000 $display("Time Out !!!");
  $finish;
end

initial begin
  $value$plusargs("DUMPWAVE=%d",dumpwave);
  if (dumpwave != 0) begin
    $fsdbDumpfile("tb_top.fsdb");
    $fsdbDumpvars(0, tb_top, "+all");  
  end
end

always
  #2 clk <= ~clk;

always 
  #33 lfextclk <= ~lfextclk;

  initial begin
    $readmemh({testcase, ".verilog"}, itcm_mem);
    for (i=0;i<(`E203_ITCM_RAM_DP);i=i+1) begin
      `ITCM.mem_r[i][00+7:00] = itcm_mem[i*8+0];
      `ITCM.mem_r[i][08+7:08] = itcm_mem[i*8+1];
      `ITCM.mem_r[i][16+7:16] = itcm_mem[i*8+2];
      `ITCM.mem_r[i][24+7:24] = itcm_mem[i*8+3];
      `ITCM.mem_r[i][32+7:32] = itcm_mem[i*8+4];
      `ITCM.mem_r[i][40+7:40] = itcm_mem[i*8+5];
      `ITCM.mem_r[i][48+7:48] = itcm_mem[i*8+6];
      `ITCM.mem_r[i][56+7:56] = itcm_mem[i*8+7];
    end

    $display("ITCM 0x00: %h", `ITCM.mem_r[8'h00]);
    $display("ITCM 0x01: %h", `ITCM.mem_r[8'h01]);
    $display("ITCM 0x02: %h", `ITCM.mem_r[8'h02]);
    $display("ITCM 0x03: %h", `ITCM.mem_r[8'h03]);
    $display("ITCM 0x04: %h", `ITCM.mem_r[8'h04]);
    $display("ITCM 0x05: %h", `ITCM.mem_r[8'h05]);
    $display("ITCM 0x06: %h", `ITCM.mem_r[8'h06]);
    $display("ITCM 0x07: %h", `ITCM.mem_r[8'h07]);
    $display("ITCM 0x16: %h", `ITCM.mem_r[8'h16]);
    $display("ITCM 0x20: %h", `ITCM.mem_r[8'h20]);
  end

  wire jtag_TDI = 1'b0;
  wire jtag_TDO;
  wire jtag_TCK = 1'b0;
  wire jtag_TMS = 1'b0;
  wire jtag_TRST = 1'b0;

  wire jtag_DRV_TDO = 1'b0;


e203_soc_top u_e203_soc_top( 
  .hfextclk(hfclk),
  .hfxoscen(),

  .lfextclk(lfextclk),
  .lfxoscen(),

  .io_pads_jtag_TCK_i_ival (jtag_TCK),
  .io_pads_jtag_TMS_i_ival (jtag_TMS),
  .io_pads_jtag_TDI_i_ival (jtag_TDI),
  .io_pads_jtag_TDO_o_oval (jtag_TDO),
  .io_pads_jtag_TDO_o_oe (),
  .io_pads_gpio_0_i_ival (1'b1),
  .io_pads_gpio_0_o_oval (),
  .io_pads_gpio_0_o_oe (),
  .io_pads_gpio_0_o_ie (),
  .io_pads_gpio_0_o_pue (),
  .io_pads_gpio_0_o_ds (),
  .io_pads_gpio_1_i_ival (1'b1),
  .io_pads_gpio_1_o_oval (),
  .io_pads_gpio_1_o_oe (),
  .io_pads_gpio_1_o_ie (),
  .io_pads_gpio_1_o_pue (),
  .io_pads_gpio_1_o_ds (),
  .io_pads_gpio_2_i_ival (1'b1),
  .io_pads_gpio_2_o_oval (),
  .io_pads_gpio_2_o_oe (),
  .io_pads_gpio_2_o_ie (),
  .io_pads_gpio_2_o_pue (),
  .io_pads_gpio_2_o_ds (),
  .io_pads_gpio_3_i_ival (1'b1),
  .io_pads_gpio_3_o_oval (),
  .io_pads_gpio_3_o_oe (),
  .io_pads_gpio_3_o_ie (),
  .io_pads_gpio_3_o_pue (),
  .io_pads_gpio_3_o_ds (),
  .io_pads_gpio_4_i_ival (1'b1),
  .io_pads_gpio_4_o_oval (),
  .io_pads_gpio_4_o_oe (),
  .io_pads_gpio_4_o_ie (),
  .io_pads_gpio_4_o_pue (),
  .io_pads_gpio_4_o_ds (),
  .io_pads_gpio_5_i_ival (1'b1),
  .io_pads_gpio_5_o_oval (),
  .io_pads_gpio_5_o_oe (),
  .io_pads_gpio_5_o_ie (),
  .io_pads_gpio_5_o_pue (),
  .io_pads_gpio_5_o_ds (),
  .io_pads_gpio_6_i_ival (1'b1),
  .io_pads_gpio_6_o_oval (),
  .io_pads_gpio_6_o_oe (),
  .io_pads_gpio_6_o_ie (),
  .io_pads_gpio_6_o_pue (),
  .io_pads_gpio_6_o_ds (),
  .io_pads_gpio_7_i_ival (1'b1),
  .io_pads_gpio_7_o_oval (),
  .io_pads_gpio_7_o_oe (),
  .io_pads_gpio_7_o_ie (),
  .io_pads_gpio_7_o_pue (),
  .io_pads_gpio_7_o_ds (),
  .io_pads_gpio_8_i_ival (1'b1),
  .io_pads_gpio_8_o_oval (),
  .io_pads_gpio_8_o_oe (),
  .io_pads_gpio_8_o_ie (),
  .io_pads_gpio_8_o_pue (),
  .io_pads_gpio_8_o_ds (),
  .io_pads_gpio_9_i_ival (1'b1),
  .io_pads_gpio_9_o_oval (),
  .io_pads_gpio_9_o_oe (),
  .io_pads_gpio_9_o_ie (),
  .io_pads_gpio_9_o_pue (),
  .io_pads_gpio_9_o_ds (),
  .io_pads_gpio_10_i_ival (1'b1),
  .io_pads_gpio_10_o_oval (),
  .io_pads_gpio_10_o_oe (),
  .io_pads_gpio_10_o_ie (),
  .io_pads_gpio_10_o_pue (),
  .io_pads_gpio_10_o_ds (),
  .io_pads_gpio_11_i_ival (1'b1),
  .io_pads_gpio_11_o_oval (),
  .io_pads_gpio_11_o_oe (),
  .io_pads_gpio_11_o_ie (),
  .io_pads_gpio_11_o_pue (),
  .io_pads_gpio_11_o_ds (),
  .io_pads_gpio_12_i_ival (1'b1),
  .io_pads_gpio_12_o_oval (),
  .io_pads_gpio_12_o_oe (),
  .io_pads_gpio_12_o_ie (),
  .io_pads_gpio_12_o_pue (),
  .io_pads_gpio_12_o_ds (),
  .io_pads_gpio_13_i_ival (1'b1),
  .io_pads_gpio_13_o_oval (),
  .io_pads_gpio_13_o_oe (),
  .io_pads_gpio_13_o_ie (),
  .io_pads_gpio_13_o_pue (),
  .io_pads_gpio_13_o_ds (),
  .io_pads_gpio_14_i_ival (1'b1),
  .io_pads_gpio_14_o_oval (),
  .io_pads_gpio_14_o_oe (),
  .io_pads_gpio_14_o_ie (),
  .io_pads_gpio_14_o_pue (),
  .io_pads_gpio_14_o_ds (),
  .io_pads_gpio_15_i_ival (1'b1),
  .io_pads_gpio_15_o_oval (),
  .io_pads_gpio_15_o_oe (),
  .io_pads_gpio_15_o_ie (),
  .io_pads_gpio_15_o_pue (),
  .io_pads_gpio_15_o_ds (),
  .io_pads_gpio_16_i_ival (1'b1),
  .io_pads_gpio_16_o_oval (),
  .io_pads_gpio_16_o_oe (),
  .io_pads_gpio_16_o_ie (),
  .io_pads_gpio_16_o_pue (),
  .io_pads_gpio_16_o_ds (),
  .io_pads_gpio_17_i_ival (1'b1),
  .io_pads_gpio_17_o_oval (),
  .io_pads_gpio_17_o_oe (),
  .io_pads_gpio_17_o_ie (),
  .io_pads_gpio_17_o_pue (),
  .io_pads_gpio_17_o_ds (),
  .io_pads_gpio_18_i_ival (1'b1),
  .io_pads_gpio_18_o_oval (),
  .io_pads_gpio_18_o_oe (),
  .io_pads_gpio_18_o_ie (),
  .io_pads_gpio_18_o_pue (),
  .io_pads_gpio_18_o_ds (),
  .io_pads_gpio_19_i_ival (1'b1),
  .io_pads_gpio_19_o_oval (),
  .io_pads_gpio_19_o_oe (),
  .io_pads_gpio_19_o_ie (),
  .io_pads_gpio_19_o_pue (),
  .io_pads_gpio_19_o_ds (),
  .io_pads_gpio_20_i_ival (1'b1),
  .io_pads_gpio_20_o_oval (),
  .io_pads_gpio_20_o_oe (),
  .io_pads_gpio_20_o_ie (),
  .io_pads_gpio_20_o_pue (),
  .io_pads_gpio_20_o_ds (),
  .io_pads_gpio_21_i_ival (1'b1),
  .io_pads_gpio_21_o_oval (),
  .io_pads_gpio_21_o_oe (),
  .io_pads_gpio_21_o_ie (),
  .io_pads_gpio_21_o_pue (),
  .io_pads_gpio_21_o_ds (),
  .io_pads_gpio_22_i_ival (1'b1),
  .io_pads_gpio_22_o_oval (),
  .io_pads_gpio_22_o_oe (),
  .io_pads_gpio_22_o_ie (),
  .io_pads_gpio_22_o_pue (),
  .io_pads_gpio_22_o_ds (),
  .io_pads_gpio_23_i_ival (1'b1),
  .io_pads_gpio_23_o_oval (),
  .io_pads_gpio_23_o_oe (),
  .io_pads_gpio_23_o_ie (),
  .io_pads_gpio_23_o_pue (),
  .io_pads_gpio_23_o_ds (),
  .io_pads_gpio_24_i_ival (1'b1),
  .io_pads_gpio_24_o_oval (),
  .io_pads_gpio_24_o_oe (),
  .io_pads_gpio_24_o_ie (),
  .io_pads_gpio_24_o_pue (),
  .io_pads_gpio_24_o_ds (),
  .io_pads_gpio_25_i_ival (1'b1),
  .io_pads_gpio_25_o_oval (),
  .io_pads_gpio_25_o_oe (),
  .io_pads_gpio_25_o_ie (),
  .io_pads_gpio_25_o_pue (),
  .io_pads_gpio_25_o_ds (),
  .io_pads_gpio_26_i_ival (1'b1),
  .io_pads_gpio_26_o_oval (),
  .io_pads_gpio_26_o_oe (),
  .io_pads_gpio_26_o_ie (),
  .io_pads_gpio_26_o_pue (),
  .io_pads_gpio_26_o_ds (),
  .io_pads_gpio_27_i_ival (1'b1),
  .io_pads_gpio_27_o_oval (),
  .io_pads_gpio_27_o_oe (),
  .io_pads_gpio_27_o_ie (),
  .io_pads_gpio_27_o_pue (),
  .io_pads_gpio_27_o_ds (),
  .io_pads_gpio_28_i_ival (1'b1),
  .io_pads_gpio_28_o_oval (),
  .io_pads_gpio_28_o_oe (),
  .io_pads_gpio_28_o_ie (),
  .io_pads_gpio_28_o_pue (),
  .io_pads_gpio_28_o_ds (),
  .io_pads_gpio_29_i_ival (1'b1),
  .io_pads_gpio_29_o_oval (),
  .io_pads_gpio_29_o_oe (),
  .io_pads_gpio_29_o_ie (),
  .io_pads_gpio_29_o_pue (),
  .io_pads_gpio_29_o_ds (),
  .io_pads_gpio_30_i_ival (1'b1),
  .io_pads_gpio_30_o_oval (),
  .io_pads_gpio_30_o_oe (),
  .io_pads_gpio_30_o_ie (),
  .io_pads_gpio_30_o_pue (),
  .io_pads_gpio_30_o_ds (),
  .io_pads_gpio_31_i_ival (1'b1),
  .io_pads_gpio_31_o_oval (),
  .io_pads_gpio_31_o_oe (),
  .io_pads_gpio_31_o_ie (),
  .io_pads_gpio_31_o_pue (),
  .io_pads_gpio_31_o_ds (),

  .io_pads_qspi_sck_o_oval (),
  .io_pads_qspi_dq_0_i_ival (1'b1),
  .io_pads_qspi_dq_0_o_oval (),
  .io_pads_qspi_dq_0_o_oe (),
  .io_pads_qspi_dq_0_o_ie (),
  .io_pads_qspi_dq_0_o_pue (),
  .io_pads_qspi_dq_0_o_ds (),
  .io_pads_qspi_dq_1_i_ival (1'b1),
  .io_pads_qspi_dq_1_o_oval (),
  .io_pads_qspi_dq_1_o_oe (),
  .io_pads_qspi_dq_1_o_ie (),
  .io_pads_qspi_dq_1_o_pue (),
  .io_pads_qspi_dq_1_o_ds (),
  .io_pads_qspi_dq_2_i_ival (1'b1),
  .io_pads_qspi_dq_2_o_oval (),
  .io_pads_qspi_dq_2_o_oe (),
  .io_pads_qspi_dq_2_o_ie (),
  .io_pads_qspi_dq_2_o_pue (),
  .io_pads_qspi_dq_2_o_ds (),
  .io_pads_qspi_dq_3_i_ival (1'b1),
  .io_pads_qspi_dq_3_o_oval (),
  .io_pads_qspi_dq_3_o_oe (),
  .io_pads_qspi_dq_3_o_ie (),
  .io_pads_qspi_dq_3_o_pue (),
  .io_pads_qspi_dq_3_o_ds (),
  .io_pads_qspi_cs_0_o_oval (),
  .io_pads_aon_erst_n_i_ival (rst_n),//This is the real reset, active low
  .io_pads_aon_pmu_dwakeup_n_i_ival (1'b1),

  .io_pads_aon_pmu_vddpaden_o_oval (),
  .io_pads_aon_pmu_padrst_o_oval    (),

  .io_pads_bootrom_n_i_ival       (1'b0),// In Simulation we boot from ROM
  .io_pads_dbgmode0_n_i_ival       (1'b1),
  .io_pads_dbgmode1_n_i_ival       (1'b1),
  .io_pads_dbgmode2_n_i_ival       (1'b1) 
);

endmodule

