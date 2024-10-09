
# XM-Sim Command File
# TOOL:	xmsim	23.09-s001
#

set tcl_prompt1 {puts -nonewline "xcelium> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level never
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
set vcd_compact_mode 0
set vhdl_forgen_loopindex_enum_pos 0
alias . run
alias indago verisium
alias quit exit
database -open -vcd -into verilog.dump _verilog.dump1 -timescale fs
database -open -shm -into waves.shm waves -default
database -open -vcd -into cpu.VCD _cpu.VCD1 -timescale fs
probe -create -database waves testbench.top.check.lui_instr testbench.top.check.clk testbench.top.check.WB_imm testbench.top.check.is_lui_instr testbench.top.check.ID_imm testbench.top.check.imm_u testbench.top.check.WB_regwrite testbench.top.check.data_write_reg testbench.top.check.WB_data_write
probe -create -database waves testbench.top.control_hazard.IF_ID_flush1 testbench.top.control_hazard.IF_ID_flush2 testbench.top.control_hazard.hazard testbench.top.control_hazard.IF_ID_flush_o testbench.top.control_hazard.EX_flush_o
probe -create -database waves testbench.top.check.no_hazard
probe -create -database waves testbench.top.id_stage.decode.sel_to_reg_o testbench.top.id_stage.ID_sel_to_reg_o
probe -create -database waves testbench.top.id_stage.decode.opcode
probe -create -database waves testbench.top.if_stage.IF_instr_i testbench.top.if_stage.IMEM_data_i
probe -create -database waves testbench.top.if_stage.IF_instr_o
probe -create -database waves testbench.top.if_stage.pc_next
probe -create -database waves testbench.top.id_stage.decode.branch_o testbench.top.id_stage.decode.jump_o
probe -create -database waves testbench.top.check.xor_instr testbench.top.check.sltu_instr testbench.top.check.slt_instr testbench.top.check.sll_instr testbench.top.check.sub_instr testbench.top.check.add_instr testbench.top.check.check_add_instr testbench.top.check.check_sub_instr testbench.top.check.check_sll_instr testbench.top.check.check_slt_instr
probe -create -database waves testbench.top.wb_stage.WB_pc_i testbench.top.wb_stage.DMEM_data_i testbench.top.wb_stage.WB_alu_result testbench.top.wb_stage.WB_alu_result_i testbench.top.wb_stage.WB_data_write_reg_o testbench.top.wb_stage.WB_imm testbench.top.wb_stage.WB_imm_i testbench.top.wb_stage.WB_rd_add_i testbench.top.wb_stage.WB_rd_add_o testbench.top.wb_stage.WB_regwrite_i testbench.top.wb_stage.WB_regwrite_o testbench.top.wb_stage.WB_rf_wdata_sel_i testbench.top.wb_stage.WB_rf_wdata_sel_o testbench.top.wb_stage.WB_sel_to_reg testbench.top.wb_stage.WB_sel_to_reg_i testbench.top.wb_stage.clk testbench.top.wb_stage.pc testbench.top.wb_stage.rst_n
probe -create -database waves testbench.top.mem_stage.MEM_pc_o testbench.top.mem_stage.DMEM_add_o testbench.top.mem_stage.DMEM_byte_mark_o testbench.top.mem_stage.DMEM_data_i testbench.top.mem_stage.DMEM_data_write_o testbench.top.mem_stage.DMEM_rst_o testbench.top.mem_stage.MEM_RD_mem_i testbench.top.mem_stage.MEM_RD_mem_o testbench.top.mem_stage.MEM_WR_mem_i testbench.top.mem_stage.MEM_WR_mem_o testbench.top.mem_stage.MEM_alu_result_i testbench.top.mem_stage.MEM_alu_result_o testbench.top.mem_stage.MEM_data_o testbench.top.mem_stage.MEM_imm_i testbench.top.mem_stage.MEM_imm_o testbench.top.mem_stage.MEM_mem_op_i testbench.top.mem_stage.MEM_pc_i testbench.top.mem_stage.MEM_rd_add_i testbench.top.mem_stage.MEM_rd_add_o testbench.top.mem_stage.MEM_regwrite_i testbench.top.mem_stage.MEM_regwrite_o testbench.top.mem_stage.MEM_rf_wdata_sel_i testbench.top.mem_stage.MEM_rf_wdata_sel_o testbench.top.mem_stage.MEM_rs2_data_i testbench.top.mem_stage.MEM_sel_to_reg_i testbench.top.mem_stage.MEM_sel_to_reg_o testbench.top.mem_stage.WB_data_i testbench.top.mem_stage.byte_addr testbench.top.mem_stage.byte_mark testbench.top.mem_stage.clk testbench.top.mem_stage.data_write testbench.top.mem_stage.forward testbench.top.mem_stage.last_add_o testbench.top.mem_stage.load_err_o testbench.top.mem_stage.mem_op testbench.top.mem_stage.rst_n testbench.top.mem_stage.store_err_o
probe -create -database waves testbench.top.ex_stage.alu_result
probe -create -database waves testbench.top.id_stage.imm testbench.top.id_stage.imm_b_type testbench.top.id_stage.imm_i_type testbench.top.id_stage.imm_j_type testbench.top.id_stage.imm_s_type testbench.top.id_stage.imm_u_type
probe -create -database waves testbench.top.id_stage.ID_rs1_data_o testbench.top.id_stage.ID_rs2_data_o
probe -create -database waves testbench.top.ex_stage.op_a_alu testbench.top.ex_stage.op_b_alu
probe -create -database waves testbench.top.control_hazard.forward_dmem

simvision -input /home/usr3/project/CPU_5stage_pipeline/run/.simvision/20888_usr3__autosave.tcl.svcf
