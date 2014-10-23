# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="429e7606cf38b5b381c6b10fbf00b120455786d9"
CROS_WORKON_TREE="489a988e536618feb4d899e36d417cc3a93c7158"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1

PLATFORM2_PROJECTS=(
	"chromiumos-wide-profiling"
	"debugd"
	"lorgnette"
	"vpn-manager"
)
CROS_WORKON_LOCALNAME="platform2"  # With all platform2 subdirs
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_TOOLDIR="${S}/platform2/common-mk"

inherit cros-debug cros-workon eutils multilib platform toolchain-funcs udev user

DESCRIPTION="Platform2 for Chromium OS: a GYP-based incremental build system"
HOMEPAGE="http://www.chromium.org/"
TEST_DATA_SOURCE="platform2-20140722.tar.gz"
SRC_URI="profile? ( gs://chromeos-localmirror/distfiles/${TEST_DATA_SOURCE} )"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan +cellular -clang cros_embedded +debugd cros_host lorgnette +power_management +profile platform2 +seccomp tcmalloc test +vpn wimax"
REQUIRED_USE="
	asan? ( clang )
"

RDEPEND_debugd="
	debugd? (
		cellular? (
			virtual/modemmanager
		)
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

RDEPEND_quipper="
	profile? (
		dev-util/perf
	)
"

RDEPEND_vpn_manager="
	vpn? (
		net-dialup/ppp
		net-dialup/xl2tpd
		net-misc/strongswan
	)
"

RDEPEND="
	platform2? (
		!cros_host? ( $(for v in ${!RDEPEND_*}; do echo "${!v}"; done) )

		${LIBCHROME_DEPEND}
		chromeos-base/chromeos-minijail
		>=dev-libs/glib-2.30
		tcmalloc? ( dev-util/google-perftools )
		sys-apps/dbus
		!chromeos-base/chromeos-debugd[-platform2]
		chromeos-base/libchromeos
		chromeos-base/metrics
		chromeos-base/system_api
		!chromeos-base/vpn-manager[-platform2]
		!dev-util/quipper
	)
"

# The gtest dep is required even when USE=-test because of the gtest_prod.h
# header.  Non-test code is allowed to include that.  http://crbug.com/359322
DEPEND="${RDEPEND}
	platform2? (
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
		"${PLATFORM2_PROJECTS[@]/#/${S}/platform2/}"
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

platform2_install_chromiumos-wide-profiling() {
	use cros_host && return 0
	use profile || return 0
	dobin "${OUT}"/quipper
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
	doins share/perf_commands/{arm,celeron-2955u,core,unknown}.txt
}

platform2_install_lorgnette() {
	use lorgnette || return 0
	dobin "${OUT}"/lorgnette
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.lorgnette.conf
	insinto /usr/share/dbus-1/system-services
	doins dbus_service/org.chromium.lorgnette.service
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

#
# These are all the repo-specific test functions.
# Keep them sorted by name!
#

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

#
# These are the ebuild <-> Platform2 glue functions.
#


src_unpack() {
	# If we don't create the source directory when Platform2 is disabled
	# prepare complains. Once Platform2 is default, this isn't needed.
	mkdir -p "${S}"

	use platform2 && cros-workon_src_unpack
	if use profile; then
		pushd "${S}/platform2" >/dev/null
		unpack ${TEST_DATA_SOURCE}
		popd >/dev/null
	fi
}

src_configure() {
	if use platform2; then
		cros-debug-add-NDEBUG
		append-lfs-flags
		clang-setup-env
		cros-workon_check_clang_syntax
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

	# Create debugfs-access user and group, which is needed by the
	# chromeos_startup script to mount /sys/kernel/debug.  This is needed
	# by bootstat and ureadahead.
	enewuser "debugfs-access"
	enewgroup "debugfs-access"

	if use debugd; then
		for ug in debugd debugd-logs; do
			enewuser "${ug}"
			enewgroup "${ug}"
		done
		enewgroup "daemon-store"
		enewgroup "logs-access"
	fi
}
