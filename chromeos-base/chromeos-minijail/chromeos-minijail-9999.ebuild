# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS helper binary for restricting privs of services."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="test"

RDEPEND="sys-libs/libcap"
DEPEND="test? ( dev-cpp/gtest )
	test? ( dev-cpp/gmock )
	chromeos-base/libchrome
	chromeos-base/libchromeos
	${RDEPEND}"

CROS_WORKON_PROJECT="minijail"
CROS_WORKON_LOCALNAME=${CROS_WORKON_PROJECT}

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

	# Only build the tool
	scons minijail || die "minijail compile failed."
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

	# Only build the tests
	# TODO(wad) eclass-ify this.
	scons minijail_unittests ||
		die "minijail_unittests compile failed."
}

src_install() {
        into /
        dosbin "${S}/minijail/minijail"
}
