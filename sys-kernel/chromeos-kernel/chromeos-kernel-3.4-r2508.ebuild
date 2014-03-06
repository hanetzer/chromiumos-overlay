# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b4695e52c06d78cdc852b7705344d8c019393037"
CROS_WORKON_TREE="049289143ba913a5d3f90fde148452eb5ce8cd6d"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
CROS_WORKON_LOCALNAME="kernel/files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel"
KEYWORDS="*"

RDEPEND="!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel-exynos
	!sys-kernel/chromeos-kernel-3_10"
DEPEND="${RDEPEND}"

src_test() {
	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		# Needed for `cros_run_unit_tests`.
		cros-kernel2_src_test
	fi
}
