# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="57ff27585fadb26f248e91fc4854287f746b7b2d"
CROS_WORKON_TREE="bb91caa1f47474a07e9867af8620c0a8db4a796a"

EAPI=4
CROS_WORKON_LOCALNAME="../platform/chromiumos-wide-profiling"
CROS_WORKON_PROJECT="chromiumos/platform/chromiumos-wide-profiling"

inherit cros-workon toolchain-funcs

DESCRIPTION="Program used to collect performance data on ChromeOS machines"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="dev-util/perf
	net-misc/curl
	sys-libs/zlib"
DEPEND="test? ( dev-cpp/gtest )
	net-misc/curl
	sys-libs/zlib"

src_configure() {
	tc-export CXX
}

src_test() {
	emake check
}

src_install() {
	dobin ${PN}.exe
}
