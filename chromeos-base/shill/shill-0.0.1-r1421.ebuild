# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="abb99ef706a8d6895c5137a5b42a0703fe3fec12"
CROS_WORKON_TREE="d239916fe7b4e34fa4d9f6759865280c27e7ae99"
CROS_WORKON_PROJECT="chromiumos/platform/shill"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
IUSE="-asan -clang +cellular gdmwimax platform2 test +tpm +vpn"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
REQUIRED_USE="asan? ( clang )"

RDEPEND="chromeos-base/bootstat
	tpm? ( chromeos-base/chaps )
	chromeos-base/chromeos-minijail
	cellular? ( chromeos-base/cromo )
	!<chromeos-base/flimflam-0.0.1-r530
	chromeos-base/libchrome:180609[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/metrics
	cellular? ( chromeos-base/mist )
	chromeos-base/platform2
	cellular? ( >=chromeos-base/mobile-providers-0.0.1-r12 )
	gdmwimax? ( chromeos-base/wimax_manager )
	vpn? ( chromeos-base/vpn-manager )
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	dev-libs/libnl:3
	dev-libs/nss
	dev-libs/protobuf
	cellular? ( net-dialup/ppp )
	vpn? ( net-dialup/ppp )
	net-dns/c-ares
	net-libs/libmnl
	net-libs/libnetfilter_queue
	net-libs/libnfnetlink
	net-misc/dhcpcd
	vpn? ( net-misc/openvpn )
	cellular? ( virtual/modemmanager )
	net-wireless/wpa_supplicant[dbus]"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest"

RDEPEND="!platform2? ( ${RDEPEND} )"
DEPEND="!platform2? ( ${DEPEND} )"

make_flags() {
	echo LIBDIR="/usr/$(get_libdir)"
	use cellular || echo SHILL_CELLULAR=0
	use gdmwimax || echo SHILL_WIMAX=0
	use vpn || echo SHILL_VPN=0
}

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

src_configure() {
	use platform2 && return 0

	cros-workon_src_configure
}

src_compile() {
	use platform2 && return 0

	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	clang-setup-env
	emake $(make_flags) shill shims
}

src_test() {
	use platform2 && return 0

	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	# Run tests if we're on x86
	if ! use x86 && ! use amd64 ; then
		echo Skipping tests on non-x86/amd64 platform...
	else
		# Build tests
		emake $(make_flags) shill_unittest

		for ut in shill ; do
			"${S}/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
	fi
}

src_install() {
	use platform2 && return 0

	dobin bin/ff_debug
	use cellular && dobin bin/mm_debug
	use cellular && dobin bin/set_apn
	use cellular && dobin bin/set_cellular_ppp
	dobin bin/set_arpgw
	dobin bin/shill_login_user
	dobin bin/shill_logout_user
	dobin bin/wpa_debug
	dobin shill
	# Netfilter queue helper is run directly from init, so install in sbin.
	dosbin build/shims/netfilter-queue-helper
	# Install Netfilter queue helper syscall filter policy file.
	insinto /usr/share/policy
	newins "shims/nfqueue-seccomp-${ARCH}.policy" nfqueue-seccomp.policy
	local shims_dir="/usr/$(get_libdir)/shill/shims"
	exeinto "${shims_dir}"
	doexe build/shims/net-diags-upload
	doexe build/shims/nss-get-cert
	doexe build/shims/crypto-util
	use vpn && doexe build/shims/openvpn-script
	use cellular && doexe build/shims/set-apn-helper
	use vpn && doexe build/shims/shill-pppd-plugin.so
	insinto "${shims_dir}"
	doins build/shims/wpa_supplicant.conf
	insinto /etc
	doins shims/nsswitch.conf
	dosym /var/run/shill/resolv.conf /etc/resolv.conf
	insinto /etc/dbus-1/system.d
	doins shims/org.chromium.flimflam.conf
	insinto /usr/share/shill
	use cellular && doins data/cellular_operator_info
	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.xml
}
