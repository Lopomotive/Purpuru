#Linker for all makefile projects
PWD := $(shell pwd)
include $(PWD)/makefiles/common.mk
include $(PWD)/makefiles/shared.mk
include $(PWD)/makefiles/conf.mk
include $(PWD)/makefiles/deps.mk
include $(PWD)/makefiles/docs.mk

MAKEFILE_DIRECTORY := $(notdir $(shell pwd))
EXISTING_MAKEFILES := ./%.mk
VALID_MAKEFILES := common.mk \
	conf.mk \
	deps.mk \
	docs.mk \
	flags.mk \
	shared.mk
	
VALID_MAKEFILES := $(addprefix $(MAKEFILE_DIRECTORY)/, $(VALID_MAKEFILES))

# Check makefiles validity
ifeq ($(EXISTING_MAKEFILES),$(VALID_MAKEFILES))
    @echo "Makefiles match prerequisite ones"
	$(call YES_OR_NO, "Maybe you are using an old version, would you like to check?", exit 0) 
    @mkdir -p$(GIT_TEMPORARY_FOLDER)
    @git clone $(GIT_URL)/$(MAKEFILE_DIRECTORY) $(GIT_TEMPORARY_FOLDER) $(DISCARD_MESSAGE)

    ifeq ($(GIT_VERSION),unknown)
        $(call warning_wrapper, "No GitHub repository found")
        $(error "Git repository not found. Exiting.")
    else
        ifneq ($(GIT_VERSION),$(VERSION))
            @echo "Versions do not match"
            if [ "$(GIT_VERSION)" \< "$(VERSION)" ]; then \
                $(call YES_OR_NO, "Would you like to update from $(GIT_VERSION) to $(VERSION)?", exit 0); \
            else \
                @echo "Version is newer than GitHub one"; \
                $(call YES_OR_NO, "Would you like to log this issue?", exit 0); \
            fi
        endif
    endif
endif
