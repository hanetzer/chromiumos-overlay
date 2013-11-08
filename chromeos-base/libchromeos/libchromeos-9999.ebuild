# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/libchromeos"

LIBCHROME_VERS=( 180609 )

inherit toolchain-funcs cros-debug cros-workon scons-utils

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="cros_host platform2 test"

LIBCHROME_DEPEND=$(
	printf \
		'chromeos-base/libchrome:%s[cros-debug=] ' \
		${LIBCHROME_VERS[@]}
)
RDEPEND="${LIBCHROME_DEPEND}
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/openssl
	dev-libs/protobuf"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	test? ( dev-cpp/gtest )
	cros_host? ( dev-util/scons )"

RDEPEND="!platform2? ( ${RDEPEND} )"
DEPEND="!platform2? ( ${DEPEND} )"

cr_scons() {
	local v=$1; shift
	BASE_VER=${v} escons -C ${v} -Y "${S}" "$@"
}

src_prepare() {
	if use platform2; then
		printf '\n\n\n'
		ewarn "This package doesn't install anything with USE=platform2."
		ewarn "You want to use the new chromeos-base/platform2 package."
		printf '\n\n\n'
		return 0
	fi
	cros-workon_src_prepare
}

src_configure() {
	use platform2 && return 0
	cros-workon_src_configure
}

src_compile() {
	use platform2 && return 0

	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	local v
	mkdir -p ${LIBCHROME_VERS[@]}
	for v in ${LIBCHROME_VERS[@]} ; do
		cr_scons ${v} libchromeos-${v}.{pc,so} libpolicy-${v}.so
	done
}

src_test() {
	use platform2 && return 0

	local v
	for v in ${LIBCHROME_VERS[@]} ; do
		cr_scons ${v} unittests libpolicy_unittest
		if ! use x86 && ! use amd64 ; then
			ewarn "Skipping unit tests on non-x86 platform"
		else
			./${v}/unittests || die "libchromeos-${v} failed"
			./${v}/libpolicy_unittest || die "libpolicy_unittest-${v} failed"
		fi
	done
}

src_install() {
	use platform2 && return 0

	local v
	insinto /usr/$(get_libdir)/pkgconfig
	for v in ${LIBCHROME_VERS[@]} ; do
		dolib.so ${v}/lib{chromeos,policy}*-${v}.so
		doins ${v}/libchromeos-${v}.pc
	done

	insinto /usr/include/chromeos
	doins chromeos/*.h

	insinto /usr/include/chromeos/dbus
	doins chromeos/dbus/*.h

	insinto /usr/include/chromeos/glib
	doins chromeos/glib/*.h

	insinto /usr/include/policy
	doins chromeos/policy/*.h
}
