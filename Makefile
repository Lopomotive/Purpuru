###MAKEFILE###

#=======================>
# VALIDATION
#=======================>
ifndef CXX
    $(error Compiler (CXX) not defined)
endif

# CHANGE: Check for minimum required tools before proceeding
REQUIRED_TOOLS := git make $(CXX)
$(foreach tool,$(REQUIRED_TOOLS),\
    $(if $(shell which $(tool)),,\
        $(error Required tool '$(tool)' not found)\
    )\
)
#=======================>
# GENERAL
#=======================>

#Include make config file
include config.mk
 
CXX := g++
CPP_SRC_EXT = cpp
C_SRC_EXT = c

#Project dependencies
DEPS_DIR := deps
DEPS :=

DEPS_INSTALL_SCRIPT = deps.sh

BIN_NAME ?= Purpuru-bot

#Versioning variables
VERSION_MAJOR ?= 0
VERSION_MINOR ?= 1
VERSION_PATCH ?= 0

PWD = $(shell pwd)
CUR_DIR := $(nodir $(PWD))
SHELL = /bin/sh
KDIR ?= /lib/modules/$(shell uname -r)/build

UNAME := $(shell uname -m) 
OS := $(shell uname -s)
KERNEL := $(shell uname -r)

DISCARD_MESSAGE := $(shell $@ > /dev/null 2>&1)

TARGET_ARCH ?= native
CROSS_COMPILE ?=

ifeq ($(TARGET_ARCH),native)
    ARCH_FLAGS := -march=native
else
    CC := $(CROSS_COMPILE)gcc
    CXX := $(CROSS_COMPILE)g++
    ARCH_FLAGS := -march=$(TARGET_ARCH)
endif

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

SRC_DIR = src
INCLUDE_DIR = include

CPP_SRCS := $(shell find $(SRC_DIR) -type f -name '*.cpp' -not -path '$(SRC_DIR)/SOURCE')
C_SRCS := $(shell find $(SRC_DIR) -type f -name '*.c' -not -path '$(SRC_DIR)/SOURCE')
HDRS := $(shell find $(INCLUDE_DIR) -type f -name '*.h' -not -path '$(INCLUDE_DIR)/INCLUDE')

OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(CPP_SRCS)) \
        $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SRCS))
DEPS := $(OBJS:.o=.d)

#=======================>
#PATHS
#=======================>

#Install envoirement
INSTALL_PREFIX := /usr/local
ENV_BUILD_DIR := $(CUR_DIR)/build
ENV_BINDIR := $(PREFIX)/bin
ENV_LIBDIR := $(PREFIX)/lib

BUILD_DIR = build
BIN_DIR = bin
TEST_DIR = tests

$(DEPS_DIR):
	@mkdir -p $(DEPS_DIR)

DOCS_DIR = docs

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
        $(eval FOUND_STD := true)\
    )
endef

$(foreach ENTRY,$(STD_SUPPORTED),\
    $(call CHECK_CXX_VERSION,$(ENTRY))\
    $(if $(break),$(break))\
)

ifndef FOUND_STD
    $(error No supported C++ standard found. Minimum C++17 required.)
endif

EXTRA_WARNINGS := -Wextra -Wpedantic -Wconversion \
                  -Wshadow -Wfloat-equal -Wlogical-op

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

CXX_FLAGS += COMPILER_HARDENING
CXX_FLAGS += INIT_FLAG

#Architecture specific hardening
ifeq ($(UNAME), x86_64)
    CXX_FLAGS += -fPIE -pie -fPIC -shared -fcf-protection=full -mbranch-protection=standard
endif

DEBUG_FLAGS ?= -g3 -ggdb -DDEBUG

#Check this out
SANITIZERS := address undefined thread
define add_sanitizer
sanitize-$(1): CXX_FLAGS += -fsanitize=$(1) -fno-omit-frame-pointer
sanitize-$(1): clean build
endef

$(foreach san,$(SANITIZERS),$(eval $(call add_sanitizer,$(san))))
#=======================>
#TIME
#=======================>

TIMESTAMP ?= true

ifeq ($(TIMESTAMP),true)
    TIME_CMD = @echo "[$$(date '+%Y-%m-%d %H:%M:%S')] Starting $@..." ; \
               start=$$(date +%s) ; \
               $(1) ; \
               end=$$(date +%s) ; \
               elapsed=$$((end - start)) ; \
               echo "[$$(date '+%Y-%m-%d %H:%M:%S')] Finished $@ (Time: $$elapsed seconds)"
else
    TIME_CMD = $(1)
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

#=======================>
#LOG
#=======================>
#Log currently not functioning

LOG_DIR ?= $(CUR_DIR)/log
ifneq(LOG_DIR, $(CUR_DIR)/log)
	@echo "Making custom set directory: $(LOG_DIR)"
	@mkdir -p $(LOG_DIR)
endif

define log

	TIME_STAMP = $1
endef
#=======================>
#TARGETS
#=======================>

.PHONY: all release debug build install uninstall clean test memcheck update isolate recompile installcheck dist distclean fetch-deps docs clean-docs version static-analysis

all:build

release: build

debug: CXX_FLAGS += $(DEBUG_FLAGS)
debug:build

dirs:
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(TEST_DIR)

fetch-deps:
	@echo "Fetching project dependencies..."
	@git submodule update --init --recursive

build: dirs $(BIN_DIR)/$(BIN_NAME)
	$(call check_source)
	$(call check_include)

$(BIN_DIR)/$(BIN_NAME): $(OBJS)
	@$(call TIME_CMD, $(CXX) $(CXX_FLAGS) -o $@ $^)

# Compilation rules for source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.$(CPP_SRC_EXT)
	@mkdir -p $(dir $@)
	@$(call TIME_CMD, $(CXX) $(CXX_FLAGS) -MMD -MP -c -o $@ $<)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.$(C_SRC_EXT)
	@mkdir -p $(dir $@)
	@$(call TIME_CMD, $(CXX) $(CXX_FLAGS) -MMD -MP -c -o $@ $<)

install: build
	@echo "Installing $(BIN_NAME) to $(INSTALL_PREFIX)/bin"
	@install -d $(INSTALL_PREFIX)/bin
	@install -m 755 $(BINDIR)/$(BIN_NAME) $(INSTALL_PREFIX)/bin/	

uinstall:
	@echo "Removing $(BIN_NAME) from $(INSTALL_PREFIX)/bin"
	@rm -f $(ENV_BINDIR)/$(BIN_NAME)

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(BIN_DIR)
	@rm -rf $(TEST_DIR)

#Docs section
docs:
	DOXYGEN := $(shell command -v$ (DISCARD_MESSAGE))
	ifeq($(DOXYGEN),)
		@echo "Doxygen not installed"
		$(call YES_OR_NO, "Do you want to install doxygen?")
			$(./$(DEPS_INSTALL_SCRIPT)) 
	endif
	#Doxygen documentation code here

clean-docs:
	@$(RM) -rf $(DOC_DIR)

static-analysis:
	@cppcheck $(SRC_DIR) --enable=all --inconclusive --std=c++$(FOUND_STD)
	@clang-tidy $(CPP_SRCS) -- $(CXX_FLAGS)

version:
	@echo "Current project version: $(CURRENT_VERSION)"

test: build
	@echo "Preparing test environment..."
	@mkdir -p $(TEST_DIR)
	@$(CXX) $(CXX_FLAGS) $(DEBUG_FLAGS) $(OBJS) $(TEST_SRC) -o $(TEST_BIN)
	@echo "Running tests..."
	@$(TEST_BIN)

memcheck: test
	@echo "Running memory check with Valgrind..."
	@valgrind --leak-check=full \
		--show-leak-kinds=all \
		--track-origins=yes \
		--verbose \
		--log-file=$(LOG_DIR)/valgrind-report.txt \
		$(TEST_BIN)

update:
ifeq ($(USE_LATEST_VERSION),true)
	@echo "Checking for updates..."
	@TEMP_DIR=$$(mktemp -d); \
	git clone https://github.com/Lopomotive/Purpuru $$TEMP_DIR; \
	if [ -n "$(VERSION_STRING)" ]; then \
		REMOTE_VERSION=$$(cd $$TEMP_DIR && git describe --tags); \
		if [ "$$REMOTE_VERSION" != "$(VERSION_STRING)" ]; then \
			echo "Newer version found. Update mechanism to be implemented."; \
		else \
			echo "Already on the latest version."; \
		fi; \
	fi; \
	rm -rf $$TEMP_DIR
endif

#Placeholder future makefile targets
isolate:
recompile:
installcheck:
dist:
distclean:

-include $(DEPS)

