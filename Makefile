# chez-qt — Chez Scheme bindings for Qt6
#
# Depends on gerbil-qt for the C++ shim (vendor/qt_shim.h + vendor/libqt_shim.so)

GERBIL_QT_DIR := $(HOME)/mine/gerbil-qt
VENDOR_DIR    := $(GERBIL_QT_DIR)/vendor

QT_CFLAGS  := $(shell pkg-config --cflags Qt6Widgets 2>/dev/null)
QT_LIBS    := $(shell pkg-config --libs Qt6Widgets 2>/dev/null || echo "-lQt6Widgets")

CC       ?= gcc
CFLAGS   ?= -O2 -fPIC -Wall
SCHEME   ?= scheme

export CHEZ_QT_LIB := $(CURDIR)
export LD_LIBRARY_PATH := $(VENDOR_DIR):$(LD_LIBRARY_PATH)

.PHONY: all clean test libs

all: qt_chez_shim.so libs

qt_chez_shim.so: qt_chez_shim.c $(VENDOR_DIR)/qt_shim.h
	$(CC) $(CFLAGS) -I$(VENDOR_DIR) -shared -o $@ $< \
		-L$(VENDOR_DIR) -lqt_shim -Wl,-rpath,$(VENDOR_DIR) $(QT_LIBS)

libs: qt_chez_shim.so
	$(SCHEME) --libdirs . --compile-imported-libraries --program compile-libs.ss

test: all
	QT_QPA_PLATFORM=offscreen $(SCHEME) --libdirs . --script qt-test.ss

clean:
	rm -f qt_chez_shim.so
	rm -f chez-qt/*.so
