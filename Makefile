###MAKEFILE###

#=======================>
# GENERAL
#=======================>

#Include make config file
include config.mk
 
CXX := g++
CPP_SRC_EXT = cpp
C_SRC_EXT = c

BIN_NAME ?= Purpuru-bot

MAKEFILE =
WITH_SUDO = sudo
TOPLVL = ../..
PWD = $(shell pwd)
CUR_DIR := $(nodir $(PWD))
SHELL = /bin/sh
KDIR ?= /lib/modules/$(shell uname -r)/build

UNAME := $(shell uname -m) 
OS := $(shell uname -s)
KERNEL := $(shell uname -r)

DISCARD_MESSAGE := $(shell $@ > /dev/null 2>&1)

#If output of statistics should be the raw output or not
RAW_OUTPUT ?= false

#General function for outputting stats
define VOMIT_STATS

endef

#Yes or no
define YES_OR_NO
	@echo -n "$(1) [y/N] " && read ans && [ $${ans:-N} = y ] || \
	 (echo "Action cancelled."; $(2))
endef

#Check source files *.cpp and *.c
define check_source
	@echo "Checking include arguments..."
	$(if $(findstring -SOURCE=, $@),\
	    $(eval SOURCE_FILE := $(patsubst -SOURCE=%, %, $@))\
	    $(if $(wildcard $(SOURCE_FILE)),\
	        $(eval FILE_LOCATION := $(shell readlink -r $(SOURCE_FILE)))\
	        $(error "Source file not found: $(SOURCE_FILE) \n") \ 
	    ,\
	    	@echo "Source file found $(SOURCE_FILE) \n"  \
	    )\
	)
	@echo "All file sources checked $@ $>"
endef

#Check include files *.h
define check_include
    @echo "Checking include arguments"
    $(if $(findstring -INCLUDE=, $@),\
        $(eval INCLUDE_FILE := $(patsubst -INCLUDE=%, %, $@))\
        $(if $(wildcard $(INCLUDE_FILE)),\
            $(eval FILE_LOCATION := $(shell readlink -r $(INCLUDE_FILE)))\
            @echo "Header file found $(INCLUDE_FILE)"
        ,\
            $(error "Header file not found: $(INCLUDE_FILE)")
        )\
    )
    @echo "All file sources checked $@ $>"
endef
	
#=======================>
#GENERAL COMPILER
#=======================>

#This might be changed
CPP_SRCS := $(shell find ./src -type f -name '*.cpp' -not -path './src/SOURCE') 
C_SRCS := $(shell find ./src -type f -name '*.c' -not -path './src/SOURCE')
HDRS := $(shell find ./src -type f -name '*.h' -not -path './include/INCLUDE/*')

OBJS := $(CPP_SRCS:.cpp=.o) $(C_SRCS:.c=.o)
DEPS := $(OBJS:.o=.d)

#=======================>
#PATHS
#=======================>

INSTALL_PREFIX := /usr/local
BUILD_DIR := $(CUR_DIR)/build
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib
INCLUDEDIR := $(PREFIX)/include

#=======================>
#FLAGS
#=======================>

CXX_FLAGS =
#Std flag and supported versions
STD_VERSION ?= 
#C++26 not supported 
STD_SUPPORTED := 17 20 23
define CHECK_CXX_VERSION
    $(if $(shell $(CXX) -std=c++$(1) -E -x c++ /dev/null 2>/dev/null >/dev/null; echo $$?),\
        $(eval CXX_FLAGS += -std=c++$(1))\
        $(eval break = true)\
    else
    	@echo "Versions under C++17 are not supported..."
    	exit 1
    )
endef

$(foreach ENTRY,$(STD_SUPPORTED),\
    $(call CHECK_CXX_VERSION,$(ENTRY))\
    $(if $(break),$(break))\
)

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

INIT_FLAG := -fno-delete-null-pointer-checks -fno-strict-overflow \
	 -fno-strict-aliasing -ftrivial-auto-var-init=zero

X86_64_HARDENING := -fPIE -pie -fPIC -shared -fcf-protection=full
X64_ARCH_HARDENING := -mbranch-protection=standard

ifeq ($(UNAME), x86_64)
	CXX_FLAGS += $(X86_64_HARDENING) $(X64_ARCH_HARDENING) 
endif

RECOMPILE_FLAGS ?= -g3 -ggdb

THREAD_HARDENING := -fcf-protection=full
ifeq (, $(wildcard /proc/sys/kernel/randomize_va_space))
	CXX_FLAGAS += THREAD_HARDENING
	@echo "Sucessfully added thread hardening: $$?"
else
	@echo "Thread hardnening not avaliable on system: $$?"
endif

#=======================>
#SYMLINK
#=======================>

#Symlink might not be needed as its own directory
CREATE_BIN_SYMLINK ?= true
#Version symlink to link with different versions
VERSION_SYMLINK ?= true

SYMLINK_CMD := ln -s 

#=======================>
#TIME
#=======================>

TIMESTAMP ?= true

LOG_TIMESTAPM ?= true
#Time functionality, check
ifeq ($(LOG_TIMESTAMP),true)
    TIME_FILE = $(dir $@).$(notdir $@)_time
    TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S'
    ELAPSED_FORMAT = '%H:%M:%S'
    
    CUR_TIME = date '+%s'
    HUMAN_TIME = date '+$(TIMESTAMP_FORMAT)'
    
    START_TIME = echo "[$$(date '+$(TIMESTAMP_FORMAT)')] Starting $@..." ; \
                 $(CUR_TIME) > $(TIME_FILE)
    
    END_TIME = st=$$(cat $(TIME_FILE)) ; \
               $(RM) $(TIME_FILE) ; \
               elapsed=$$(($$(date '+%s') - $$st)) ; \
               formatted=$$(date -u -d @$$elapsed '+$(ELAPSED_FORMAT)' 2>/dev/null || date -u -r $$elapsed '+$(ELAPSED_FORMAT)') ; \
               echo "[$$(date '+$(TIMESTAMP_FORMAT)')] Finished $@ (Time: $$formatted)"
    
    TIME_CMD = $(START_TIME) ; \
               $(1) ; \
               $(END_TIME)
endif

#Timestamp when file has last been modified
FILE_TIMESTAMPS ?= true
ifeq(FILE_TIMESTAMPS, true)
	LAST_MODIFIED_RAW := $(shell stat @$ | grep Modify)
	LAST_MODIFIED := $(shell stat --format=%y @$ | sed 's/\..*//')

	LAST_ACESSED_RAW := $(shell stat @$ | grep Access)
	LAST_ACESSED := $(shell stat --format=%x @$ | sed 's/\..*//')

	LAST_CHANGE_RAW := $(shell stat @$ | grep Change)
	LAST_CHANGE := $(shell stat --format=%x @$ | sed 's/\..*//')

	#Output stats
	define VOMIT_TIME_STATS
		ifeq(RAW_OUTPUT, true)
			@echo "Outputting raw file time stats..."
			STATS_RAW := $(filter %_RAW,$(.VARIABLES))
			$(foreach STAT, $(STATS_RAW), \
				@echo "$(STAT): $$($(STAT))" \
			)
		else
			@echo "Outputting filtered file time stats"
			STATS := $(filer-out %_RAW, $(.VARIABLES))
			$(foreach STAT, $(STATS),
				@echo "$(STAT): $$($(STAT))" \ 
			)
		endif
	endef
endif

#=======================>
#GIT
#=======================>

CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD>/dev/null | \
	echo "unknown branch")

#Version checking
USE_VERSION ?= false

ifeq ($(shell git describe > /dev/null 2>&1 ; echo $$?), 0)
	USE_VERSION := true
	VERSION := $(shell git describe --tags --long --dirty --always | \
		sed 's/v\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)-\?.*-\([0-9]*\)-\(.*\)/\1 \2 \3 \4 \5/g')
	VERSION_MAJOR := $(word 1, $(VERSION))
	VERSION_MINOR := $(word 2, $(VERSION))
	VERSION_PATCH := $(word 3, $(VERSION))
	VERSION_REVISION := $(word 4, $(VERSION))
	VERSION_HASH := $(word 5, $(VERSION))
	VERSION_STRING := \
		"$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(VERSION_REVISION)-$(VERSION_HASH)"
	override CXXFLAGS := $(CXXFLAGS) \
		-D VERSION_MAJOR=$(VERSION_MAJOR) \
		-D VERSION_MINOR=$(VERSION_MINOR) \
		-D VERSION_PATCH=$(VERSION_PATCH) \
		-D VERSION_REVISION=$(VERSION_REVISION) \
		-D VERSION_HASH=\"$(VERSION_HASH)\"
endif

#Git updates to the latest version
USE_LATEST_VERSION ?= true

#CONTINUE HERE WITH THIS
ifeq(USE_LATEST_VERSION, true)
	TEMP_GIT_FOLDER := $(CUR_DIR)/"git_temp"
	$(eval TMP := $(shell mktemp -d))
	@mkdir -p TEMP_GIT_FOLDER
	@echo "Checking git version"
	git clone https://github.com/Lopomotive/Purpuru $(TEMP_GIT_FOLDER) $(DISCARD_MESSAGE)
	@echo "Cloning..."
	TEMP_GIT_VERSION := 
	
	@$(RM) -rf TEMP_GIT_FOLDER
endif

#Automatically update to the newest version
AUTO_GIT ?= true

#=======================>
#LOG
#=======================>

LOG_DIR ?= $(CUR_DIR)/log
ifneq(LOG_DIR, $(CUR_DIR)/log)
	@echo "Making custom set directory: $(LOG_DIR)"
	@mkdir -p $(LOG_DIR)
endif

define log

	TIME_STAMP = $1
endef
#=======================>
#INSTALL
#=======================>

.PHONY: release debug dirs install uinstall clean all isolate update

#Standard, non-optimized release build
release: dirs
ifeq($(USE_VERSION), true)
	@echo "Beginning to release build"
else
	@$(START_TIME)
	@$(MAKE) all 
endif

#Work on this debug
debug: all
	@echo "Debugging file... @$"
	$(CXX_FLAGS) += RECOMPILE_FLAGS
	
	
dirs:
	@echo "Creating directories"
	@mdkir -p $(dir $(OBJS))
	@mdkir -p $(BINDIR)

install:
	@echo "Installing bin to $(BINDIR)"
	

uinstall:
	@echo "Removing file from $(BINDIR)"
	@$(RM) $(BINDIR)/$(BIN_NAME)

	
clean:
	@echo "Cleaning..."
	@echo "Deleting $(BIN_NAME) symlink"
	@$(STAR_TIME)
	@$(RM) $(BIN_NAME)
	@echo "Deleting dir tree..."
	$@(RM) -r build
	$@(RM) -r bin
	
all: $(BINDIR)/$(BIN_NAME)
	@echo "Creating symlink..."
	@$(RM) $(BIN_NAME)
	@$(START_TIME)
	@$(CREATE_SYMLINK) $(BINDIR)/$(BIN_NAME) $(BIN_NAME)
	
	@echo -en "\t Make time:"
	@$(END_TIME)

$(BINDIR)/$(BIN_NAME) : $(OBJS)
	@echo "Linking current: $@"
	@$(START_TIME)
	$(CXX) $(CXX_FLAGS) $(OBJS) -o $@
	@echo -en "\t Link time:"
	@$(END_TIME)

#For isolating specified code files
isolate:

#For recompiling makefile, check if changes to dir have been made
recompile:

#Check install 
installcheck:

dist:

distclean:

update:

-include $(DEPS)

$()
