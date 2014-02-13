# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0064490da885a20f3ca2b1b6965bacac2b216790"
CROS_WORKON_TREE="9f1de24e59b7add8639ef4c6e9536733ea7e671f"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel-next"
KEYWORDS="*"

DEPEND="!sys-kernel/chromeos-kernel"
RDEPEND="!sys-kernel/chromeos-kernel"
