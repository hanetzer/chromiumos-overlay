# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="~amd64 ~x86 ~arm"

if [[ ${PV} != "9999" ]] ; then
	inherit git

	KEYWORDS="amd64 x86 arm"

	EGIT_REPO_URI="http://src.chromium.org/git/pam_google.git"
	EGIT_TREE="f1464cc3c3ab4d754a36ef03a5835fcb27e47369"
fi

inherit toolchain-funcs

DESCRIPTION="PAM module for Google login."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"

IUSE=""

RDEPEND="dev-cpp/gflags
	 net-misc/curl
         sys-libs/pam"

DEPEND="chromeos-base/libchromeos
	dev-cpp/gtest
	${RDEPEND}"

src_unpack() {
	if [[ -n "${EGIT_REPO_URI}" ]] ; then
		git_src_unpack
	else
		local platform="${CHROMEOS_ROOT}/src/platform"
		elog "Using platform: $platform"
		cp -a "${platform}/pam_google" "${S}" || die
	fi
}

src_prepare() {
	ln -sf "${S}" "${S}/../pam_google"
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

	scons || die "pam_google compile failed."
}

src_install() {
	mkdir -p "${D}/lib/security/" "${D}/etc/"
	cp -a "${S}/pam_google/libpam_google.so" \
	  "${D}/lib/security/pam_google.so"
	cp -a "${S}/pam_google/verisign_class3.pem" \
          "${D}/etc/login_trust_root.pem"
	chown root:root "${D}/etc/login_trust_root.pem"
	chmod 0644 "${D}/etc/login_trust_root.pem"
}
