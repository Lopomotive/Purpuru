#Makefile test file

DEFAULT_TEST_LOG_DIR := $("test")
DEFAULT_TEST_LOG_FILE := $("default.log") 
TEST_DIR := $(shell mktemp -d)

