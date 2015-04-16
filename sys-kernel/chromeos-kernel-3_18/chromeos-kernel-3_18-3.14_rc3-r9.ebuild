# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="eb90dfa2a6e862168bc485adeca829779e1407ff"
CROS_WORKON_TREE="b381d3084c3bb5878bb9fa72d17f78a4d97377b6"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/v3.18-experiment"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.18"
KEYWORDS="*"
