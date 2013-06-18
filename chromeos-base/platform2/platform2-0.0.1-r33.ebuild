# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("300e00bf995e4c5ecae2d5a58301e2a40a0f4237" "5cc83e28f25353c6497f4addd41ad2051a9c9b18" "63f24c52a8fa7d4f54ce694cc5d256ffbb9776f0" "4f268f4f387a6c1d86c84cf474b9e83f8385a1f6" "e09dd19350d8a5773e00ae798c9f5f1c0280a3c7" "4c0e3dfeb981d780de2808b57389c11d00ece680")
CROS_WORKON_TREE=("2fd2d51bf3d84075fe84059b8e496d303ee9904e" "37cc3bd7d7f0fb3a0c610847a892be8f46921f4a" "445ac640715f55638ffa5f131385f1859b01e09a" "0eaed43df5e74f1d7e1140e5871274733c674c3d" "084239ba2466156b1d254febd525a7df7e3ddf04" "44aba3b1181a4bea1bc2f2af63dd09bed7e98fc1")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=(
	"common-mk"
	"cros-disks"
	"debugd"
	"libchromeos"
	"metrics"
	"system_api"
)
CROS_WORKON_PROJECT=("${CROS_WORKON_LOCALNAME[@]/#/chromiumos/platform/}")
CROS_WORKON_DESTDIR=("${CROS_WORKON_LOCALNAME[@]/#/${S}/}")

inherit cros-board cros-debug cros-workon eutils

DESCRIPTION="Platform2 for Chromium OS: a GYP-based incremental build system"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host gdmwimax +incremental platform2 test"

LIBCHROME_VERS=( 180609 )

LIBCHROME_DEPEND=$(
	printf \
		'chromeos-base/libchrome:%s[cros-debug=] ' \
		${LIBCHROME_VERS[@]}
)

RDEPEND_cros_disks="
	!cros_host? (
		app-arch/unrar
		sys-apps/util-linux
		sys-block/parted
		sys-fs/avfs
		sys-fs/exfat-utils
		sys-fs/fuse-exfat
		sys-fs/ntfs3g
		sys-fs/udev
	)
"

RDEPEND_debugd="
	!cros_host? (
		dev-libs/libpcre
		net-libs/libpcap
		sys-apps/memtester
		sys-apps/smartmontools
	)
"

DEPEND_debugd="
	!cros_host? (
		chromeos-base/shill
		virtual/modemmanager
	)
"

RDEPEND="
	platform2? (
		$(for v in ${!RDEPEND_*}; do echo "${!v}"; done)

		${LIBCHROME_DEPEND}
		chromeos-base/chromeos-minijail
		dev-cpp/gflags
		dev-libs/dbus-c++
		dev-libs/dbus-glib
		>=dev-libs/glib-2.30
		dev-libs/openssl
		dev-libs/protobuf
		sys-apps/dbus
		sys-apps/rootdev
	)
"

DEPEND="${RDEPEND}
	platform2? (
		$(for v in ${!DEPEND_*}; do echo "${!v}"; done)

		chromeos-base/protofiles

		test? (
			app-shells/dash
			dev-cpp/gmock
			dev-cpp/gtest
		)
	)
"

#
# Platform2 common helper functions
#

platform2() {
	local platform2_py="${S}/common-mk/platform2.py"

	local action="$1"

	"${platform2_py}" \
		$(platform2_get_target_args) \
		--use_flags="${USE}" \
		--action="${action}" \
		|| die
}

platform2_get_target_args() {
	if use cros_host; then
		echo "--host"
	else
		echo "--board=$(get_current_board_with_variant)"
	fi
}

platform2_test() {
	local platform2_test_py="${S}/common-mk/platform2_test.py"

	local action="$1"
	local bin="$2"
	local run_as_root="$3"
	local gtest_filter="$4"

	local run_as_root_flag=""
	if [[ "${run_as_root}" == "1" ]]; then
		run_as_root_flag="--run_as_root"
	fi

	"${platform2_test_py}" \
		--action="${action}" \
		--bin="${bin}" \
		$(platform2_get_target_args) \
		--gtest_filter="${gtest_filter}" \
		--use_flags="${USE}" \
		${run_as_root_flag} \
		|| die

}

platform2_multiplex() {
	# Runs a step (ie platform2_{test,install}) for a given subdir.
	# Sets up two variables to be used by the step:
	#   OUT = the build output directory, contains binaries/libs
	#   SRC = the path to subdir we're running the step for

	local phase=$1
	local OUT="$(cros-workon_get_build_dir)/out/Default"
	local pkg
	for pkg in "${CROS_WORKON_LOCALNAME[@]}"; do
		local SRC="${S}/${pkg}"
		pushd "${SRC}" >/dev/null
		platform2_${phase}_${pkg}
		popd >/dev/null
	done
}

#
# These are all the repo-specific install functions.
# Keep them sorted by name!
#

platform2_install_common-mk() {
	return 0
}

platform2_install_cros-disks() {
	use cros_host && return 0

	exeinto /opt/google/cros-disks
	doexe "${OUT}"/disks

	# Install USB device IDs file.
	insinto /opt/google/cros-disks
	doins usb-device-info

	# Install seccomp policy file.
	newins avfsd-seccomp-${ARCH}.policy avfsd-seccomp.policy

	# Install upstart config file.
	insinto /etc/init
	doins cros-disks.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.CrosDisks.conf
}

platform2_install_debugd() {
	into /
	dosbin "${OUT}"/debugd
	dodir /debugd

	exeinto /usr/libexec/debugd/helpers
	doexe "${OUT}"/{capture_packets,icmp,netif,modem_status,network_status}

	doexe src/helpers/{minijail-setuid-hack,send_at_command,systrace,capture_utility}.sh

	insinto /etc/dbus-1/system.d
	doins share/org.chromium.debugd.conf

	insinto /etc/init
	doins share/{debugd,trace_marker-test}.conf

	insinto /etc/init/perf_commands
	doins share/perf_commands/{arm,core,unknown}.txt
}

platform2_install_libchromeos() {
	./platform2_preinstall.sh "${OUT}" "${LIBCHROME_VERS}"

	local v
	insinto /usr/$(get_libdir)/pkgconfig
	for v in "${LIBCHROME_VERS[@]}"; do
		dolib.so "${OUT}"/lib/lib{chromeos,policy}*-${v}.so
		doins "${OUT}"/lib/libchromeos-${v}.pc
	done

	local dir dirs=( . dbus glib )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/chromeos/${dir}
		doins chromeos/${dir}/*.h
	done

	insinto /usr/include/policy
	doins chromeos/policy/*.h
}

platform2_install_metrics() {
	dobin "${OUT}"/metrics_{client,daemon} syslog_parser.sh

	dolib.so "${OUT}/lib/libmetrics.so"

	insinto /usr/include/metrics
	doins c_metrics_library.h \
		metrics_library{,_mock}.h \
		timer{,_mock}.h
}

platform2_install_system_api() {
	local dir dirs=( dbus switches )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/chromeos/${dir}
		doins -r ${dir}/*
	done
}

#
# These are all the repo-specific test functions.
# Keep them sorted by name!
#

platform2_test_common-mk() {
	return 0
}

platform2_test_cros-disks() {
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

	platform2_test "run" "${OUT}/disks_testrunner" "1" \
		"${gtest_filter_root_tests}"
	platform2_test "run" "${OUT}/disks_testrunner" "0" \
		"${gtest_filter_user_tests}"
}

platform2_test_debugd() {
	pushd "${SRC}/src" >/dev/null
	platform2_test "run" "${OUT}/debugd_testrunner"
	./helpers/capture_utility_test.sh || die
	popd >/dev/null
}

platform2_test_libchromeos() {
	! use x86 && ! use amd64 && return 0

	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		platform2_test "run" "${OUT}/libchromeos-${v}_unittests"
		platform2_test "run" "${OUT}/libpolicy-${v}_unittests"
	done
}

platform2_test_metrics() {
	local tests=(
		metrics_library_test
		metrics_daemon_test
		counter_test
		timer_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform2_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_system_api() {
	return 0
}

#
# These are the ebuild <-> Platform2 glue functions.
#

src_unpack() {
	# If we don't create the source directory when Platform2 is disabled
	# prepare complains. Once Platform2 is default, this isn't needed.
	mkdir -p "${S}"

	use platform2 && cros-workon_src_unpack
}

src_configure() {
	use platform2 && platform2 "configure"
}

src_compile() {
	use platform2 && platform2 "compile"
}

src_test() {
	use platform2 || return 0

	platform2_test "pre_test"
	platform2_multiplex test
	platform2_test "post_test"
}

src_install() {
	use platform2 && platform2_multiplex install
}
