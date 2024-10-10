all:
#	xrun register_file.v defi.vh -access +rwc
# xrun -f list_file.f -access +rwc -logfile log/simulation.log -gui & 
	xrun -sv -f list_file.f -access +rwc -gui & -log log.txt 
#	xrun  control_hazard.v  defi.vh -access +rwc -logfile log/simulation.log -errormax 0 -top register_file -work log
all_1:
	xrun -sv -f list_file.f -access +rwc -coverage all -covoverwrite -covworkdir ./cor_work -covfile ./coverage.ccf -log log.txt

		
