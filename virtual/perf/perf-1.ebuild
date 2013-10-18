# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Chrome OS perf virtual package"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="kernel_next"

RDEPEND="
	kernel_next? ( dev-util/perf-next )
	!kernel_next? ( dev-util/perf )
"
