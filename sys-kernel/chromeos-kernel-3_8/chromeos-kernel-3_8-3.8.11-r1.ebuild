# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b09f31da2ed251e0be2ee83ffea49a6386532dff"
CROS_WORKON_TREE="18f14dacc2790c01a7e1705124916a6549c58f20"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/3.8"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.8"
KEYWORDS="*"

DEPEND="!sys-kernel/chromeos-kernel
	!sys-kernel/chromeos-kernel-3_10
	!sys-kernel/chromeos-kernel-3_14"
RDEPEND="${DEPEND}"
