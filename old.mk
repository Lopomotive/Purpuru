TOP_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

include $(TOP_DIR)/makefiles/linker.mk

NO_CLEAN = false

# Discord bot specific compiler flags
# Will be added later
DPP_LIB =

# Default compile response is to throw and exit gracefully
.DEFAULT: throw clean

# Handle makefile interruptions
.PRECIOUS: restore

# Phony targets
.PHONY: test clean docs dirs debug all install restore test-make

# Test target
test:
	@echo "Running tests..."

# Debug target
debug:
ifeq ($(USE_GIT_VERSION),true)
	$(call success_wrapper, "Beginning debugging build:")
	@echo $(VERSION_STRING)
else
	$(call warning_wrapper, "Beginning debugging build with unsure version")
endif
	$(call make_compile)

# General target
general:
	$(call compiler_flags)
	$(call flag_remove)
	$(call check_source)
	$(call check_include)

# Test-make target
test-make:
	@echo "Testing make"

# Build all target
all: $(PRGM)

$(PRGM): $(OBJS)
	@echo "Installing and compiling program..."
	@$(START_TIME)
	$(CXX) $(CXX_FLAGS) $(COMPILER_FLAGS) -o $@ $(OBJS) $(DPP_LIB)
	@echo "Time elapsed: \n"
	@$(END_TIME)

# C and C++ integration
%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(COMPILER_FLAGS) -MMD -MP -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) $(COMPILER_FLAGS) -MMD -MP -c $< -o $@


dirs:
	@echo "Creating directories"
	@mkdir -p $(dir $(OBJECTS))

	
# Install target
install:
ifeq ($(NO_CLEAN),false)
	@echo "Cleaning up..."
	$(MAKE) clean
endif
	@echo "Installing $(PRGM) to $(INSTALL_PATH)"
	install $(BIN_PATH)/$(BIN_NAME) $(DESTDIR)$(INSTALL_PREFIX)
	cp $(PRGM) $(INSTALL_PATH)

# Uninstall target
uninstall:
	@echo "Uninstalling $(PRGM) from $(INSTALL_PATH)"
	@$(RM) $(INSTALL_PATH)/$(PRGM)

# Clean target
clean:
	@echo "Cleaning up..."
	@$(RM) $(OBJS) $(DEPS) $(PRGM)
	@$(RM) $(BIN_NAME)
	@$(RM) -r build
	@$(RM) -r bin

# Restore target
restore:
	@echo "Restoring to previous version..."

# Include dependency files
-include $(DEPS)
