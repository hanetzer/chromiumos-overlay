# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="4eb0f1b7936c6551e5f13e54c65d2b6716f1edd2"
CROS_WORKON_TREE="55a21015c6b1dfca353e0e6181f1b574bb665a8c"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/v3.18-experiment"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.18"
KEYWORDS="*"
