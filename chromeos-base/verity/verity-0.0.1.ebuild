# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="~amd64 ~x86 ~arm"

if [[ ${PV} != "9999" ]] ; then
	inherit git

	KEYWORDS="amd64 x86 arm"

	EGIT_REPO_URI="http://src.chromium.org/git/dm-verity.git"
	EGIT_COMMIT="v${PV}"
fi

inherit toolchain-funcs

DESCRIPTION="File system integrity image generator for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test valgrind splitdebug"

RDEPEND="chromeos-base/libchrome
	 chromeos-base/libchromeos
	 dev-libs/openssl"

# qemu use isn't reflected as it is copied into the target
# from the build host environment.
DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	valgrind? ( dev-util/valgrind )"

src_unpack() {
	export SRC=${S}/verity
	if [[ -n "${EGIT_REPO_URI}" ]] ; then
		git_src_unpack
		mkdir -p ${S}/verity || die "failed to create verity subdir"
		mv -t ${S}/verity ${S}/* &>/dev/null
	else
		local platform="${CHROMEOS_ROOT}/src/platform"
		elog "Using platform: $platform"
		mkdir -p ${S}/verity
		cp -pr ${platform}/verity/* ${S}/verity
	fi
}

src_compile() {
	tc-export CXX
	tc-export CC
	tc-export OBJCOPY
	tc-export STRIP
	emake -C $SRC OUT=${S}/build \
		SPLITDEBUG=$(use splitdebug && echo 1) verity || \
		die "failed to make verity"
}

src_test() {
	tc-export CXX
	tc-export CC
	tc-export OBJCOPY
	tc-export STRIP
	# TODO(wad) add a verbose use flag to change the MODE=
	emake -C ${SRC} \
		OUT=${S}/build \
		VALGRIND=$(use valgrind && echo 1) \
		MODE=opt \
		SPLITDEBUG=0 \
		tests || die "unit tests (with ${GTEST_ARGS}) failed!"
}

src_install() {
	# TODO: copy splitdebug output somewhere
	into /
	dobin "${S}/build/verity"
}
