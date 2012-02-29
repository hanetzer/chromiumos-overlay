# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d321685f41e05c8457a3eba6dfd9ca2240049463"
CROS_WORKON_PROJECT="chromiumos/platform/libchromeos"
CROS_WORKON_LOCALNAME="../common" # FIXME: HACK

inherit toolchain-funcs cros-debug cros-workon scons-utils

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host test"

# TODO: Ideally this is only a build depend, but there is an ordering
# issue where we need to make sure that libchrome is built first.
RDEPEND="chromeos-base/libchrome:0[cros-debug=]
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/libpcre
	dev-libs/openssl
	dev-libs/protobuf"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	test? ( dev-cpp/gtest )
	cros_host? ( dev-util/scons )"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"
	escons libchromeos.a libpolicy.a libpolicy.so
}

src_test() {
	escons unittests libpolicy_unittest
	if ! use x86 && ! use amd64 ; then
		ewarn "Skipping unit tests on non-x86 platform"
	else
		./unittests || die "libchromeos unittests failed."
		./libpolicy_unittest || die "libpolicy_unittest unittests failed."
	fi
}

src_install() {
	dolib.a lib{chromeos,policy}.a
	dolib.so libpolicy.so

	insinto /usr/include/chromeos
	doins chromeos/*.h

	insinto /usr/include/chromeos/dbus
	doins chromeos/dbus/*.h

	insinto /usr/include/chromeos/glib
	doins chromeos/glib/*.h

	insinto /usr/include/policy
	doins chromeos/policy/*.h

	insinto /usr/$(get_libdir)/pkgconfig
	doins *.pc
}
