# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d759928b27f4623305ad05f89802b7800d5092fd"
CROS_WORKON_TREE="3fa02294d1a551d67e2919de98e34c31b29da586"
CROS_WORKON_LOCALNAME="../platform/chromiumos-wide-profiling"
CROS_WORKON_PROJECT="chromiumos/platform/chromiumos-wide-profiling"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Program used to collect performance data on ChromeOS machines"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

COMMON_DEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	dev-libs/openssl
	dev-libs/protobuf"
RDEPEND="${COMMON_DEPEND}
	virtual/perf"
DEPEND="${COMMON_DEPEND}
	test? ( dev-cpp/gtest )"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	cros-workon_src_test
}

src_install() {
	dobin quipper
}
