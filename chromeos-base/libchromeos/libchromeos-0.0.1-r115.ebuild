# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a8d2b777a4600203d377fca0050127ca126e018b"
CROS_WORKON_PROJECT="chromiumos/platform/libchromeos"
CROS_WORKON_LOCALNAME="../common" # FIXME: HACK

LIBCHROME_VERS=( 85268 125070 )

inherit toolchain-funcs cros-debug cros-workon scons-utils

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host test"

LIBCHROME_DEPEND=$(
	printf \
		'chromeos-base/libchrome:%s[cros-debug=] ' \
		${LIBCHROME_VERS[@]}
)
RDEPEND="${LIBCHROME_DEPEND}
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/libpcre
	dev-libs/openssl
	dev-libs/protobuf"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	test? ( dev-cpp/gtest )
	cros_host? ( dev-util/scons )"

cr_scons() {
	local v=$1; shift
	BASE_VER=${v} escons -C ${v} -Y "${S}" "$@"
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	if ! grep -qs BASE_VER SConstruct ; then
		# XXX: older source tree; drop once it is updated
		cr_scons ${LIBCHROME_VERS[0]} \
			libchromeos.a libpolicy.a libpolicy.so
		return 0
	fi

	local v
	mkdir -p ${LIBCHROME_VERS[@]}
	for v in ${LIBCHROME_VERS[@]} ; do
		cr_scons ${v} libchromeos-${v}.{pc,so} libpolicy-${v}.so
	done
}

src_test() {
	local v

	if ! grep -qs BASE_VER SConstruct ; then
		# XXX: older source tree; drop once it is updated
		escons unittests libpolicy_unittest
		if ! use x86 && ! use amd64 ; then
			ewarn "Skipping unit tests on non-x86 platform"
		else
			./unittests || die "libchromeos failed"
			./libpolicy_unittest || die "libpolicy_unittest failed"
		fi
		return 0
	fi

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
	if ! grep -qs BASE_VER SConstruct ; then
		# XXX: older source tree; drop once it is updated

		dolib.a lib{chromeos,policy}.a
		dolib.so libpolicy.so

		insinto /usr/$(get_libdir)/pkgconfig
		doins *.pc
	else
		local v
		insinto /usr/$(get_libdir)/pkgconfig
		for v in ${LIBCHROME_VERS[@]} ; do
			dolib.so ${v}/lib{chromeos,policy}*-${v}.so
			doins ${v}/libchromeos-${v}.pc
		done

		# Transitional code: drop once everyone has migrated
		# to the SLOT-ed packages.
		v=${LIBCHROME_VERS[0]}
		dosym libchromeos-${v}.so /usr/$(get_libdir)/libchromeos.so
		dosym libchromeos-${v}.pc /usr/$(get_libdir)/pkgconfig/libchromeos.pc
		dosym libpolicy-${v}.so /usr/$(get_libdir)/libpolicy.so
		cat <<-EOF > libchromeos.pc
		Name: libchromeos
		Description: chromeos base library
		Version: 0
		Requires: libchrome-${v} libchromeos-${v}
		Libs: -lrt
		EOF
		doins libchromeos.pc
	fi

	insinto /usr/include/chromeos
	doins chromeos/*.h

	insinto /usr/include/chromeos/dbus
	doins chromeos/dbus/*.h

	insinto /usr/include/chromeos/glib
	doins chromeos/glib/*.h

	insinto /usr/include/policy
	doins chromeos/policy/*.h
}
