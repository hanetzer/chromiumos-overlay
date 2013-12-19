#!/bin/sh
#
# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

awk '
  $1 == "VERSION" { x = $3 }
  $1 == "PATCHLEVEL" { y = $3 }
  $1 == "SUBLEVEL" { z = $3 }
  END { print x "." y "." z }
' "$1/Makefile"
