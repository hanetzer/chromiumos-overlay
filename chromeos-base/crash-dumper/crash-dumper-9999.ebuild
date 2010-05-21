# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Build chromeos crash handler"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="test"

RDEPEND="chromeos-base/google-breakpad"
DEPEND="${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"

	elog "Using platform: $platform"
	mkdir -p "${S}/crash"
	cp -a "${platform}"/crash/* "${S}/crash" || die
} 

src_compile() {
	tc-export CXX PKG_CONFIG
	pushd "crash"
	emake libcrash.so || die "compile failed."
	popd
}

src_install() {
	into /usr
	dolib.so "${S}/crash/libcrash.so" || die
}
