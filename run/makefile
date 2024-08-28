all:
#	xrun register_file.v defi.vh -access +rwc
#	xrun -f list_file.f -access +rwc -logfile log/simulation.log -gui & 
#	xrun  control_hazard.v  defi.vh -access +rwc -logfile log/simulation.log -errormax 0 -top register_file -work log
	make comp
	make run
	make gtk
comp:
	iverilog -o compile ../rtl/*.v ../rtl/defi.vh ../tb/testbench.v ../tb/DMEM.v
run:
	vvp compile
gtk:
	gtkwave *.VCD

