# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b0b37eb50164e384fb3af1dd0c641c6e0c8b5c22"
CROS_WORKON_TREE="15038dd990b3eabf061cea2df8021ee7e5fc8424"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel-next"
KEYWORDS="*"

DEPEND="!sys-kernel/chromeos-kernel"
RDEPEND="!sys-kernel/chromeos-kernel"
