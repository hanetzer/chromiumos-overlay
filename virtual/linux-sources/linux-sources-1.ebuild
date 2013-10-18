# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS Kernel virtual package"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="-kernel_next -kernel_sources"

RDEPEND="
	kernel_next? ( sys-kernel/chromeos-kernel-next[kernel_sources=] )
	!kernel_next? ( sys-kernel/chromeos-kernel[kernel_sources=] )
"
