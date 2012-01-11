# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="d305cde314a6f3868b9832ab63d589f050cad42d"
CROS_WORKON_PROJECT="chromiumos/platform/libchromeos"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="cros_host test"

# TODO: Ideally this is only a build depend, but there is an ordering
# issue where we need to make sure that libchrome is built first.
RDEPEND="chromeos-base/libchrome
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/libpcre
	dev-libs/openssl
	dev-libs/protobuf"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	test? ( dev-cpp/gtest )
	cros_host? ( dev-util/scons )"

CROS_WORKON_LOCALNAME="../common" # FIXME: HACK

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"
	scons libchromeos.a || die "libchromeos.a compile failed."
	scons libpolicy.a libpolicy.so || die "libpolicy compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"
	scons unittests || die
	scons libpolicy_unittest || die
	if ! use x86; then
		echo Skipping unit tests on non-x86 platform
	else
		./unittests || die "libchromeos unittests failed."
		./libpolicy_unittest || die "libpolicy_unittest unittests failed."
	fi
}

src_install() {
	dolib.a lib{chromeos,policy}.a || die
	dolib.so libpolicy.so || die

	insinto /usr/include/chromeos
	doins chromeos/*.h || die

	insinto /usr/include/chromeos/dbus
	doins chromeos/dbus/*.h || die

	insinto /usr/include/chromeos/glib
	doins chromeos/glib/*.h || die

	insinto /usr/include/policy
	doins chromeos/policy/*.h || die

	insinto /usr/$(get_libdir)/pkgconfig
	doins *.pc || die
}
