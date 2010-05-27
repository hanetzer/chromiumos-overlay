# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

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

src_unpack() {
       local platform="${CHROMEOS_ROOT}/src/platform"
       elog "Using platform: $platform"
       mkdir -p "${S}/pam_offline"
       cp -a "${platform}/pam_offline" "${S}" || die
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

       pushd pam_offline
       scons || die "pam_offline compile failed."
       popd
}

src_install() {
       dodir /lib/security
       cp -a "${S}/pam_offline/libchromeos_pam_offline.so" \
         "${D}/lib/security/chromeos_pam_offline.so"
}
