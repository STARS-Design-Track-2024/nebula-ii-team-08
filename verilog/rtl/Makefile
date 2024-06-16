PATTERNS = gpio_control sample_team_proj la_control
# PATTERNS = sample_team_proj team_template

#Bus Wrap Initialize
.PHONY: initialize
initialize:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		( cd $$i &&\
			make generate_wb_yaml \
		) ; \
	done

#Bus Wrap Generate
generate:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		( cd $$i &&\
		 	make generate_wb_wrapper \
		) ; \
	done