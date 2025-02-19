#Continue this

INTEGRATED_FLAGS = 

WARNING_FLAG ?=
NO_CLEAN = false

#Discord bot lib
DPP_LIB =

#Check if integrated debug.h should be included
INTEGRATED_DEBUG ?= 

PRGM = Pupuru
CPP_SRCS := $(shell find ./src -type f -name '*.cpp')
C_SRCS := $(shell find ./src -type f -name '*.c')
HDRS := $(shell find ./src -type f -name '*.h')
OBJS := $(CPP_SRCS:.cpp=.o) $(C_SRCS:.c=.o)
DEPS := $(OBJS:.o=.d)

#User installation path
INSTALL_PATH =

#Gcc compiler and flags
CXX = g++
CXX_FLAGS = $(WARNING_FLAGS) $(INTEGRATED_FLAGS)

ifdef INTEGRATED_DEBUG
	CXXFLAGS += INTEGRATED_DEBUG

.PHONY: all install clean
	
all: $(PRGM)
	$(PRGM)
$(PRGM) : $(OBJS)
	$(CXX) $(CXX_FLAGS) -o $@ $(OBJS) $(DPP_LIB)

#C and C++ integration
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

%.o: %.c
	$(CCX) $(CFLAGS) -MMD -MP -c $< -o $@

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
	
-include $(DEPS)
