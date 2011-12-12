# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="5ba42b5a35bc79ac455107008f2189fa26228789"
CROS_WORKON_PROJECT="chromiumos/platform/minijail"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS helper binary for restricting privs of services."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

RDEPEND="sys-libs/libcap"
DEPEND="test? ( dev-cpp/gtest )
	test? ( dev-cpp/gmock )
	chromeos-base/libchrome
	chromeos-base/libchromeos
	${RDEPEND}"

CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# Only build the tools
	emake LIBDIR=$(get_libdir) || die
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# TODO(wad) switch to common.mk to get qemu and valgrind coverage
	emake libminijail_unittest || die "libminijail_unittest compile failed."
	if use x86 ; then
		./libminijail_unittest  || \
		    die "unit tests failed!"
	fi
}

src_install() {
	into /
	dosbin minijail0 || die
	dolib.so libminijail.so || die
	dolib.so libminijailpreload.so || die
	insinto /usr/include/chromeos
	doins libminijail.h || die
}
