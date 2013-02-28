# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="609a1a1a79bc50ec8d15af019ecdfd0813d5c1b5"
CROS_WORKON_TREE="442a732bb3466bc50f7e499c8e0e31429eb727e4"
CROS_WORKON_LOCALNAME="../platform/chromiumos-wide-profiling"
CROS_WORKON_PROJECT="chromiumos/platform/chromiumos-wide-profiling"

inherit cros-workon toolchain-funcs

DESCRIPTION="Program used to collect performance data on ChromeOS machines"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="virtual/perf
	dev-libs/openssl
	dev-libs/protobuf"
DEPEND="test? ( dev-cpp/gtest )
	dev-libs/openssl
	dev-libs/protobuf"

src_configure() {
	tc-export CXX
}

src_compile() {
	emake ${PN}
}

src_test() {
	emake check
}

src_install() {
	dobin ${PN}
}
