#Lightweight makefile approach
NO_CLEAN = false

#Discord bot specific compiler flags
# Will be added later
DPP_LIB = 

#Gcc compiler and flags
CXX = g++
CXX_FLAGS = $(WARNING_FLAGS) $(INTEGRATED_FLAGS)

#Compiler hardening tags 
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

#Compiler hardening on by default
ifndef NO_COMPILER_HARDENING
	CXX_FLAGS += COMPILER_HARDNENING
endif

#Production code flags
# Can be good with better var name
INIT_FLAG := -fno-delete-null-pointer-checks -fno-strict-overflow \
	 -fno-strict-aliasing -ftrivial-auto-var-init=zero

#Kernel build directory
KDIR = /lib/modules/$(shell uname -r)/build
	 
#Get OS info
UNAME := $(shell uname -m) 
OS := $(shell uname -s)
KERNEL := $(shell uname -r)

#Cpu specific hardening
X86_64_HARDENING := -fPIE -pie -fPIC -shared -fcf-protection=full
X64_ARCH_HARDENING := -mbranch-protection=standard

ifeq ($(UNAME), x86_64)
	CXX_FLAGS += $(X86_64_HARDENING) $(X64_ARCH_HARDENING) 
endif

#Check if superior arch user or other distro...
ARCH_LINUX := $(shell grep -q "Arch Linux" /etc/os-release 2>/dev/null && echo "Arch Linux")
DEBIAN := $(shell grep -q "Debian" /etc/os-release 2>/dev/null && echo "Debian")
UBUNTU := $(shell grep -q "Ubuntu" /etc/os-release 2>/dev/null && echo "Ubuntu")
FEDORA := $(shell grep -q "Fedora" /etc/os-release 2>/dev/null && echo "Fedora")
OPEN_SUSE := $(shell grep -q "openSUSE" /etc/os-release 2>/dev/null && echo "openSUSE")
CENTOS := $(shell grep -q "CentOS" /etc/os-release 2>/dev/null && echo "CentOS")
REDHAT := $(shell grep -q "Red Hat" /etc/os-release 2>/dev/null && echo "Red Hat")
ALPINE := $(shell grep -q "Alpine" /etc/os-release 2>/dev/null && echo "Alpine") 

#Variable for all compiler flags
COMPILER_FLAGS := $(INTEGRATED_FLAGS) $(WARNING_FLAG) \
	$(COMPILER_HARDENING) $(X86_64_HARDENING)
	
#Info message wrapper
# Test this out
define info_wrapper
    @echo -e "\033[$(2)<===================>\n$(3): $(4)\n<===================>\033[0m"
endef

#Warning message wrapper
define warning_wrapper
	$(eval WARNING_MESSAGE := $(1))
	$(call info_wrapper, "1;33", "Warning", $(WARNING_MESSSAGE))
endef

#Error message wrapper
define error_wrapper
	$(eval ERROR_MESSAGE := $(1))
	$(call info_wrapper, "1;31", "Error", $(ERROR_MESSAGE))
endef

#Important note wrapper
define important_note
	$(eval IMPORTANT_MESSAGE := $(1))
	$(call info_wrapper, "1;34", "Important", $(IMPORTANT_MESSAGE))
endef

define compiler_flags
	@echo "Testing if flags are valid..."
	$(foreach FLAG_SECTION, $(COMPILER_FLAGS), \
		$(eval FLAGS := $($(FLAG_SECTION))) \
		$(foreach FLAG, $(FLAGS), \
			if $(CXX) $(FLAG) -E - < /dev/null > /dev/null 2>&1; then \
				echo "  [VALID] $(FLAG)"; \
			else \
				echo "  [INVALID] $(FLAG)"; \
				$(eval $(FLAG_SECTION) := $(filter-out $(FLAG), $($(FLAG_SECTION)))); \
			fi; \
		) \
		@echo "$(FLAG_SECTION): $($(FLAG_SECTION))" \
	)
endef
				
THREAD_HARDENING := -fcf-protection=full
ifeq (, $(wildcard /proc/sys/kernel/randomize_va_space))
	echo "Thread hardnening enabled"
	COMPILER_FLAGS += THREAD_HARDENING
else
	echo "Thread hardening is not compatiable with your kernel: $(KERNEL)"
endif

#Check if any files are mentioned in the INCLUDE= compiler speification in common/INCLUDE folder
define check_include
    @echo "Checking include arguments"
    $(if $(findstring -INCLUDE=, $@),\
        $(eval INCLUDE_FILE := $(patsubst -INCLUDE=%, %, $@))\
        $(if $(wildcard $(INCLUDE_FILE)),\
            $(eval FILE_LOCATION := $(shell readlink -r $(INCLUDE_FILE)))\
            $(info Header file found: $(FILE_LOCATION))\
        ,\
            $(info Header file not found: $(INCLUDE_FILE))\
        )\
    )
endef

define check_source
	@echo "Checking include arguments"
	$(if $(findstring -SOURCE=, $@),\
	    $(eval SOURCE_FILE := $(patsubst -SOURCE=%, %, $@))\
	    $(if $(wildcard $(SOURCE_FILE)),\
	        $(eval FILE_LOCATION := $(shell readlink -r $(SOURCE_FILE)))\
	        $(info Header file found: $(FILE_LOCATION))\
	    ,\
	        $(info Header file not found: $(SOURCE_FILE))\
	    )\
	)	
endef

PRGM := Pupuru

#Enable all header and implementation files except in INCLUDE and SOURCE
CPP_SRCS := $(shell find ./src -type f -name '*.cpp' -not -path './src/SOURCE') 
C_SRCS := $(shell find ./src -type f -name '*.c' -not -path './src/SOURCE')
HDRS := $(shell find ./src -type f -name '*.h' -not -path './include/INCLUDE/*')

OBJS := $(CPP_SRCS:.cpp=.o) $(C_SRCS:.c=.o)
DEPS := $(OBJS:.o=.d)

#User installation path
export INSTALL_PATH := bin$(PATH)

.PHONY: all install clean test

#Default
.DEFAULT: throw

#Handle makefile interuptions
.PRECIOUS: restore clean

#Handle potential file corruption
.DELETE_ON_ERROR: clean

#Look into one shell
.ONE_SHELL:

DEFAULT_TEST_LOG_DIR := $("test")
DEFAULT_TEST_LOG_FILE := $("default.log") 
TEST_DIR := $(shell mktemp -d)

#Remove unwanted flags
define flag_remove
    @echo "Compiler testing..."
    $(foreach FLAG_SECTION, $(COMPILER_FLAGS), \
        $(eval FLAGS := $($(FLAG_SECTION))) \
        $(foreach FLAG, $(FLAGS), \
            $(foreach ARG, $(MAKECMDGOALS), \
                $(if $(findstring --remove-$(FLAG), $(ARG)), \
                    $(eval $(FLAG_SECTION) := $(filter-out $(FLAG), $($(FLAG_SECTION)))))) \
        ) \
        $(eval $(FLAG_SECTION) := $$($(FLAG_SECTION))) \
        @echo "$(FLAG_SECTION): $($(FLAG_SECTION))" \
    ) \
    $(eval COMPILER_FLAGS := $(COMPILER_FLAGS))
endef

#Testing case 
test: $(PRGM)
	$(call compiler_flags)
	$(call flag_remove)
	$(CXX) $(COMPILER_FLAGS)

#Throw something at the current user
throw: 

all: $(PRGM)
	$(call flag_remove)
	$(PRGM)
$(PRGM) : $(OBJS)
	$(CXX) $(CXX_FLAGS) $(COMPILER_FLAGS) -o $@ $(OBJS) $(DPP_LIB)

#C and C++ integration
%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(COMPILER_FLAGS) -MMD -MP -c $< -o $@

%.o: %.c
	$(CCX) $(CFLAGS) $(COMPILER_FLAGS) -MMD -MP -c $< -o $@

install: all
ifeq($(NO_CLEAN), false)
	@echo "Cleaning up..."
	$(MAKE) clean
endif
	@echo "Installing $(PRGM) to $(INSTALL_PATH)"
	cp $(PRGM) $(INSTALL_PATH)

#Remove if cleaning is specified
clean:
	rm -rf $(OBJS) $(DEPS) $(PRGM)

#Restore safescript
restore:

-include $(DEPS)
