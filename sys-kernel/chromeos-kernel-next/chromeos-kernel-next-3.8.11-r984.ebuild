# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="6fa1d9b846d1f2523753d73e64f8f8ddbff3e4a4"
CROS_WORKON_TREE="5939a251d19dbf229ae8087ce2e393e5ac13b1a5"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel-next"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

DEPEND="!sys-kernel/chromeos-kernel"
RDEPEND="!sys-kernel/chromeos-kernel"
