# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b79c74edff87b97a3231d51235bf0f6bae189781"
CROS_WORKON_TREE="167d02c1d34b7a7c890adfcb8f1c3b093d253b48"
CROS_WORKON_LOCALNAME="../platform/chromiumos-wide-profiling"
CROS_WORKON_PROJECT="chromiumos/platform/chromiumos-wide-profiling"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Program used to collect performance data on ChromeOS machines"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	virtual/perf
	dev-libs/openssl
	dev-libs/protobuf"
DEPEND="test? ( dev-cpp/gtest )
	dev-libs/openssl
	dev-libs/protobuf"

src_configure() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}
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
