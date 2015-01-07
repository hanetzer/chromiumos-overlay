# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="3a8dd014a98b0fabbd707e96a7cb3c9ab8188e46"
CROS_WORKON_TREE="53e17640650c6c968fd518acee696680c33e0210"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-debug cros-workon eutils toolchain-funcs

DESCRIPTION="Chrome OS helper binary for restricting privs of services."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+seccomp test"

RDEPEND="sys-libs/libcap"
DEPEND="test? ( dev-cpp/gtest )
	test? ( dev-cpp/gmock )
	${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	S+="/minijail"
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# Only build the tools
	emake LIBDIR=$(get_libdir) USE_seccomp=$(usex seccomp)
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# TODO(wad) switch to common.mk to get qemu and valgrind coverage
	emake tests

	if use x86 || use amd64 ; then
		./libminijail_unittest || \
		    die "libminijail unit tests failed!"
		./syscall_filter_unittest || \
		    die "syscall filter unit tests failed!"
	fi
}

src_install() {
	into /
	dosbin minijail0
	dolib.so libminijail.so
	dolib.so libminijailpreload.so

	insinto /usr/include/chromeos
	doins libminijail.h
}
