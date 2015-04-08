# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a6bca273ce4a3b6b4e78fefe219a85d62e70b529"
CROS_WORKON_TREE="3d7a4b229bc5598dcddca4bfe703aee7f789e8cf"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/v3.18-experiment"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.18"
KEYWORDS="*"
