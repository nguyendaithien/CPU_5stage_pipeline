
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
database -open -evcd -into verilog.dump _verilog.dump -timescale fs
database -open -shm -into waves.shm waves -default
database -open -vcd -into cpu.VCD _cpu.VCD1 -timescale fs
probe -create -database waves testbench.top.if_stage.csr_mepc_i testbench.top.if_stage.IF_exc_sel_i testbench.top.if_stage.IF_instr_compressed_o testbench.top.if_stage.IF_instr_fetch_err_o testbench.top.if_stage.IF_instr_i testbench.top.if_stage.IF_instr_o testbench.top.if_stage.IF_pc_o testbench.top.if_stage.IF_pc_sel_mux_i testbench.top.if_stage.IMEM_add_o testbench.top.if_stage.IMEM_data_i testbench.top.if_stage.Instr testbench.top.if_stage.boot_addr_i testbench.top.if_stage.clk testbench.top.if_stage.csr_depc_i testbench.top.if_stage.csr_mtvec_i testbench.top.if_stage.exc_add testbench.top.if_stage.flush testbench.top.if_stage.illegal_instr testbench.top.if_stage.illegal_instr_o testbench.top.if_stage.is_compressed testbench.top.if_stage.is_compressed_o testbench.top.if_stage.pc_dest testbench.top.if_stage.pc_next testbench.top.if_stage.pc_sel testbench.top.if_stage.pc_set_i testbench.top.if_stage.rst_n testbench.top.if_stage.stall testbench.top.check.bgeu_instr testbench.top.check.clk testbench.top.check.MEM_RD testbench.top.check.is_bgeu_instr testbench.top.check.EX_zero testbench.top.check.op_a_alu testbench.top.check.op_b_alu testbench.top.check.MEM_WR testbench.top.check.ID_rs1_data testbench.top.check.ID_rs2_data testbench.top.check.bltu_instr testbench.top.check.is_bltu_instr testbench.top.check.bge_instr testbench.top.check.is_bge_instr testbench.top.check.blt_instr testbench.top.check.is_blt_instr testbench.top.check.bne_instr testbench.top.check.is_bne_instr testbench.top.check.beg_instr testbench.top.check.is_beg_instr testbench.top.check.sw_instr testbench.top.check.mem_rs1_data testbench.top.check.is_sw_instr testbench.top.check.alu_result testbench.top.check.data_write_mem testbench.top.check.ID_imm testbench.top.check.sh_instr testbench.top.check.is_sh_instr testbench.top.check.sb_instr testbench.top.check.is_sb_instr testbench.top.check.lhu_instr testbench.top.check.WB_dmem_data testbench.top.check.is_lhu_instr testbench.top.check.WB_data_write testbench.top.check.data_write_reg testbench.top.check.WB_regwrite testbench.top.check.lbu_instr testbench.top.check.is_lbu_instr testbench.top.check.lb_instr testbench.top.check.is_lb_instr testbench.top.check.lh_instr testbench.top.check.is_lh_instr testbench.top.check.lw_instr testbench.top.check.is_lw_instr testbench.top.check.auipc_instr testbench.top.check.WB_imm testbench.top.check.is_auipc_instr testbench.top.check.ID_pc testbench.top.check.imm_u testbench.top.check.lui_instr testbench.top.check.is_lui_instr testbench.top.check.slli_instr testbench.top.check.is_slli_instr testbench.top.check.srli_instr testbench.top.check.is_srli_instr testbench.top.check.srai_instr testbench.top.check.is_srai_instr testbench.top.check.sltiu_instr testbench.top.check.is_sltiu_instr testbench.top.check.slti_instr testbench.top.check.is_slti_instr testbench.top.check.xori_instr testbench.top.check.is_xori_instr testbench.top.check.ori_instr testbench.top.check.is_ori_instr testbench.top.check.addi_instr testbench.top.check.is_addi_instr testbench.top.check.and_instr testbench.top.check.is_and_instr testbench.top.check.or_instr testbench.top.check.is_or_instr testbench.top.check.sra_instr testbench.top.check.is_sra_instr testbench.top.check.srl_instr testbench.top.check.is_srl_instr testbench.top.check.xor_instr testbench.top.check.is_xor_instr testbench.top.check.sltu_instr testbench.top.check.is_sltu_instr testbench.top.check.slt_instr testbench.top.check.is_slt_instr testbench.top.check.sll_instr testbench.top.check.is_sll_instr testbench.top.check.sub_instr testbench.top.check.is_sub_instr testbench.top.check.add_instr testbench.top.check.is_add_instr testbench.top.check.current_state testbench.top.check.no_hazard testbench.top.check.check_add_3 testbench.top.check.rst_n testbench.top.check.check_add_2 testbench.top.check.check_add_1
probe -create -database waves testbench.top.control_main.current_state

simvision -input /home/usr3/project/CPU_5stage_pipeline/run/.simvision/25769_usr3__autosave.tcl.svcf
