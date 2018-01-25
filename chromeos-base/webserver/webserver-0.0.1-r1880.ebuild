# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="749b81edc3e3d6d6c0e7c4eabf0d57c36f9a5d12"
CROS_WORKON_TREE="cb1db95577b9301ad0ba70a312e09a65bf75841b"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="webserver"

inherit cros-workon platform user

DESCRIPTION="HTTP sever interface library"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/permission_broker
	net-libs/libmicrohttpd
	!chromeos-base/libwebserv
"

DEPEND="
	${RDEPEND}
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

        # Install seccomp filter for webservd.
        insinto /usr/share/filters
        doins webservd/usr/share/filters/webservd-seccomp.policy

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
