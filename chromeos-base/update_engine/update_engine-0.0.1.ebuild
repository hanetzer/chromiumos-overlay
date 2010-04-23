# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Update Engine."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"

RDEPEND="app-arch/bzip2
         chromeos-base/libchrome
         dev-cpp/gflags
         dev-cpp/glog
         dev-libs/libpcre
         dev-libs/protobuf
         dev-util/bsdiff
         sys-libs/zlib"
DEPEND="dev-cpp/gtest
        dev-util/lcov
        net-misc/wget
        sys-apps/fakeroot
        ${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform dir: $platform"
	mkdir -p "${S}/update_engine"

	ls -l "${S}/update_engine"

	cp -a "${platform}"/update_engine/* "${S}/update_engine" || die

	cp -a "${platform}"/../common/chromeos "${S}" || die
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
	export CCFLAGS="$CFLAGS"

	pushd "update_engine"
	scons ${MAKEOPTS} \
		update_engine \
		delta_generator \
		|| die "update_engine compile failed"
	popd
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM
	export CCFLAGS="$CFLAGS"

	pushd "update_engine"
	scons debug=1 \
		update_engine_unittests \
		test_http_server \
		|| die "failed to build tests"
	popd

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		LIB_PATH="${SYSROOT}/usr/lib:${SYSROOT}/lib"
		LIBC_PATH="${SYSROOT}/usr/lib/gcc/${CHOST}/"$(gcc-fullversion)
		X11_PATH="${SYSROOT}/usr/lib/opengl/xorg-x11/lib"
		pushd "update_engine"
		for test in *_unittests; do
			LD_LIBRARY_PATH="$LIB_PATH:$LIBC_PATH:$X11_PATH" \
				"${SYSROOT}/lib/ld-linux.so.2" "$test" \
				--gtest_filter='-*.RunAsRoot*:*.Fakeroot*' \
				|| die "$test failed"
		done
		popd
	fi
}

src_install() {
	dodir /usr/bin
	exeinto /usr/bin

	doexe "${S}/update_engine/update_engine"
}
