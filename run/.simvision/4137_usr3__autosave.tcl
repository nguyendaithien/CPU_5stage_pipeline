
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
database -open -vcd -into cpu.VCD _cpu.VCD1 -timescale fs
database -open -shm -into waves.shm waves -default
database -open -vcd -into verilog.dump _verilog.dump1 -timescale fs
probe -create -database waves testbench.top.if_stage.clk testbench.top.if_stage.IF_exc_sel_i testbench.top.if_stage.IF_instr_compressed_o testbench.top.if_stage.IF_instr_fetch_err_o testbench.top.if_stage.IF_instr_i testbench.top.if_stage.IF_instr_o testbench.top.if_stage.IF_pc_o testbench.top.if_stage.IF_pc_sel_mux_i testbench.top.if_stage.IMEM_add_o testbench.top.if_stage.IMEM_data_i testbench.top.if_stage.Instr testbench.top.if_stage.boot_addr_i testbench.top.if_stage.csr_depc_i testbench.top.if_stage.csr_mepc_i testbench.top.if_stage.csr_mtvec_i testbench.top.if_stage.exc_add testbench.top.if_stage.flush testbench.top.if_stage.illegal_instr testbench.top.if_stage.illegal_instr_o testbench.top.if_stage.is_compressed testbench.top.if_stage.is_compressed_o testbench.top.if_stage.pc_dest testbench.top.if_stage.pc_next testbench.top.if_stage.pc_sel testbench.top.if_stage.pc_set_i testbench.top.if_stage.rst_n testbench.top.if_stage.stall testbench.top.control_hazard.hazard testbench.top.control_hazard.EX_flush_o testbench.top.control_hazard.IF_ID_flush_o testbench.top.control_hazard.stall_o
probe -create -database waves testbench.top.check.add_instr testbench.top.check.clk testbench.top.check.alu_result testbench.top.check.is_add_instr testbench.top.check.no_hazard testbench.top.check.data_write_reg testbench.top.check.op_a_alu testbench.top.check.op_b_alu testbench.top.check.WB_data_write testbench.top.check.ID_rs1_data testbench.top.check.WB_regwrite testbench.top.check.ID_rs2_data testbench.top.check.MEM_WR testbench.top.check.MEM_RD
probe -create -database waves testbench.top.control_main.current_state
probe -create -database waves testbench.top.check.check_add_1 testbench.top.check.check_add_2 testbench.top.check.check_add_3
probe -create -database waves testbench.top.id_stage.ID_rf_wdata_sel_i
probe -create -database waves testbench.top.id_stage.data_write_reg testbench.top.ex_stage.alu_result
probe -create -database waves testbench.top.wb_stage.WB_sel_to_reg_i
probe -create -database waves testbench.top.wb_stage.WB_alu_result
probe -create -database waves testbench.top.id_stage.WB_data_i
probe -create -database waves testbench.top.wb_stage.WB_data_write_reg_o

simvision -input /home/usr3/project/CPU_5stage_pipeline/run/.simvision/4137_usr3__autosave.tcl.svcf
