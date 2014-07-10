# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("16492f8e5d3fb18afc85c3542c9ab2768a94fd4d" "593b034869b10e8b48df0f1cb175eac9531c046d" "ab5da99378c96719bd7eaf8a2572c1e2715a2a6a" "c27ea0405210a6005450e4378de41a74a6c6ad0b" "0f20a12432b8537c24d053c2c56f64296b233469")
CROS_WORKON_TREE=("659f53d86e9e3c49f0b1ff6d13437e1f956dde21" "379d1ff558a4096f202c26440ba9ba944ae6e82f" "720027bf11968930fb77843e24d285594b332fac" "d4fb7d788822c8ab51317fa0c548bc79ffce352a" "c6640b28ad41f391e42df1292f9859d8dca43c2c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1

OLD_PLATFORM_LOCALNAME=(
	"chaps"
	"chromiumos-wide-profiling"
	"lorgnette"
	"power_manager"
)
NEW_PLATFORM2_LOCALNAME=(
	"attestation"
	"buffet"
	"crash-reporter"
	"cromo"
	"cros-disks"
	"debugd"
	"mist"
	"shill"
	"vpn-manager"
	"wimax_manager"
)
CROS_WORKON_LOCALNAME=(
	"${OLD_PLATFORM_LOCALNAME[@]/#/platform/}"
	"platform2"  # With all platform2 subdirs
)
CROS_WORKON_PROJECT=(
	"${OLD_PLATFORM_LOCALNAME[@]/#/chromiumos/platform/}"
	"chromiumos/platform2"
)
CROS_WORKON_DESTDIR=(
	"${OLD_PLATFORM_LOCALNAME[@]/#/${S}/platform/}"
	"${S}/platform2"
)
PLATFORM_SUBDIR="common-mk"
PLATFORM_TOOLDIR="${S}/platform2/common-mk"

inherit cros-board cros-debug cros-workon eutils multilib platform toolchain-funcs udev user

DESCRIPTION="Platform2 for Chromium OS: a GYP-based incremental build system"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -attestation buffet +cellular +crash_reporting -clang +cros_disks cros_embedded +debugd cros_host gdmwimax lorgnette +power_management +profile platform2 +seccomp +shill tcmalloc test +tpm +vpn wimax"
IUSE_POWER_MANAGER="-als +display_backlight -has_keyboard_backlight -legacy_power_button -lockvt -mosys_eventlog"
IUSE+=" ${IUSE_POWER_MANAGER}"
REQUIRED_USE="
	asan? ( clang )
	cellular? ( shill )
	debugd? ( shill )
	gdmwimax? ( wimax )
"

RDEPEND_chaps="
	tpm? (
		app-crypt/trousers
		dev-libs/dbus-c++
		dev-libs/openssl
		dev-libs/protobuf
	)
"

RDEPEND_crash_reporter="
	crash_reporting? (
		chromeos-base/google-breakpad
		chromeos-base/chromeos-ca-certificates
		!<chromeos-base/chromeos-init-0.0.25
		>=dev-cpp/gflags-2.0
		dev-libs/libpcre
		net-misc/curl
	)
"

RDEPEND_cromo="
	cellular? (
		dev-libs/dbus-c++
		virtual/modemmanager
	)
	!<chromeos-base/chromeos-init-0.0.9
"

RDEPEND_cros_disks="
	cros_disks? (
		app-arch/unrar
		dev-libs/dbus-c++
		sys-apps/rootdev
		sys-apps/util-linux
		sys-fs/avfs
		sys-fs/dosfstools
		sys-fs/exfat-utils
		sys-fs/fuse-exfat
		sys-fs/ntfs3g
		sys-fs/udev
	)
"

RDEPEND_debugd="
	debugd? (
		dev-libs/dbus-c++
		dev-libs/libpcre
		net-libs/libpcap
		sys-apps/memtester
		sys-apps/smartmontools
	)
"

RDEPEND_lorgnette="
	lorgnette? (
		chromeos-base/chromeos-minijail
		dev-libs/dbus-c++
		media-gfx/sane-backends
		media-libs/libpng[pnm2png]
	)
"

RDEPEND_mist="
	cellular? (
		dev-libs/libusb
		dev-libs/protobuf
		net-dialup/ppp
		sys-fs/udev
	)
"

RDEPEND_power_manager="
	power_management? (
		!<chromeos-base/chromeos-init-0.0.11
		>=dev-cpp/gflags-2.0
		dev-cpp/glog
		dev-libs/protobuf
		media-sound/adhd
		sys-fs/udev
	)
"

RDEPEND_quipper="
	profile? (
		dev-util/perf
	)
"

RDEPEND_shill="
	shill? (
		chromeos-base/bootstat
		chromeos-base/chromeos-minijail
		!<chromeos-base/flimflam-0.0.1-r530
		!<chromeos-base/chromeos-init-0.0.4
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
	)
"

RDEPEND_vpn_manager="
	vpn? (
		>=dev-cpp/gflags-2.0
		net-dialup/ppp
		net-dialup/xl2tpd
		net-misc/strongswan
	)
"

RDEPEND_wimax_manager="
	wimax? (
		dev-libs/dbus-c++
		dev-libs/protobuf
	)
	gdmwimax? ( virtual/gdmwimax )
"

DEPEND_chaps="tpm? ( dev-db/leveldb )"

DEPEND_crash_reporter="crash_reporting? ( sys-devel/flex )"

RDEPEND="
	platform2? (
		!cros_host? ( $(for v in ${!RDEPEND_*}; do echo "${!v}"; done) )

		${LIBCHROME_DEPEND}
		chromeos-base/chromeos-minijail
		>=dev-libs/glib-2.30
		tcmalloc? ( dev-util/google-perftools )
		sys-apps/dbus
		!chromeos-base/chaps[-platform2]
		!chromeos-base/crash-reporter
		!chromeos-base/cromo[-platform2]
		!chromeos-base/cros-disks[-platform2]
		!chromeos-base/chromeos-debugd[-platform2]
		chromeos-base/libchromeos
		chromeos-base/metrics
		!chromeos-base/mist[-platform2]
		!chromeos-base/power_manager
		!chromeos-base/shill[-platform2]
		chromeos-base/system_api
		!chromeos-base/vpn-manager[-platform2]
		!chromeos-base/wimax_manager[-platform2]
		!dev-util/quipper
	)
"

# The gtest dep is required even when USE=-test because of the gtest_prod.h
# header.  Non-test code is allowed to include that.  http://crbug.com/359322
DEPEND="${RDEPEND}
	platform2? (
		!cros_host? (
			$(for v in ${!DEPEND_*}; do echo "${!v}"; done)
		)
		chromeos-base/protofiles
		test? (
			app-shells/dash
			dev-cpp/gmock
		)
		dev-cpp/gtest
	)
"

#
# Platform2 common helper functions
#

platform2_multiplex() {
	# Runs a step (ie platform2_{test,install}) for a given subdir.
	# Sets up two variables to be used by the step:
	#   OUT = the build output directory, contains binaries/libs
	#   SRC = the path to subdir we're running the step for

	local SRC
	local phase="$1"
	local OUT="$(cros-workon_get_build_dir)/out/Default"
	local multiplex_names=(
		"${OLD_PLATFORM_LOCALNAME[@]/#/${S}/platform/}"
		"${NEW_PLATFORM2_LOCALNAME[@]/#/${S}/platform2/}"
	)
	for SRC in "${multiplex_names[@]}"; do
		pushd "${SRC}" >/dev/null

		# Subshell so that funcs that change the env (like `into` and
		# `insinto`) don't affect the next pkg.
		local pkg="${SRC##*/}"
		( "platform2_${phase}_${pkg}" ) || die

		popd >/dev/null
	done
}

#
# These are all the repo-specific install functions.
# Keep them sorted by name!
#

platform2_install_attestation() {
	use attestation || return 0
	use cros_host && return 0

	insinto /etc/dbus-1/system.d
	doins server/org.chromium.Attestation.conf

	insinto /etc/init
	doins server/attestationd.conf

	insinto /usr
	dosbin "${OUT}"/attestationd
	dobin "${OUT}"/attestation

	insinto /usr/share/policy
	newins server/attestationd-seccomp-${ARCH}.policy attestationd-seccomp.policy
}

platform2_install_buffet() {
	use cros_host && return 0
	use buffet || return 0

	dobin "${OUT}"/buffet
	dobin "${OUT}"/buffet_client

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Buffet.conf

	# Upstart script.
	insinto /etc/init
	doins buffet.conf
}

platform2_install_chaps() {
	use tpm || return 0
	use cros_host && return 0

	dosbin "${OUT}"/chapsd
	dobin "${OUT}"/chaps_client
	dobin "${OUT}"/p11_replay
	dolib.so "${OUT}"/lib/libchaps.so

	# Install D-Bus config file.
	dodir /etc/dbus-1/system.d
	sed 's,@POLICY_PERMISSIONS@,group="pkcs11",' \
		"org.chromium.Chaps.conf.in" \
		> "${D}/etc/dbus-1/system.d/org.chromium.Chaps.conf"

	# Install upstart config file.
	insinto /etc/init
	doins chapsd.conf

	# Install headers for use by clients.
	insinto /usr/include/chaps
	doins token_manager_client.h
	doins token_manager_client_mock.h
	doins token_manager_interface.h
	doins isolate.h
	doins chaps_proxy_mock.h
	doins chaps_interface.h
	doins chaps.h
	doins attributes.h

	insinto /usr/include/chaps/pkcs11
	doins pkcs11/*.h
}

platform2_install_chromiumos-wide-profiling() {
	use cros_host && return 0
	use profile || return 0
	dobin "${OUT}"/quipper
}

platform2_install_crash-reporter() {
	use cros_host && return 0
	use crash_reporting || return 0

	into /
	dosbin "${OUT}"/crash_reporter
	dosbin crash_sender

	into /usr
	dobin "${OUT}"/list_proxies
	dobin "${OUT}"/warn_collector
	dosbin kernel_log_collector.sh

	insinto /etc/init
	doins init/crash-reporter.conf init/crash-sender.conf
	use cros_embedded || doins init/warn-collector.conf

	insinto /etc
	doins crash_reporter_logs.conf

	udev_dorules 99-crash-reporter.rules
}

platform2_install_cromo() {
	use cros_host && return 0
	use cellular || return 0

	dosbin "${OUT}"/cromo
	dolib.so "${OUT}"/libcromo.a

	dobin mm-cromo-command

	insinto /etc/dbus-1/system.d
	doins org.chromium.ModemManager.conf

	insinto /usr/include/cromo
	doins modem_handler.h cromo_server.h plugin.h \
		hooktable.h carrier.h utilities.h modem.h \
		sms_message.h sms_cache.h

	insinto /usr/include/cromo/dbus_adaptors
	doins "${OUT}"/gen/include/dbus_adaptors/mm-{mobile,serial}-error.h
	doins "${OUT}"/gen/include/dbus_adaptors/org.freedesktop.ModemManager.*.h
	doins "${OUT}"/gen/include/cromo/dbus_adaptors/org.freedesktop.DBus.Properties.h

	dodir /usr/$(get_libdir)/cromo/plugins

	insinto /etc/init
	doins init/cromo.conf
}

platform2_install_cros-disks() {
	use cros_disks || return 0
	use cros_host && return 0

	exeinto /opt/google/cros-disks
	doexe "${OUT}"/disks

	# Install USB device IDs file.
	insinto /opt/google/cros-disks
	doins usb-device-info

	# Install seccomp policy file.
	use seccomp && newins avfsd-seccomp-${ARCH}.policy avfsd-seccomp.policy

	# Install upstart config file.
	insinto /etc/init
	doins cros-disks.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.CrosDisks.conf
}

platform2_install_debugd() {
	use debugd || return 0
	use cros_host && return 0

	into /
	dosbin "${OUT}"/debugd
	dodir /debugd

	exeinto /usr/libexec/debugd/helpers
	doexe "${OUT}"/{capture_packets,icmp,netif,network_status}
	use cellular && doexe "${OUT}"/modem_status
	use wimax && doexe "${OUT}"/wimax_status

	doexe src/helpers/{minijail-setuid-hack,systrace,capture_utility}.sh
	use cellular && doexe src/helpers/send_at_command.sh

	insinto /etc/dbus-1/system.d
	doins share/org.chromium.debugd.conf

	insinto /etc/init
	doins share/{debugd,trace_marker-test}.conf

	insinto /etc/perf_commands
	doins share/perf_commands/{arm,core,unknown}.txt
}

platform2_install_lorgnette() {
	use lorgnette || return 0
	dobin "${OUT}"/lorgnette
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.lorgnette.conf
	insinto /usr/share/dbus-1/system-services
	doins dbus_service/org.chromium.lorgnette.service
}

platform2_install_mist() {
	use cros_host && return 0
	use cellular || return 0;

	dobin "${OUT}"/mist

	insinto /usr/share/mist
	doins default.conf

	udev_dorules 51-mist.rules
}

platform2_install_power_manager() {
	use power_management || return 0
	use cros_host && return 0

	# Built binaries
	dobin "${OUT}"/powerd
	dobin "${OUT}"/powerd_setuid_helper
	dobin "${OUT}"/backlight_dbus_tool
	dobin "${OUT}"/backlight_tool
	dobin "${OUT}"/get_powerd_initial_backlight_level
	dobin "${OUT}"/memory_suspend_test
	dobin "${OUT}"/powerd_dbus_suspend
	dobin "${OUT}"/power_supply_info
	dobin "${OUT}"/set_power_policy
	dobin "${OUT}"/suspend_delay_sample

	fowners root:power /usr/bin/powerd_setuid_helper
	fperms 4750 /usr/bin/powerd_setuid_helper

	# Scripts
	dobin powerd/powerd_suspend
	dobin tools/activate_short_dark_resume
	dobin tools/debug_sleep_quickly
	dobin tools/send_metrics_on_resume
	dobin tools/set_short_powerd_timeouts
	dobin tools/suspend_stress_test

	# Preferences
	insinto /usr/share/power_manager
	doins default_prefs/*
	use als && doins optional_prefs/has_ambient_light_sensor
	use display_backlight || doins optional_prefs/external_display_only
	use has_keyboard_backlight && doins optional_prefs/has_keyboard_backlight
	use legacy_power_button && doins optional_prefs/legacy_power_button
	use lockvt && doins optional_prefs/lock_vt_before_suspend
	use mosys_eventlog && doins optional_prefs/mosys_eventlog

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PowerManager.conf

	exeinto "$(udev_get_udevdir)"
	doexe udev/*.sh

	udev_dorules udev/*.rules

	insinto /etc/init
	doins init/*.conf
}

platform2_install_shill() {
	use shill || return 0
	use cros_host && return 0

	dobin bin/ff_debug

	if use cellular; then
		dobin bin/set_apn
		dobin bin/set_cellular_ppp
	fi

	dosbin bin/reload_network_device
	dobin bin/set_arpgw
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
	use cellular && doins data/cellular_operator_info
	use cellular && doins "${OUT}"/serviceproviders.pbf

	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.xml

	# Install init scripts
	insinto /etc/init
	doins init/*.conf

	udev_dorules udev/*.rules
}

platform2_install_vpn-manager() {
	use cros_host && return 0
	use vpn || return 0

	insinto /usr/include/chromeos/vpn-manager
	doins service_error.h
	dosbin "${OUT}"/l2tpipsec_vpn
	exeinto /usr/libexec/l2tpipsec_vpn
	doexe bin/pluto_updown
}

platform2_install_wimax_manager() {
	use cros_host && return 0
	use wimax || return 0

	# Install D-Bus introspection XML files.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.WiMaxManager*.xml

	# Skip the rest of the files unless USE=gdmwimax is specified.
	use gdmwimax || return 0

	# Install daemon executable.
	dosbin "${OUT}"/wimax-manager

	# Install WiMAX Manager default config file.
	insinto /usr/share/wimax-manager
	doins default.conf

	# Install upstart config file.
	insinto /etc/init
	doins wimax_manager.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins dbus_bindings/org.chromium.WiMaxManager.conf
}

#
# These are all the repo-specific test functions.
# Keep them sorted by name!
#

platform2_test_attestation() {
	return 0
}

platform2_test_buffet() {
	use buffet || return 0
	platform_test "run" "${OUT}/buffet_testrunner"
}

platform2_test_chaps() {
	use tpm || return 0
	use cros_host && return 0

	local tests=(
		chaps_test
		chaps_service_test
		slot_manager_test
		session_test
		object_test
		object_policy_test
		object_pool_test
		object_store_test
		opencryptoki_importer_test
		isolate_login_client_test
	)

	local gtest_filter_qemu=""
	gtest_filter_qemu+="-*DeathTest*"
	gtest_filter_qemu+=":*ImportSample*"
	gtest_filter_qemu+=":TestSession.RSA*"
	gtest_filter_qemu+=":TestSession.KeyTypeMismatch"
	gtest_filter_qemu+=":TestSession.KeyFunctionPermission"
	gtest_filter_qemu+=":TestSession.BadKeySize"
	gtest_filter_qemu+=":TestSession.BadSignature.*"

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "" "${gtest_filter_qemu}"
	done
}

platform2_test_chromiumos-wide-profiling() {
	use cros_host && return 0
	use profile || return 0

	local tests=(
		address_mapper_test
		utils_test
	)
	# These tests don't work quite right when there is a mismatch between
	# the active running kernel and the test target (bitwise).
	# Also, below tests are temporarily disabled, see crbug.com/340543
	use amd64 && tests+=(
		perf_parser_test
		perf_reader_test
		perf_recorder_test
		perf_serializer_test
	)
	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "1"
	done
}

platform2_test_crash-reporter() {
	use cros_host && return 0
	use crash_reporting || return 0

	# TODO(mkrebs): The tests are not currently thread-safe, so
	# running them in the default parallel mode results in
	# failures.
	local tests=(
		chrome_collector_test
		crash_collector_test
		kernel_collector_test
		udev_collector_test
		unclean_shutdown_collector_test
		user_collector_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_cromo() {
	use cros_host && return 0
	use cellular || return 0

	local tests=(
		sms_message_unittest
		sms_cache_unittest
		utilities_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_cros-disks() {
	use cros_disks || return 0
	use cros_host && return 0

	local gtest_filter_qemu_common=""
	gtest_filter_qemu_common+="DiskManagerTest.*"
	gtest_filter_qemu_common+=":ExternalMounterTest.*"
	gtest_filter_qemu_common+=":UdevDeviceTest.*"
	gtest_filter_qemu_common+=":MountInfoTest.RetrieveFromCurrentProcess"
	gtest_filter_qemu_common+=":GlibProcessTest.*"

	local gtest_filter_user_tests="-*.RunAsRoot*:"
	use arm && gtest_filter_user_tests+="${gtest_filter_qemu_common}"

	local gtest_filter_root_tests="*.RunAsRoot*-"
	use arm && gtest_filter_root_tests+="${gtest_filter_qemu_common}"

	platform_test "run" "${OUT}/disks_testrunner" "1" \
		"${gtest_filter_root_tests}"
	platform_test "run" "${OUT}/disks_testrunner" "0" \
		"${gtest_filter_user_tests}"
}

platform2_test_debugd() {
	use cros_host && return 0
	use debugd || return 0
	! use x86 && ! use amd64 && ewarn "Skipping unittests for non-x86: debugd" && return 0

	pushd "${SRC}/src" >/dev/null
	platform_test "run" "${OUT}/debugd_testrunner"
	./helpers/capture_utility_test.sh || die
	popd >/dev/null
}

platform2_test_lorgnette() {
	use lorgnette || return 0
	! use x86 && ! use amd64 && ewarn "Skipping unittests for non-x86: lorgnette" && return 0
	platform_test "run" "${OUT}/lorgnette_unittest"
}

platform2_test_mist() {
	use cros_host && return 0
	use cellular || return 0;

	platform_test "run" "${OUT}/mist_testrunner"
}

platform2_test_power_manager() {
	use power_management || return 0
	use cros_host && return 0
	! use x86 && ! use amd64 && ewarn "Skipping unittests for non-x86: power_manager" && return 0
	local tests=(
		power_manager_daemon_test
		power_manager_policy_test
		power_manager_system_test
		power_manager_util_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_shill() {
	use cros_host && return 0
	use shill || return 0
	! use x86 && ! use amd64 && ewarn "Skipping unittests for non-x86: shill" && return 0

	platform_test "run" "${OUT}/shill_unittest"
}

platform2_test_vpn-manager() {
	use cros_host && return 0
	use vpn || return 0
	! use x86 && ! use amd64 && ewarn "Skipping unittests for non-x86: vpn-manager" && return 0

	local tests=(
		daemon_test
		ipsec_manager_test
		l2tp_manager_test
		service_manager_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_wimax_manager() {
	use cros_host && return 0
	use wimax || return 0
	use gdmwimax || return 0

	platform_test "run" "${OUT}/wimax_manager_testrunner"
}

#
# These are the ebuild <-> Platform2 glue functions.
#

pkg_setup() {
	# Create the 'power' user and group here in pkg_setup as
	# platform2_install_power_manager needs them to change the ownership
	# of power manager files.
	if use power_management; then
		enewuser "power"   # For power_manager
		enewgroup "power"  # For power_manager
	fi
	cros-workon_pkg_setup
}

src_unpack() {
	# If we don't create the source directory when Platform2 is disabled
	# prepare complains. Once Platform2 is default, this isn't needed.
	mkdir -p "${S}"

	use platform2 && cros-workon_src_unpack
}

src_configure() {
	if use platform2; then
		cros-debug-add-NDEBUG
		clang-setup-env
		platform_configure
	fi
}

src_compile() {
	use platform2 && platform "compile"
}

src_test() {
	use platform2 || return 0

	platform_test "pre_test"
	platform2_multiplex test
	platform_test "post_test"
}

src_install() {
	use platform2 && platform2_multiplex install
}

pkg_preinst() {
	# Create users and groups that are used by system daemons at runtime.
	# Users and groups, which are needed during build time, should be
	# created in pkg_setup instead.
	local ug

	if use cellular; then
		for ug in cromo qdlservice; do
			enewuser "${ug}"
			enewgroup "${ug}"
		done
	fi

	if use cros_disks; then
		for ug in cros-disks ntfs-3g avfs fuse-exfat; do
			enewuser "${ug}"
			enewgroup "${ug}"
		done
	fi

	if use debugd; then
		for ug in debugd debugd-logs debugfs-access; do
			enewuser "${ug}"
			enewgroup "${ug}"
		done
		enewgroup "daemon-store"
		enewgroup "logs-access"
	fi

	if use tpm; then
		for ug in attestation pkcs11 chaps; do
			enewuser "${ug}"
			enewgroup "${ug}"
		done
	fi

	if use shill; then
		enewgroup "shill-crypto"
		enewuser "shill-crypto"
		enewgroup "nfqueue"
		enewuser "nfqueue"
	fi
}
