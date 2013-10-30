# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="056b0abc1273a6eebfd73060a1d0344ef02b8696"
CROS_WORKON_TREE="ac9a854d749150507eb20f14bbda339083f76b41"
CROS_WORKON_PROJECT="chromiumos/platform/update_engine"

inherit toolchain-funcs cros-debug cros-workon scons-utils

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="-asan -clang cros_host cros_p2p -delta_generator"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

COMMON_DEPEND="app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/metrics
	chromeos-base/platform2
	chromeos-base/verity
	cros_p2p? ( chromeos-base/p2p )
	dev-cpp/gflags
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/libpcre
	dev-libs/libxml2
	dev-libs/openssl
	dev-libs/protobuf
	dev-util/bsdiff
	net-misc/curl
	sys-apps/rootdev
	sys-fs/e2fsprogs
	sys-fs/udev"

DEPEND="chromeos-base/system_api
	dev-cpp/gmock
	dev-cpp/gtest
	cros_host? ( dev-util/scons )
	${COMMON_DEPEND}"

RDEPEND="chromeos-base/chromeos-installer
	${COMMON_DEPEND}"


src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	clang-setup-env
	export CCFLAGS="$CFLAGS"
	export BASE_VER=${LIBCHROME_VERS}

	escons
}

src_test() {
	UNITTESTS_BINARY=update_engine_unittests
	TARGETS="${UNITTESTS_BINARY} test_http_server delta_generator"
	escons ${TARGETS}

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		# We need to set PATH so that the `openssl` in the target
		# sysroot gets executed instead of the host one (which is
		# compiled differently). http://crosbug.com/27683
		if [ -n "${GTEST_ARGS}" ]; then
			sudo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" PATH="$SYSROOT/usr/bin:$PATH" \
				"$./{UNITTESTS_BINARY}" ${GTEST_ARGS} \
				info "./${UNITTESTS_BINARY} (root) succeeded" \
				|| die "./${UNITTESTS_BINARY} (root) failed, retval=$?"
		else
			PATH="$SYSROOT/usr/bin:$PATH" \
			"./${UNITTESTS_BINARY}" --gtest_filter='-*.RunAsRoot*' \
				&& einfo "./${UNITTESTS_BINARY} (unprivileged) succeeded" \
				|| die "./${UNITTESTS_BINARY} (unprivileged) failed, retval=$?"
			sudo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" PATH="$SYSROOT/usr/bin:$PATH" \
				"./${UNITTESTS_BINARY}" --gtest_filter='*.RunAsRoot*' \
				&& einfo "./${UNITTESTS_BINARY} (root) succeeded" \
				|| die "./${UNITTESTS_BINARY} (root) failed, retval=$?"
		fi
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
