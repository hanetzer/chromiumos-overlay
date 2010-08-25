# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="b714c07e58dc1967e332eaf927a3b93e5a4acd3e"

inherit cros-workon toolchain-funcs

DESCRIPTION="TPM initialization functions"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

RDEPEND="
	app-crypt/trousers
	dev-libs/openssl
	"

DEPEND="
	test? ( dev-cpp/gtest )
	chromeos-base/libchromeos
	${RDEPEND}"

CROS_WORKON_PROJECT="tpm_init"
CROS_WORKON_LOCALNAME=${CROS_WORKON_PROJECT}

src_unpack() {
	cros-workon_src_unpack
	pushd "${S}"
	mkdir "${CROS_WORKON_PROJECT}"
	mv * "${CROS_WORKON_PROJECT}"
	popd
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export CCFLAGS="$CFLAGS"
	fi

	pushd tpm_init
	# Build the daemon and command line client
	scons || die "chromeos-tpm compile failed."
	popd
}

src_test() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export CCFLAGS="$CFLAGS"
	fi

	pushd tpm_init
	popd
}

src_install() {
	S="${S}/tpm_init"

	dosbin "${S}/chromeos-tpm-init"
	dolib "${S}/libtpm_init.a"

	insinto "/usr/include/tpm_init"
	doins "${S}/tpm_init.h"
}
