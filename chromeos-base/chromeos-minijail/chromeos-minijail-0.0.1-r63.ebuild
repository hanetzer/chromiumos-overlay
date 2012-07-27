# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=6135db98e6bed85a8940c4a3eac366d6e1b56776
CROS_WORKON_TREE="f6c44d024ca3c42560cee2ed582a8274df8d575b"

EAPI=2
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
	if use x86 || use amd64 ; then
		./libminijail_unittest  || \
		    die "unit tests failed!"
	fi

	emake syscall_filter_unittest || die "syscall_filter_unittest compile failed."
	if use x86 || use amd64 ; then
		./syscall_filter_unittest || \
		    die "syscall filter unit tests failed!"
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
