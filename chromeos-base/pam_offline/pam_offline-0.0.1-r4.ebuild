# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="d26925c51b72d81c47bba5c0d9b042782254b6e3"

inherit cros-workon toolchain-funcs

DESCRIPTION="PAM module for offline login."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="chromeos-base/libcros
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/openssl
	sys-libs/pam"

DEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	${RDEPEND}"

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
	export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
	export CCFLAGS="$CFLAGS"
	fi

	scons || die "pam_offline compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM
	export CCFLAGS="$CFLAGS"

	scons pam_offline_unittests || die "Failed to build tests"

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		"${S}/pam_offline_unittests" ${GTEST_ARGS} || die "$test failed"
	fi
}

src_install() {
	dodir /lib/security
	cp -a "${S}/pam_offline/libchromeos_pam_offline.so" \
		"${D}/lib/security/chromeos_pam_offline.so"
}
