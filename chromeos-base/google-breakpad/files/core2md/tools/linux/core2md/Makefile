# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

all: core_dumper

# The top of the breakpad source tree.
SRC = ../../..

INCLUDE_DIRS = -I$(SRC)
CXXFLAGS += -Wall -Werror -I$(SRC)

core_dumper: core_dumper.o core_reader.o
	$(CXX) $(CXXFLAGS) -o $@ $^

.cc.o:
	$(CXX) $(CXXFLAGS) $(INCLUDE_DIRS) -c $< -o $@

clean:
	rm -f *.o core_dumper
