# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="d2463c2e6571181f9b4b59fba3ecc24cfbd3a411"
CROS_WORKON_TREE="c2331c392c8ac4d1d008726c3c4c20275215d505"

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

