# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a0e169021a583e621ca36f6563d97636f914f243"
CROS_WORKON_TREE="5d6af22fb97c6aaa60b845684c5b2118decb6fb0"

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

