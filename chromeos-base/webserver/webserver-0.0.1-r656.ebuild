# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("f79c6ff380dfc82c301aa12816f0bda9a1d47a70" "14295827d0060eede467cc41b91d6bd17cc433dd")
CROS_WORKON_TREE=("6170a8927aafca5e644b27ff86083850b6545e3f" "ca810b92f6b646be95610638913f7d0a7040c42f")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/webservd")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/webservd")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/webserver")

PLATFORM_SUBDIR="webserver"

inherit cros-workon platform user

DESCRIPTION="HTTP sever interface library"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	chromeos-base/permission_broker
	net-libs/libmicrohttpd
	!chromeos-base/libwebserv
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
		libwebserv/preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libwebserv-${v}.so"
		doins "${OUT}/lib/libwebserv-${v}.pc"
	done

	# Install header files from libwebserv
	insinto /usr/include/libwebserv
	doins libwebserv/*.h

	# Install init scripts for webservd.
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
		webservd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
