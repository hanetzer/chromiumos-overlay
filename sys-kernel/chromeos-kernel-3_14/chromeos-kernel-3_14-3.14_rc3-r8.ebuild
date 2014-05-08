# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="30a95d48fa9b9fafbc135f957213124f76b24992"
CROS_WORKON_TREE="d5e18f98877fffa4536e500aae7206f3211c6e7a"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/3.14"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.14"
KEYWORDS="*"

DEPEND="!sys-kernel/chromeos-kernel-3_10
	!sys-kernel/chromeos-kernel-baytrail
	!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel"
RDEPEND="${DEPEND}"
