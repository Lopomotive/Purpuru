#Continue this

WARNING_FLAG =
NO_CLEAN = false

DPP_LIB =

#Check if integrated debug.h should be included
INTEGRATE_DEBUG ?= 

PRGM = $(shell pwd)
CPP_SRCS := $(shell find ./src -type f -name '*.cpp')
C_SRCS := $(shell find ./src -type f -name '*.c')
HDRS := $(shell find ./src -type f -name '*.h')
OBJS := $(SRCS:.cpp=.o)
DEPS := $(OBJS:.o=.d)

.PHONY: install all clean

install: all
ifeq ($(NO_CLEAN), false)
		$(MAKE) clean

all:
	
clean:
