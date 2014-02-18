# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="060b8085634e06736ed299e8d62530523f0865b0"
CROS_WORKON_TREE="038e15701eb1ca02c272c47892fba96768e883ae"
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
