# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=5d456d5c5180d2b0585682e5c8b75503465b51a7
CROS_WORKON_TREE="daf6a5a79b0fb531746ddb71293c8b342c35e920"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
CROS_WORKON_LOCALNAME="../third_party/kernel/files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel"
KEYWORDS="amd64 arm x86"

RDEPEND="!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel-exynos"
DEPEND="${RDEPEND}"

