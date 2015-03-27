# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a66e20065b11c2944a5a63f0ed2536eb3898f9bb"
CROS_WORKON_TREE="c7d3b9d2f9ffa6b643ad1ddd6e95d2af66293cfe"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.14"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.14"
KEYWORDS="*"
