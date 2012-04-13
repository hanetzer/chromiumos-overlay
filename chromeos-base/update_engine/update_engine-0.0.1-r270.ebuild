# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a2dee1d3a7f13c91b6d4973dca477c5496e9cf53"
CROS_WORKON_TREE="81530d99f22c1c11bbe55216ba9ab88584f98c75"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/update_engine"

inherit toolchain-funcs cros-debug cros-workon scons-utils

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host -delta_generator"

RDEPEND="app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/libchrome:85268[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/metrics
	chromeos-base/vboot_reference
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
	sys-libs/e2fsprogs-libs"
DEPEND="dev-cpp/gmock
	dev-cpp/gtest
	dev-libs/dbus-glib
	cros_host? ( dev-util/scons )
	sys-fs/udev
	${RDEPEND}"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	escons
}

src_test() {
	TARGETS="update_engine_unittests test_http_server delta_generator"
	escons ${TARGETS}

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		local test
		for test in ./*_unittests; do
			# We need to set PATH so that the `openssl` in the target
			# sysroot gets executed instead of the host one (which is
			# compiled differently). http://crosbug.com/27683
			PATH="$SYSROOT/usr/bin:$PATH" \
			"$test" --gtest_filter='-*.RunAsRoot*:*.Fakeroot*' || die "$test failed"
			sudo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" PATH="$SYSROOT/usr/bin:$PATH" \
				"$test" --gtest_filter='*.RunAsRoot*' >& $T/log || die "$test failed"
		done
	fi
}

src_install() {
	dosbin update_engine
	dobin update_engine_client

	use delta_generator && dobin delta_generator

	insinto /usr/share/dbus-1/services
	doins org.chromium.UpdateEngine.service

	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	insinto /lib/udev/rules.d
	doins 99-gpio-dutflag.rules

	insinto /usr/include/chromeos/update_engine
	doins update_engine.dbusserver.h
	doins update_engine.dbusclient.h
}
