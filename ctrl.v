// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel, br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load);

  /* TODO: Declare the ports listed above as inputs or outputs */
  
  input clk, rst_f;
  input [3:0] opcode, mm, stat;
  output reg rf_we, wb_sel, br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load;
  output reg [1:0] alu_op;
  
  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcodes
  parameter NOOP = 0, LOD = 1, STR = 2, SWP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7, ALU_OP = 8, HLT=15;

  // addressing modes
  parameter AM_IMM = 8;

  // state registers
  reg [2:0]  present_state, next_state;

  /* TODO: Write a clock process that progresses the fsm to the next state on the
       positive edge of the clock, OR resets the state to 'start0' on the negative edge
       of rst_f. Notice that the computer is reset when rst_f is low, not high. */

  initial
    present_state = start0;

  always @(posedge clk, negedge rst_f)
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end

  
  /* TODO: Write a process that determines the next state of the fsm. */

  always @(present_state, rst_f)
  begin
    case(present_state)
      start0:
        next_state = start1;
      start1:
      begin
	if (rst_f == 1'b0)
        begin
	  pc_rst = 1'b1;
          next_state = start1;
	end
	else
        begin
          pc_rst = 1'b0;
          next_state = fetch;
        end
      end
      fetch:
        next_state = decode;
      decode:
        next_state = execute;
      execute:
        next_state = mem;
      mem:
        next_state = writeback;
      writeback:
        next_state = fetch;
      default:
        next_state = start1;
    endcase
  end

  /* TODO: Generate outputs based on the FSM states and inputs. For Parts 2 and 3, you will
       add the new control signals here. */

  always @(present_state, opcode, mm)
  begin

    rf_we <= 0;
    wb_sel <= 1;
    alu_op <= 0;

    case(present_state)

      fetch:
      begin
        ir_load = 1'b1;
        pc_sel = 1'b0;
        br_sel = 1'b0;
        pc_write = 1'b1;
      end

      decode:
      begin
        ir_load <= 0;
        case(opcode)
          ALU_OP:
          begin		
            wb_sel <= 0;
            pc_write <= 0;
            if (mm == 0)
              rb_sel <= 0;
          end

          BRA:
          begin
            if ((mm & stat) != 0)
            begin
              br_sel <= 1;
              pc_sel <= 1;
            end
            else
              pc_write <= 0;
          end

          BNE:
          begin
            if ((mm & stat) == 0)
            begin
              br_sel <= 1;
              pc_sel <= 1;
            end
            else
              pc_write <= 0;
          end

          BRR:
          begin
            if ((mm & stat) != 0)
            begin
              br_sel <= 0;
              pc_sel <= 1;
            end
            else
              pc_write <= 0;
          end	

          BNR:
          begin
            if ((mm & stat) == 0)
            begin
              br_sel <= 0;
              pc_sel <= 1;
            end
            else
              pc_write <= 0;
          end

          default:
          begin
            pc_write <= 0;	
          end
        endcase
      end

      execute:
      begin
        pc_write <= 0;
        if (opcode == ALU_OP)
          if (mm == 8)
            alu_op = 2'b01;
          else
            alu_op = 2'b00;
      end

      mem:
      begin
        if ((opcode == ALU_OP) && (mm == AM_IMM))
          alu_op = 2'b11;
        else
          alu_op = 2'b10;
      end

      writeback:
        if (opcode == ALU_OP)
          rf_we <= 1;

      default:
      begin
        rf_we = 1'b0;
        wb_sel = 1'b0;
        alu_op = 2'b10;
        rb_sel = 1'b0;
        ir_load = 1'b0;
        pc_sel = 1'b0;
        pc_write = 1'b0;
        pc_rst = 1'b0;
        br_sel = 1'b0;
      end
    endcase
  end

  // Halt on HLT instruction
  always @(opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt."); //Delay 1 ns so $monitor will print the halt instruction
      $stop;
    end
  end
    
endmodule
