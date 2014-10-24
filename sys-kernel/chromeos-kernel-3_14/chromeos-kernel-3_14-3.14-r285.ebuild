# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="4baf23725a628efa4b41a08feef1c5ef2a04de2f"
CROS_WORKON_TREE="d0e16139cdbbbf0e0d20b7c2f3cc33c580c0c159"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/3.14"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.14"
KEYWORDS="*"
