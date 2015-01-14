# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="96d912518c158ef2c5dc608de9c0d420039788b3"
CROS_WORKON_TREE="f78b6a285a2edddd1c15af4f07863ae1870ad4bb"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="shill"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon platform udev user

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD-Google"
SLOT="0"
IUSE="+cellular +seccomp test +tpm +vpn wake_on_wifi wimax"
KEYWORDS="*"

RDEPEND="
	chromeos-base/bootstat
	tpm? ( chromeos-base/chaps )
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	chromeos-base/metrics
	wimax? ( chromeos-base/wimax_manager )
	dev-libs/dbus-c++
	dev-libs/libnl:3
	cellular? ( net-dialup/ppp )
	vpn? ( net-dialup/ppp )
	net-dns/c-ares
	net-firewall/iptables
	net-libs/libnetfilter_queue
	net-libs/libnfnetlink
	net-misc/dhcpcd
	sys-apps/rootdev
	vpn? ( net-misc/openvpn )
	net-wireless/wpa_supplicant[dbus]
	cellular? ( virtual/modemmanager )
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest"

pkg_preinst() {
	enewgroup "shill-crypto"
	enewuser "shill-crypto"
	enewgroup "nfqueue"
	enewuser "nfqueue"
}

src_install() {
	# Install libshill-net library.
	insinto "/usr/$(get_libdir)/pkgconfig"
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		./net/preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libshill-net-${v}.so"
		doins "${OUT}/lib/libshill-net-${v}.pc"
	done

	# Install header files from libshill-net.
	insinto /usr/include/shill/net
	doins net/*.h

	dobin bin/ff_debug

	if use cellular; then
		dobin bin/set_apn
		dobin bin/set_cellular_ppp
	fi

	dosbin bin/reload_network_device
	dobin bin/set_arpgw
	dobin bin/set_wake_on_lan
	dobin bin/shill_login_user
	dobin bin/shill_logout_user
	dobin bin/wpa_debug
	dobin "${OUT}"/shill

	# Netfilter queue helper is run directly from init, so install in sbin.
	dosbin "${OUT}"/netfilter-queue-helper
	dosbin init/netfilter-common

	# Install Netfilter queue helper syscall filter policy file.
	insinto /usr/share/policy
	use seccomp && newins shims/nfqueue-seccomp-${ARCH}.policy nfqueue-seccomp.policy

	local shims_dir=/usr/$(get_libdir)/shill/shims
	exeinto "${shims_dir}"
	doexe "${OUT}"/net-diags-upload
	doexe "${OUT}"/crypto-util

	if use vpn; then
		doexe "${OUT}"/openvpn-script
		newexe "${OUT}"/lib/libshill-pppd-plugin.so shill-pppd-plugin.so
	fi

	use cellular && doexe "${OUT}"/set-apn-helper

	sed \
		"s,@libdir@,/usr/$(get_libdir)", \
		shims/wpa_supplicant.conf.in \
		> "${D}/${shims_dir}/wpa_supplicant.conf"

	insinto /etc
	doins shims/nsswitch.conf
	dosym /var/run/shill/resolv.conf /etc/resolv.conf
	insinto /etc/dbus-1/system.d
	doins shims/org.chromium.flimflam.conf
	insinto /usr/share/shill
	use cellular && doins "${OUT}"/serviceproviders.pbf

	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.xml

	# Install init scripts
	insinto /etc/init
	doins init/*.conf

	udev_dorules udev/*.rules
}

platform_pkg_test() {
	platform_test "run" "${OUT}/shill_unittest"
}
