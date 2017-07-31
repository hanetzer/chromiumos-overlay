# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("15e8e67a2b251d20823b8d95697c8e9939ab8c07" "1a8d3f4e25945ede4da3c629d2a6f1fcf76d0fdc")
CROS_WORKON_TREE=("18a5d541337acfc9612fab7fbd9e3a9d0567978f" "71b19f7b68caabeed557c2eb4fb92cbc49461c9e")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/shill")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/connectivity/shill")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/shill")
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="shill"

inherit cros-workon platform systemd udev user

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cellular dhcpv6 json_store kernel-3_8 kernel-3_10 pppoe +seccomp systemd +tpm +vpn wake_on_wifi +wifi wimax +wired_8021x"

# Sorted by the package we depend on. (Not by use flag!)
RDEPEND="
	chromeos-base/bootstat
	tpm? ( chromeos-base/chaps )
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/nsswitch
	wimax? ( chromeos-base/wimax_manager )
	dev-libs/dbus-c++
	cellular? ( net-dialup/ppp )
	pppoe? ( net-dialup/ppp )
	vpn? ( net-dialup/ppp )
	net-dns/c-ares
	net-firewall/iptables
	net-libs/libnetfilter_queue
	net-libs/libnfnetlink
	net-misc/dhcpcd
	dhcpv6? ( net-misc/dhcpcd[ipv6] )
	vpn? ( net-vpn/openvpn )
	wifi? ( net-wireless/wpa_supplicant[dbus] )
	wired_8021x? ( net-wireless/wpa_supplicant[dbus] )
	sys-apps/rootdev
	cellular? ( virtual/modemmanager )
	!kernel-3_10? ( !kernel-3_8? ( net-firewall/conntrack-tools ) )
"

DEPEND="${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/shill-client
	chromeos-base/power_manager-client
	chromeos-base/system_api"

pkg_preinst() {
	enewgroup "shill-crypto"
	enewuser "shill-crypto"
	enewgroup "nfqueue"
	enewuser "nfqueue"
}

get_dependent_services() {
	local dependent_services=()
	if use wifi || use wired_8021x; then
		dependent_services+=(wpasupplicant)
	fi
	if use systemd; then
		echo "network-services.service ${dependent_services[*]/%/.service }"
	else
		echo "started network-services " \
			"${dependent_services[*]/#/and started }"
	fi
}

load_cfg80211() {
	if use wifi; then
		echo "modprobe cfg80211"
	else
		echo true
	fi
}

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/connectivity/shill"
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
	dosbin bin/set_wifi_regulatory
	dobin bin/set_arpgw
	dobin bin/set_wake_on_lan
	dobin bin/shill_login_user
	dobin bin/shill_logout_user
	if use wifi || use wired_8021x; then
		dobin bin/wpa_debug
	fi
	dobin "${OUT}"/shill

	# Deprecated.  On Linux 3.12+ conntrackd is used instead.
	local netfilter_queue_helper=no
	if use kernel-3_8 || use kernel-3_10; then
		netfilter_queue_helper=yes
	fi

	if [[ "${netfilter_queue_helper}" == "yes" ]]; then
		# Netfilter queue helper is run directly from init, so install
		# in sbin.
		dosbin "${OUT}"/netfilter-queue-helper
		dosbin init/netfilter-common
	fi

	# Install Netfilter queue helper syscall filter policy file.
	insinto /usr/share/policy
	use seccomp && newins shims/nfqueue-seccomp-${ARCH}.policy nfqueue-seccomp.policy

	local shims_dir=/usr/$(get_libdir)/shill/shims
	exeinto "${shims_dir}"
	doexe "${OUT}"/crypto-util

	use vpn && doexe "${OUT}"/openvpn-script
	if use cellular || use pppoe || use vpn; then
		newexe "${OUT}"/lib/libshill-pppd-plugin.so shill-pppd-plugin.so
	fi

	use cellular && doexe "${OUT}"/set-apn-helper

	if use wifi || use wired_8021x; then
		sed \
			"s,@libdir@,/usr/$(get_libdir)", \
			shims/wpa_supplicant.conf.in \
			> "${D}/${shims_dir}/wpa_supplicant.conf"
	fi

	dosym /run/shill/resolv.conf /etc/resolv.conf
	insinto /etc/dbus-1/system.d
	doins shims/org.chromium.flimflam.conf

	if use cellular; then
		insinto /usr/share/shill
		doins "${OUT}"/serviceproviders.pbf
		insinto /usr/share/protofiles
		doins "${S}/mobile_operator_db/mobile_operator_db.proto"
	fi

	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.dbus-xml
	doins dbus_bindings/dbus-service-config.json

	# Replace template parameters inside init scripts
	local shill_name="shill.$(usex systemd service conf)"
	local network_services_name="network-services.$(usex systemd service conf)"
	sed \
		"s,@expected_started_services@,$(get_dependent_services)," \
		"init/${shill_name}.in" \
		> "${T}/${shill_name}"
	sed \
		"s,@load_cfg80211@,$(load_cfg80211)," \
		init/${network_services_name}.in \
		> "${T}/${network_services_name}"

	# Install init scripts
	if use systemd; then
		if [[ "${netfilter_queue_helper}" == "yes" ]]; then
			systemd_dounit init/netfilter-queue.service
			systemd_enable_service network.target \
				netfilter-queue.service
		fi
		systemd_dounit init/shill-start-user-session.service
		systemd_dounit init/shill-stop-user-session.service

		local dependent_services=$(get_dependent_services)
		systemd_dounit "${T}/shill.service"
		for dependent_service in ${dependent_services}; do
			systemd_enable_service "${dependent_service}" shill.service
		done
		systemd_enable_service shill.service network.target

		systemd_dounit "${T}/network-services.service"
		systemd_enable_service boot-services.target network-services.service
	else
		insinto /etc/init
		doins "${T}"/*.conf
		doins init/shill-start-user-session.conf \
			init/shill-stop-user-session.conf \
			init/shill_respawn.conf
		if [[ "${netfilter_queue_helper}" == "yes" ]]; then
			doins init/netfilter-queue.conf
		fi
	fi
	insinto /usr/share/cros/init
	doins init/*.sh

	udev_dorules udev/*.rules
}

platform_pkg_test() {
	platform_test "run" "${OUT}/shill_unittest"
}
