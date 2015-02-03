# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="5e66aec8d9d6446ff5c64656be280dc99acf2ca0"
CROS_WORKON_TREE="a355f237a6c87b1af271eba307be5958092d4312"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="libwebserv"

inherit cros-workon platform user

DESCRIPTION="HTTP sever interface library"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	net-libs/libmicrohttpd
"

DEPEND="
	${RDEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

pkg_preinst() {
	# Create user and group for webservd.
	enewuser "webservd"
	enewgroup "webservd"
}

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		./preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libwebserv-${v}.so"
		doins "${OUT}/lib/libwebserv-${v}.pc"
	done

	# Install header files from libwebserv
	insinto /usr/include/libwebserv
	doins *.h

	# Install init scripts.
	insinto /etc/init
	doins webservd/etc/init/webservd.conf

	# Install DBus configuration files.
	insinto /etc/dbus-1/system.d
	doins webservd/etc/dbus-1/org.chromium.WebServer.conf

	# Install web server daemon.
	dobin "${OUT}"/webservd
}

platform_pkg_test() {
	local tests=(
		libwebserv_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
