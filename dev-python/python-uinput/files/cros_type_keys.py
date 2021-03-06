#!/usr/bin/env python
# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import argparse
import cros_keys

argparser = argparse.ArgumentParser(description="Type text via events.")
argparser.add_argument(
    "-k", "--keyevents", action="store_true",
    help="Treat text as white space separated list of keyevents.")
argparser.add_argument("text", help="text or list of keyevent string")

args = argparser.parse_args()
if args.keyevents:
    cros_keys.press_keys(args.text.split())
else:
    cros_keys.type_chars(args.text)
