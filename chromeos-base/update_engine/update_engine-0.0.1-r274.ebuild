# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="0b4a6ffb20e83aea7e5616be07bebb2f09ac85da"
CROS_WORKON_TREE="22ae304e544719d1350ad06bddf21a23de150342"

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

LIBCHROME_VERS="125070"

RDEPEND="app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
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
	export BASE_VER=${LIBCHROME_VERS}

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
			"$test" --gtest_filter='-*.RunAsRoot*:*.Fakeroot*' \
                                || die "$test (fakeroot) failed, retval=$?"
			sudo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" PATH="$SYSROOT/usr/bin:$PATH" \
				"$test" --gtest_filter='*.RunAsRoot*' >& $T/log \
                                || die "$test (root) failed, retval=$?"
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
