# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b2776bf7149bddd1f4161f14f79520f17fc1d71d"
CROS_WORKON_TREE="03bfa96b6009c6a82187282345e733eddc1f5373"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/v3.18-experiment"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.18"
KEYWORDS="*"
