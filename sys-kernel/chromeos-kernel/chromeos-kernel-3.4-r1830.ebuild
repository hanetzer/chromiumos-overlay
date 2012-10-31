# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="11b92b16b822a8f3dae1a0c68d9f0187580a3328"
CROS_WORKON_TREE="c9704dadaf4eb8aaa3570f94e192fa4971022d4e"

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

