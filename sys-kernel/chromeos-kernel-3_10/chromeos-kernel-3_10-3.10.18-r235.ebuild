# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="de8374203b9ebb1d0ec25f7c20942583134ef3c7"
CROS_WORKON_TREE="a46620d16930c62ddf4e2bc5f5878e339502c692"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/3.10"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.10"
KEYWORDS="*"

DEPEND="!sys-kernel/chromeos-kernel-baytrail
	!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel"
RDEPEND="${DEPEND}"
