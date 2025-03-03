#Shared for information wrappers and other things
#-------------------------
#Misc
#-------------------------

export INSTALL_PATH := bin$(PATH)

#-------------------------

#-------------------------
#OS
#-------------------------

#Check if superior arch user or other distro...
ARCH_LINUX := $(shell grep -q "Arch Linux" /etc/os-release 2>/dev/null && echo "Arch Linux")
DEBIAN := $(shell grep -q "Debian" /etc/os-release 2>/dev/null && echo "Debian")
UBUNTU := $(shell grep -q "Ubuntu" /etc/os-release 2>/dev/null && echo "Ubuntu")
FEDORA := $(shell grep -q "Fedora" /etc/os-release 2>/dev/null && echo "Fedora")
OPEN_SUSE := $(shell grep -q "openSUSE" /etc/os-release 2>/dev/null && echo "openSUSE")
CENTOS := $(shell grep -q "CentOS" /etc/os-release 2>/dev/null && echo "CentOS")
REDHAT := $(shell grep -q "Red Hat" /etc/os-release 2>/dev/null && echo "Red Hat")
ALPINE := $(shell grep -q "Alpine" /etc/os-release 2>/dev/null && echo "Alpine")

#------------------------- 
#Symlinks
#-------------------------
VERSION_SYMLINK :=
#Check if symlink functionality is enabled
BIN_SYMLINK ?= true
ifeq ($(BIN_SYMLINK),true)
	BIN_SYMLINK_CMD = ln -sf $(BIN_NAME) $(DESTDIR)$(PREFIX)/bin/$(PRGM_NAME)
endif

VERSION_SYMLINK ?= false
ifeq ($(VERSION_SYMLINK),true)
	@echo "Creating specific version symlink $>"
endif

#-------------------------

#-------------------------
# MISC
#-------------------------

DISCARD_MESSAGE := $(shell $@ > /dev/null 2>&1)

#Variable to exit gracefully, may become a function
EXIT_GRACEFULLY = 

#-------------------------

#-------------------------
#Logging
#-------------------------

#Logging not implemented yet
LOG_DIR = ./logs 
log:
	@mkdir -p $(LOG_DIR) $(DISCARD_MESSAGE)
	
#-------------------------
#Time
#-------------------------

#File timestamp function, check out
ifeq ($(LOG_TIMESTAMP),true)
    TIME_FILE = $(dir $@).$(notdir $@)_time
    TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S'
    ELAPSED_FORMAT = '%H:%M:%S'
    
    CUR_TIME = date '+%s'
    HUMAN_TIME = date '+$(TIMESTAMP_FORMAT)'
    
    START_TIME = @echo "[$(shell $(HUMAN_TIME))] Starting $@..." ; \
                 $(shell $(CUR_TIME)) > $(TIME_FILE)
    
    END_TIME = @st=$$(cat $(TIME_FILE)) ; \
               $(RM) $(TIME_FILE) ; \
               elapsed=$$(($$(date '+%s') - $$st)) ; \
               formatted=$$(date -u -d @$$elapsed '+$(ELAPSED_FORMAT)' 2>/dev/null || date -u -r $$elapsed '+$(ELAPSED_FORMAT)') ; \
               echo "[$(shell $(HUMAN_TIME))] Finished $@ (Time: $$formatted)"
    
    TIME_CMD = $(START_TIME) ; \
               $(CMD) ; \
               $(END_TIME)
endif
#-------------------------

#-------------------------
#Git 
#-------------------------

#Git url for fetch control
GIT_URL := https://github.com/Lopomotive/Purpuru

#Check if this is in a git repo
CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD>/dev/null | \
	echo "unknown branch")

#Automatically updates the file to the newest github version if found
AUTO_GIT ?= true

USE_GIT_VERSION = false

ifeq ($(shell git descrbe --tags >/dev/null 2>&1; echo $$?),0)
    # Git repo with tags detected
    USE_GIT_VERSION := true
    VERSION := $(shell git describe --tags --long --dirty --always | \
        sed 's/v\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)-\?.*-\([0-9]*\)-\(.*\)/\1 \2 \3 \4 \5/g')
    VERSION_MAJOR := $(word 1, $(VERSION))
    VERSION_MINOR := $(word 2, $(VERSION))
    VERSION_PATCH := $(word 3, $(VERSION))
    VERSION_REVISION := $(word 4, $(VERSION))
    VERSION_HASH := $(word 5, $(VERSION))
    VERSION_STRING := "$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(VERSION_REVISION)-$(VERSION_HASH)"
    
    # Add timestamp to version info
    BUILD_DATE := $(shell date '+%Y-%m-%d')
    BUILD_TIME := $(shell date '+%H:%M:%S')
    
    # Override with proper quoting for preprocessor defines
    override CXXFLAGS += -DVERSION_MAJOR=$(VERSION_MAJOR) \
        -DVERSION_MINOR=$(VERSION_MINOR) \
        -DVERSION_PATCH=$(VERSION_PATCH) \
        -DVERSION_REVISION=$(VERSION_REVISION) \
        -DVERSION_HASH=\"$(VERSION_HASH)\" \
        -DVERSION_STRING=\"$(VERSION_STRING)\" \
        -DBUILD_DATE=\"$(BUILD_DATE)\" \
        -DBUILD_TIME=\"$(BUILD_TIME)\" \
        -DGIT_BRANCH=\"$(CURRENT_BRANCH)\"
else
    # Fallback version if not in git repo or no tags
    VERSION_MAJOR := 0
    VERSION_MINOR := 0
    VERSION_PATCH := 1
    VERSION_REVISION := 0
    VERSION_HASH := "unknown"
    VERSION_STRING := "0.0.1.0-unknown"
    
    BUILD_DATE := $(shell date '+%Y-%m-%d')
    BUILD_TIME := $(shell date '+%H:%M:%S')
    
    override CXXFLAGS += -DVERSION_MAJOR=$(VERSION_MAJOR) \
        -DVERSION_MINOR=$(VERSION_MINOR) \
        -DVERSION_PATCH=$(VERSION_PATCH) \
        -DVERSION_REVISION=$(VERSION_REVISION) \
        -DVERSION_HASH=\"$(VERSION_HASH)\" \
        -DVERSION_STRING=\"$(VERSION_STRING)\" \
        -DBUILD_DATE=\"$(BUILD_DATE)\" \
        -DBUILD_TIME=\"$(BUILD_TIME)\" \
        -DGIT_BRANCH=\"$(CURRENT_BRANCH)\"
endif

#Remove PHONY later and place somewhere else
.PHONY: release
release:
	ifeq($(USE_GIT_VERSION), true)
	 	$(call important_wrapper, "Beginning to release build $(VERSION_STRING)")
	else
		$(call warning_wrapper, "Beginning to release uncertain build")
	endif

#Get git version
.PHONY:git_version

git_version:
ifdef GIT_VERSION
	GIT_REPO := $(shell git rev-parse --show-toplevel 2>/dev/null)
	$(call success_wrapper, "Git repository detected: $(GIT_REPO)")
	@$(RM) -f git_version.*
	@GIT_VER=$$(git describe --tags --long --dirty --always 2>/dev/null); \
	echo "$$GIT_VER" > git_version.$$GIT_VER; \
	echo "Git version $$GIT_VER"
else
	@GIT_VER="0.0.0-unknown"; \
	echo "$$GIT_VER" > git_version.$$GIT_VER; \
	$(call warning_wrapper, "Git repository not detected, using fallback: $$GIT_VER")
endif

#-------------------------

	
#-------------------------
#Wrappers
#-------------------------


ENABLE_COLOR ?= true

CUSTOM_WRAPPERS ?= true

#Info message wrapper
define info_wrapper
	$(if $(filter true,$(ENABLE_COLOR)), \
		@echo -e "\033[$(1)m<===================>\n$(2): $(3)\n<===================>\033[0m", \
		@echo "<===================>\n$(2): $(3)\n<===================>" \
	)
endef

#Warning message wrapper
define warning_wrapper
	$(eval WARNING_MESSAGE := $(1))
	$(if $(filter true, $(CUSTOM_WRAPPERS)), \
		$(call info_wrapper, "1;33", "Warning", $(WARNING_MESSSAGE)), \
		$(warning $(WARNING_MESSAGE)) \
	)
endef

#Error message wrapper
define error_wrapper
	$(eval ERROR_MESSAGE := $(1))
	$if($(filter true, $(CUSTOM_WRAPPERS)),
		$(call info_wrapper, "1;31", "Error", $(ERROR_MESSAGE)), \
		$(error $(ERROR_MESSAGE)) \
	) 
endef

#Important note wrapper
define important_wrapper
	$(eval IMPORTANT_MESSAGE := $(1))
	if( $(filter true, $(CUSTOM_WRAPPERS)), \
 		$(call info_wrapper, "1;34", "Important", $(IMPORTANT_MESSAGE)), \
		$(info $(IMPORTANT_MESSAGE)) \
	)
endef

#Sucess message wrapper
define sucess_wrapper
	$(eval SUCESSFUL_MESSAGE := $(1))
	$(call info_wrapper, "1;32", "Sucessful", $(SUCESSFUL_MESSAGE))
endef



