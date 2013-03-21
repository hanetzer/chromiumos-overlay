# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="6febf4d3a6413d20ac59449c0b5c61bfabbb7362"
CROS_WORKON_TREE="3d49f004064b959303f2c778e69d7ef93b09ec66"
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

src_test() {
	# Needed for `cros_run_unit_tests`.
	cros-kernel2_src_test
}
