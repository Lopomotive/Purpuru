#Common makefile

include shared.mk

CXX := g++

TOPLVL = ../..

SHELL = $(shell echo $SHELL)

PRGM_NAME = Purpuru

WITH_SUDO = sudo

#Kernel build directory
KDIR = /lib/modules/$(shell uname -r)/build

#Get OS info
UNAME := $(shell uname -m) 
OS := $(shell uname -s)
KERNEL := $(shell uname -r)

CPP_SRCS := $(shell find ./src -type f -name '*.cpp' -not -path './src/SOURCE') 
C_SRCS := $(shell find ./src -type f -name '*.c' -not -path './src/SOURCE')
HDRS := $(shell find ./src -type f -name '*.h' -not -path './include/INCLUDE/*')

OBJS := $(CPP_SRCS:.cpp=.o) $(C_SRCS:.c=.o)
DEPS := $(OBJS:.o=.d)

#Config defaults 
BIN_NAME ?= Purpuru-bot 


#------------------

define check_source
	@echo "Checking include arguments..."
	$(if $(findstring -SOURCE=, $@),\
	    $(eval SOURCE_FILE := $(patsubst -SOURCE=%, %, $@))\
	    $(if $(wildcard $(SOURCE_FILE)),\
	        $(eval FILE_LOCATION := $(shell readlink -r $(SOURCE_FILE)))\
	        $(call  Header file found: $(FILE_LOCATION))\
	    ,\
	        $(info Header file not found: $(SOURCE_FILE))\
	    )\
	)
	$(call important_wrapper, "File sources checked")
endef

#Check if any files are mentioned in the INCLUDE= compiler speification in common/INCLUDE folder
define check_include
    @echo "Checking include arguments"
    $(if $(findstring -INCLUDE=, $@),\
        $(eval INCLUDE_FILE := $(patsubst -INCLUDE=%, %, $@))\
        $(if $(wildcard $(INCLUDE_FILE)),\
            $(eval FILE_LOCATION := $(shell readlink -r $(INCLUDE_FILE)))\
            $(call sucess_wrapper, "Header file found: $(FILE_LOCATION)")\
        ,\
            $(call error_wrapper, "Header file not found: $(INCLUDE_FILE)")\
        )\
    )
    $(call important_wrapper, "Include checked")
endef
			









