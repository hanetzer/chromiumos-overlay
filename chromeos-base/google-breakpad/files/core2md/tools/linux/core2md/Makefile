# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

all: core_dumper core2md

# The top of the breakpad source tree.
SRC = ../../..

INCLUDE_DIRS = -I$(SRC)
CXXFLAGS += -Wall -I$(SRC)

CORE2MD_OBJS = \
	core_reader.o \
	core2md.o \
	linux_dumper.o \
	minidump_writer.o \
	$(SRC)/client/minidump_file_writer.o \
	$(SRC)/common/convert_UTF.o \
	$(SRC)/common/linux/file_id.o \
	$(SRC)/common/string_conversion.o

core_dumper: core_dumper.o core_reader.o
	$(CXX) $(CXXFLAGS) -o $@ $^

core2md: $(CORE2MD_OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^

.cc.o:
	$(CXX) $(CXXFLAGS) $(INCLUDE_DIRS) -c $< -o $@

clean:
	rm -f *.o core_dumper
