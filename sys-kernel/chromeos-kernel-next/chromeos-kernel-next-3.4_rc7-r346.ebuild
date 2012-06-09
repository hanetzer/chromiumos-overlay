# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="c6666a12926a9bbfb193ecdb0d6efe0e3fc73aeb"
CROS_WORKON_TREE="89291aa382976f468f6aca9f15ad0a188008f7db"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="../third_party/kernel-next/"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel-next"
KEYWORDS="amd64 arm x86"

DEPEND="!sys-kernel/chromeos-kernel"
RDEPEND="!sys-kernel/chromeos-kernel"
