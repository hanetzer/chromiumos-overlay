# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="af697fc95e11a23646b951d1279f5928f936687c"
CROS_WORKON_TREE="1dc1d380533d7b5f451ed786d7f8e3f4c0aa42c4"
CROS_WORKON_PROJECT="chromiumos/platform/debugd"
CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS debugging service"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang platform2"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/chromeos-minijail
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/platform2
	chromeos-base/system_api
	dev-libs/dbus-c++
	dev-libs/glib:2
	dev-libs/libpcre
	net-libs/libpcap
	sys-apps/memtester
	sys-apps/smartmontools"
DEPEND="${RDEPEND}
	chromeos-base/shill
	sys-apps/dbus
	virtual/modemmanager"

src_compile() {
	use platform2 && return 0

	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG OBJCOPY
	cros-debug-add-NDEBUG
	clang-setup-env
	emake BASE_VER=${LIBCHROME_VERS}
}

src_test() {
	use platform2 && return 0
	emake tests BASE_VER=${LIBCHROME_VERS}
}

src_install() {
	use platform2 && return 0
	cd build-opt
	into /
	dosbin debugd
	dodir /debugd
	exeinto /usr/libexec/debugd/helpers
	doexe helpers/capture_packets
	doexe helpers/icmp
	doexe helpers/netif
	doexe helpers/modem_status
	doexe "${S}"/src/helpers/minijail-setuid-hack.sh
	doexe "${S}"/src/helpers/send_at_command.sh
	doexe "${S}"/src/helpers/systrace.sh
	doexe "${S}"/src/helpers/capture_utility.sh
	doexe helpers/network_status
	doexe helpers/wimax_status

	insinto /etc/dbus-1/system.d
	doins "${S}/share/org.chromium.debugd.conf"

	insinto /etc/init
	doins "${S}"/share/{debugd,trace_marker-test}.conf

	insinto /etc/perf_commands
	doins "${S}"/share/perf_commands/{arm,core,unknown}.txt
}

src_configure() {
	use platform2 && return 0
	cros-workon_src_configure
}
