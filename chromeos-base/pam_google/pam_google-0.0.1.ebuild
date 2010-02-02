# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

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

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	elog "Using platform: $platform"
	mkdir -p "${S}/pam_google"
	cp -a "${platform}/pam_google" "${S}" || die
}

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

	pushd pam_google
	scons || die "pam_google compile failed."
	popd
}

src_install() {
	mkdir -p "${D}/lib/security/" "${D}/etc/"
	cp -a "${S}/pam_google/libpam_google.so" \
	  "${D}/lib/security/pam_google.so"
	cp -a "${S}/pam_google/verisign_class3.pem" \
          "${D}/etc/login_trust_root.pem"
}
