all:
#	xrun register_file.v defi.vh -access +rwc
	xrun test.sv CPU_EDABK_TOP.v control_hazard.v WB_stage.v MEM_stage.v ALU.v EX_stage.v decoder.v register_file.v ID_stage.v defi.vh -access +rwc -logfile log/simulation.log -errormax 0 -top register_file -work log
#	xrun  control_hazard.v  defi.vh -access +rwc -logfile log/simulation.log -errormax 0 -top register_file -work log

