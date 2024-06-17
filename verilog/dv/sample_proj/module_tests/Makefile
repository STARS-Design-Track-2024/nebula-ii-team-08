##############################################################################
# Runing the simulations
##############################################################################

#g flag enables sv support
%.vvp: %_tb.sv
	iverilog -Ttyp -DFUNCTIONAL -DSIM -DUSE_POWER_PINS -DUNIT_DELAY=#1 \
	-g2012 \
	-f$(USER_PROJECT_VERILOG)/includes/includes.rtl.caravel_user_project -o $@ $<

%.vcd: %.vvp
	vvp  $<
	mv $@ RTL-$@
	rm -f $<

# ---- Clean ----
clean:
	\rm  -f *.vvp *.log *.vcd *.lst

.PHONY: clean hex all