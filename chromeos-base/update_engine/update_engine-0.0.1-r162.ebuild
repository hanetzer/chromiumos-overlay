# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="10d02dd60d4c4f41f7f4ed92322fa7b597760118"
inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chrome OS Update Engine."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="-delta_generator"
KEYWORDS="amd64 arm x86"

RDEPEND="app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/cros_boot_mode
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
	sys-apps/rootdev
	sys-fs/e2fsprogs
	sys-libs/e2fsprogs-libs
	sys-libs/zlib"
DEPEND="chromeos-base/libchromeos
	dev-cpp/gmock
	dev-cpp/gtest
	dev-libs/dbus-glib
	${RDEPEND}"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	scons ${MAKEOPTS} || die "update_engine compile failed"
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	TARGETS="update_engine_unittests test_http_server"
	scons ${MAKEOPTS} ${TARGETS} || die "failed to build tests"

	if ! use x86 ; then
	  echo Skipping tests on non-x86 platform...
	else
	  for test in ./*_unittests; do
		"$test" --gtest_filter='-*.RunAsRoot*:*.Fakeroot*' || die "$test failed"
		sudo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" \
		  "$test" --gtest_filter='*.RunAsRoot*' || die "$test failed"
	  done
	fi
}

src_install() {
	dosbin update_engine
	dobin update_engine_client

	if use delta_generator; then
	  dobin delta_generator
	fi

	insinto /usr/share/dbus-1/services
	doins org.chromium.UpdateEngine.service

	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	insinto /usr/include/chromeos/update_engine
	doins update_engine.dbusserver.h
	doins update_engine.dbusclient.h
}
