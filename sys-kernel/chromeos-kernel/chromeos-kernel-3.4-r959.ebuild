# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="10e1a283e7f74642e74443710cf0ed528cc197db"
CROS_WORKON_TREE="de1efd48dd05d88b518d0af3a48485f151a19cf9"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
CROS_WORKON_LOCALNAME="../third_party/kernel/files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel"
KEYWORDS="amd64 arm x86"

DEPEND="!sys-kernel/chromeos-kernel-next"
RDEPEND="!sys-kernel/chromeos-kernel-next"

