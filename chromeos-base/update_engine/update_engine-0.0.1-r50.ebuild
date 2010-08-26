# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="1cd885fe5569952adb97c23886b8d12b68257ba1"
inherit toolchain-funcs cros-workon

DESCRIPTION="Chrome OS Update Engine."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="app-arch/bzip2
	chromeos-base/libchrome
	chromeos-base/metrics
	chromeos-base/verity
	dev-cpp/gflags
	dev-libs/glib
	dev-libs/libpcre
	dev-libs/libxml2
	dev-libs/protobuf
	dev-util/bsdiff
	net-misc/curl
	sys-libs/zlib"
DEPEND="chromeos-base/libchromeos
	dev-cpp/gmock
	dev-cpp/gtest
	dev-libs/dbus-glib
	${RDEPEND}"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
	export CCFLAGS="$CFLAGS"

	scons ${MAKEOPTS} || die "update_engine compile failed"
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM
	export CCFLAGS="$CFLAGS"

	scons debug=1 \
		update_engine_unittests \
		test_http_server \
		|| die "failed to build tests"

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		LIB_PATH="${SYSROOT}/usr/lib:${SYSROOT}/lib"
		LIBC_PATH="${SYSROOT}/usr/lib/gcc/${CHOST}/"$(gcc-fullversion)
		X11_PATH="${SYSROOT}/usr/lib/opengl/xorg-x11/lib"
		for test in *_unittests; do
			LD_LIBRARY_PATH="$LIB_PATH:$LIBC_PATH:$X11_PATH" \
				"${SYSROOT}/lib/ld-linux.so.2" "$test" \
				--gtest_filter='-*.RunAsRoot*:*.Fakeroot*' \
				|| die "$test failed"
		done
	fi
}

src_install() {
	dosbin update_engine
	dobin update_engine_client

	insinto /usr/share/dbus-1/services
	doins org.chromium.UpdateEngine.service

	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	insinto /usr/include/chromeos/update_engine
	doins update_engine.dbusserver.h
	doins update_engine.dbusclient.h
}
