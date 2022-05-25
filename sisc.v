// ECE:3350 SISC processor project
// main SISC module, part 1

`timescale 1ns/100ps  

module sisc (clk, rst_f);

  input clk, rst_f;

  wire rb_sel, rf_we, wb_sel, stat_en;
  wire [1:0] alu_op;
  wire [3:0] rd_regb, alu_sts, stat;
  wire [31:0] rega, regb, wr_dat, alu_out;
  
  wire pc_sel, pc_write, pc_rst, br_sel, ir_load;
  wire [15:0] br_addr, pc_out;
  wire [31:0] read_data, instr;
  
// component instantiation

  ctrl u1 (clk, rst_f, instr[31:28], instr[27:24], stat, rf_we, alu_op, wb_sel, br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load);

  rf u2 (clk, instr[19:16], rd_regb, instr[23:20], wr_dat, rf_we, rega, regb);

  alu u3 (clk, rega, regb, instr[15:0], alu_op, alu_out, alu_sts, stat_en);

  mux4 u4 (instr[15:12], instr[23:20], rb_sel, rd_regb);

  mux32 u5 (alu_out, 32'h00000000, wb_sel, wr_dat);

  statreg u6(clk, alu_sts, stat_en, stat);

  pc u7(clk, br_addr, pc_sel, pc_write, pc_rst, pc_out);

  br u8(pc_out, instr[15:0], br_sel, br_addr);

  ir u9(clk, ir_load, read_data, instr);

  im u10(pc_out, read_data);

  initial
  $monitor($time,,"IR: %h PC_OUT: %b R1: %h R2: %h R3: %h R4: %h R5: %h ALU_OP: %b BR_SEL: %b PC_WRITE: %b PC_SEL: %b",instr,pc_out,u2.ram_array[1],u2.ram_array[2],u2.ram_array[3],u2.ram_array[4],u2.ram_array[5],alu_op,br_sel,pc_write,pc_sel);

endmodule


