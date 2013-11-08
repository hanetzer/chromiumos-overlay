# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/debugd"
CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS debugging service"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
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

RDEPEND="!platform2? ( ${RDEPEND} )"
DEPEND="!platform2? ( ${DEPEND} )"

src_prepare() {
	if use platform2; then
		printf '\n\n\n'
		ewarn "This package doesn't install anything with USE=platform2."
		ewarn "You want to use the new chromeos-base/platform2 package."
		printf '\n\n\n'
		return 0
	fi
	cros-workon_src_prepare
}

src_compile() {
	use platform2 && return 0

	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG OBJCOPY
	cros-debug-add-NDEBUG
	clang-setup-env
	emake BASE_VER=${LIBCHROME_VERS}
}

src_test() {
	use platform2 && return 0
	if ! use x86 && ! use amd64 ; then
		einfo Skipping unit tests on non-x86 platform
	else
		emake tests BASE_VER=${LIBCHROME_VERS}
	fi
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
