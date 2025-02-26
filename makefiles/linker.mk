#Linker for all makefile projects

MAKEFILE_DIRECTORY := $(notdir $(shell pwd))
include ./Makefile.*
