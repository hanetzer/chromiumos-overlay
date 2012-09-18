# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=d491c95488a5c96c8763bad37daeaf64b18fb92d
CROS_WORKON_TREE="05433cccbb3f339774d6f5c93fcc6de01ee84af5"

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

