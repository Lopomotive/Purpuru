#Shared for information wrappers and other things

CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
export INSTALL_PATH := bin$(PATH)

#Check if superior arch user or other distro...
ARCH_LINUX := $(shell grep -q "Arch Linux" /etc/os-release 2>/dev/null && echo "Arch Linux")
DEBIAN := $(shell grep -q "Debian" /etc/os-release 2>/dev/null && echo "Debian")
UBUNTU := $(shell grep -q "Ubuntu" /etc/os-release 2>/dev/null && echo "Ubuntu")
FEDORA := $(shell grep -q "Fedora" /etc/os-release 2>/dev/null && echo "Fedora")
OPEN_SUSE := $(shell grep -q "openSUSE" /etc/os-release 2>/dev/null && echo "openSUSE")
CENTOS := $(shell grep -q "CentOS" /etc/os-release 2>/dev/null && echo "CentOS")
REDHAT := $(shell grep -q "Red Hat" /etc/os-release 2>/dev/null && echo "Red Hat")
ALPINE := $(shell grep -q "Alpine" /etc/os-release 2>/dev/null && echo "Alpine") 

ENABLE_COLOR := true

CUSTOM_WRAPPERS := true

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
define important_note
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



