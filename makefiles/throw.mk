#Makefile handling exceptions and errors


#Throw something at the current user
throw:
	$(call error_wrapper, "Fatal error occured whilst compiling")
	#Trap what is causing the error
	TRAPPED_ERRORS := bash -c "trap "

	#This needs working
	@echo -n "Do you want to analyze the current error: $(TRAPPED_ERROR)? [y/N] " && read ans && [ $${ans:-N} = y ]
	if [ $${ans} = y ] || [ $${ans} = Y ]; then \
        printf $(_SUCCESS) "YES" ; \
    else \
        printf $(_DANGER) "NO" ; \
    fi
    @echo 'Next steps...'


