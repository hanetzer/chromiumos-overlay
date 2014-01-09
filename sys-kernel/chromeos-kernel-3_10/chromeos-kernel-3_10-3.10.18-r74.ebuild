# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5dbd56201ab943e2d2a6f1ebd8f96da4c37504d3"
CROS_WORKON_TREE="4df5752ef219764318c8e1d52963c593c4c0e549"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/3.10"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.10"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

DEPEND="!sys-kernel/chromeos-kernel-baytrail"
RDEPEND="${DEPEND}"
