export THEOS=/Users/$(shell whoami)/Projects/theos
TARGET := appletv:clang:latest:9.0
DEBUG=1
include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libkbtask

libkbtask_FILES = $(wildcard *.m)
libkbtask_CFLAGS = -fobjc-arc -IPublic -I.
libkbtask_LDFLAGS = -ljb -L.
libkbtask_INSTALL_PATH = /fs/jb/usr/lib

include $(THEOS_MAKE_PATH)/library.mk
