# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon toolchain-funcs

DESCRIPTION="PAM module for Google login."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="dev-cpp/gflags
	net-misc/curl
	sys-libs/pam"

DEPEND="chromeos-base/libchromeos
	dev-cpp/gtest
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
	scons || die "pam_google compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM
	export CCFLAGS="$CFLAGS"

	scons pam_google_unittests || die "Failed to build tests"

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		"${S}/pam_google_unittests" ${GTEST_ARGS} || die "$test failed"
	fi
}

src_install() {
	mkdir -p "${D}/lib/security/" "${D}/etc/"
	cp -a "${S}/libpam_google.so" \
	  "${D}/lib/security/pam_google.so" || die
	cp -a "${S}/verisign_class3.pem" \
          "${D}/etc/login_trust_root.pem" || die
	chown root:root "${D}/etc/login_trust_root.pem"
	chmod 0644 "${D}/etc/login_trust_root.pem"
}
