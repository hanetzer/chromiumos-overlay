# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="69feb5ecf55b322e5030ec1a4b348f9c9f2a7ce2"
CROS_WORKON_TREE="20cc26ede2e28a3ce6998b24a26d24a8f48d31ba"
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
