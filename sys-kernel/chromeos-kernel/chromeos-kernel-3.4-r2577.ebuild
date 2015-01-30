# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="98a3381aa01583a3ebcd0b92967768ca98647a13"
CROS_WORKON_TREE="e2407f176ddaa8f957d4560eb667140bde7661d1"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
CROS_WORKON_LOCALNAME="kernel/v3.4"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel 3.4"
KEYWORDS="*"

src_test() {
	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		# Needed for `cros_run_unit_tests`.
		cros-kernel2_src_test
	fi
}
