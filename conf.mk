#Makefile configuration file
#Uncommenting a configuration section like GENERAL: will proceed to parse all the default configuration
#values of the category
# Note: if you do not know what you are doing please leave the default settings
# as is

#GENERAL:

#Specifies if Makefile should do a cleanup after compiling, default = true
CLEANUP = true

#Name of the executebale to be created, default = Purpuru-bot
BIN_NAME = Purpuru-bot

#If makefile should include colored text in messages, default = true
ENABLE_COLOR =

#If makefile should include custom information wrappers
CUSTOM_WRAPPERS = 

#Compiler flags and settings for the GCC compiler
#Note that the current project only supports the native GCC linux compiler

#FLAGS:

#Extra specific debug, defualt = none
DLINK_FLAGS =

#Extra realease specific flags, default = none
RLINK_FLAGS =

#Flags for recompiling, often used for testing, default = -g3 -ggdb(requires gdb)
RECOMPILE_FLAGS =

#Logging specific settings

#Directory for logging files, default = ../makefiles/logs
LOG_DIR = 

#If log file should include timestamps, default = true
LOG_TIMESTAMP =

#If log file should include debug information, default = true
LOG_DEBUG =

#GIT specific settings
# Automatically update the file to the newest github version, default = true
AUTO_GIT = true

#Install specific settings
#INSTALL:

#Path of binary executeable, default = /usr/local/bin
INSTALL_PREFIX = /usr/local/bin

#Specify kernel build module, default = /lib/modules/$(shell uname -r)/build
KDIR =

#Path to the executeable prefix, do not touch this if you are clueless, default = /usr/local
PREFIX = /usr/local

#If symlink between binary and directory should be created, default=true
BIN_SYMLINK = true

#If symlink should link with different versions of the same software, default=false
VERSION_SYMLINK = false

