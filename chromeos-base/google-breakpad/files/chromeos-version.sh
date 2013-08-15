#!/bin/sh
#
# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script is given one argument: the base of the source directory of
# the package, and it prints a string on stdout with the numerical version
# number for said repo.

# Scan the git log looking for an svn rev like so:
# git-svn-id: http://google-breakpad.googlecode.com/svn/trunk@1204 4c0a9323-5329-0410-9bdc-e9ce6186880e
git --git-dir="$1/.git" log | \
  sed -n '/git-svn-id:/{s:.*@::;s: .*::;p;q}'
