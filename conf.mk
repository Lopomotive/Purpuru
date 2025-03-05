#Makefile configuration file
#All configurations are empty by default

#GENERAL

#Kernel directory, leave untouched if you do not know what you are doing
# Default = /lib/modules/$(shell uname -r)/build
KDIR =

#FLAGS

#Current C++ version being used, C++17 and up are only supported
# Default = 17
STD_VERSION = 

#More compiler info
# Default = false
MORE_INFO =

#Flags for debugging
# Default = -g3 -ggdb -DDEBUG
DEBUG_FLAGS =

#TIME

#Show time for compiler and build
# Default = true
TIMESTAMP =

#Gives file history timestamps, not currently implemented
# Default = true
FILE_TIMESTAMPS =

#GIT

#Version checking github repo, will automatically turn true if
# git repo is detected
# Default = false
USE_VERSION = false


