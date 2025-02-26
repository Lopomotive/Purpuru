#Makefile flags for flags

include ./shared.mk

CXX_FLAGS = $(WARNING_FLAGS) $(INTEGRATED_FLAGS)

COMPILER_HARDENING := -Wall -O3 -Wformat -Wformat=2 \
	-Wconversion -Wimplicit-fallthrough -Werror=format-security \
	-Wbidi-chars=any -Wextra -Wformat-nonliteral -Wformat-security\
	-Wfatal-errors -D_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 \
	-D_GLIBCXX_ASSERTIONS \
	-fstack-clash-protection -fstack-protector-strong \
	-Wl,-z,nodlopen -Wl,-z,noexecstack -Wl,-z,relro \
	-Wl,-z,now -Wl,--as-needed -Wl,--no-copy-dt-needed-entries \
	-Wtrampolines -Werror=implicit -Werror=incompatiable-pointer-types \
	-Werror=int-convertions 

#Production code flags
INIT_FLAG := -fno-delete-null-pointer-checks -fno-strict-overflow \
	 -fno-strict-aliasing -ftrivial-auto-var-init=zero

#Cpu specific hardening
X86_64_HARDENING := -fPIE -pie -fPIC -shared -fcf-protection=full
X64_ARCH_HARDENING := -mbranch-protection=standard

ifeq ($(UNAME), x86_64)
	CXX_FLAGS += $(X86_64_HARDENING) $(X64_ARCH_HARDENING) 
endif

#Recompilation/failsafe testing flags
RECOMPILE_FLAGS := -D NDEBUG -g3

#Variable for all compiler flags
COMPILER_FLAGS := $(INTEGRATED_FLAGS) $(WARNING_FLAG) \
	$(COMPILER_HARDENING) $(X86_64_HARDENING)

ifndef NO_COMPILER_HARDENING
	CXX_FLAGS += COMPILER_HARDNENING
endif

#This needs to be worked on
define compiler_flags
	@echo "Testing if flags are valid..."
	$(foreach FLAG_SECTION, $(COMPILER_FLAGS), \
		$(eval FLAGS := $($(FLAG_SECTION))) \
		$(foreach FLAG, $(FLAGS), \
			if $(CXX) $(FLAG) -E - < /dev/null > /dev/null 2>&1; then \
				echo "  [VALID] $(FLAG)"; \
			else \
				$(call warning_wrapper, "Warning invalid flag: $(FLAG)")
				$(eval $(FLAG_SECTION) := $(filter-out $(FLAG), $($(FLAG_SECTION)))); \
			fi; \
		) \
		@echo "$(FLAG_SECTION): $($(FLAG_SECTION))" \
	)
	$(call sucess_wrapper, "Compiler flag filtering was succesful!")
endef
	
THREAD_HARDENING := -fcf-protection=full
ifeq (, $(wildcard /proc/sys/kernel/randomize_va_space))
	COMPILER_FLAGS += THREAD_HARDENING
	$(call sucess_wrapper, "Sucessfully added thread hardening")
else
	$(call error_message, "Thread hardening not avaliable on system")
endif

define flag_remove
    @echo "Compiler testing..."
    $(foreach FLAG_SECTION, $(COMPILER_FLAGS), \
        $(eval FLAGS := $($(FLAG_SECTION))) \
        $(foreach FLAG, $(FLAGS), \
            $(foreach ARG, $(MAKECMDGOALS), \
                $(if $(findstring --remove-$(FLAG), $(ARG)), \
                    $(eval $(FLAG_SECTION) := $(filter-out $(FLAG), $($(FLAG_SECTION)))))) \
                else
                	$(call warning_wrapper, "Flag: $(FLAG), not found")
        ) \
        $(eval $(FLAG_SECTION) := $$($(FLAG_SECTION))) \
        $(call important_wrapper, "Flag completed")
    ) \
    $(eval COMPILER_FLAGS := $(COMPILER_FLAGS)) \
    $(call sucess_wrapper, "Unwanted flags succesfully removed")
endef



