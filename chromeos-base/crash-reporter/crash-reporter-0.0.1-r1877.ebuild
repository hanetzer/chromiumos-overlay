# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="f2940f738a66cefe7e475f965981961c0ef45573"
CROS_WORKON_TREE="d6dbfc384bc1322c21572be01e1f9e4833c82422"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="crash-reporter"

inherit cros-i686 cros-workon platform systemd udev

DESCRIPTION="Crash reporting service that uploads crash reports with debug
information"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cheets cros_embedded -cros_host -direncryption systemd test"
REQUIRED_USE="!cros_host"

RDEPEND="
	chromeos-base/chromeos-ca-certificates
	chromeos-base/google-breakpad[cros_i686?]
	chromeos-base/libbrillo
	chromeos-base/metrics
	dev-libs/libpcre
	net-misc/curl
	direncryption? ( sys-apps/keyutils )
"
DEPEND="
	${RDEPEND}
	chromeos-base/debugd-client
	chromeos-base/session_manager-client
	chromeos-base/system_api
	dev-cpp/gtest
	test? (
		dev-cpp/gmock
	)
	sys-devel/flex
"

src_configure() {
	platform_src_configure
	use cheets && use_i686 && platform_src_configure_i686
}

src_compile() {
	platform_src_compile
	use cheets && use_i686 && platform_src_compile_i686 "core_collector"
}

src_install() {
	into /
	dosbin "${OUT}"/crash_reporter
	dosbin crash_sender

	into /usr
	use cros_embedded || dobin "${OUT}"/list_proxies
	use cros_embedded || dobin "${OUT}"/warn_collector
	dosbin kernel_log_collector.sh

	if use cheets; then
		dobin "${OUT}"/core_collector
		use_i686 && newbin "$(platform_out_i686)"/core_collector "core_collector32"
	fi

	if use systemd; then
		systemd_dounit init/crash-reporter.service
		systemd_dounit init/crash-boot-collect.service
		systemd_enable_service multi-user.target crash-reporter.service
		systemd_enable_service multi-user.target crash-boot-collect.service
		systemd_dounit init/crash-sender.service
		systemd_dounit init/crash-sender.timer
		systemd_enable_service timers.target crash-sender.timer
		if ! use cros_embedded; then
			systemd_dounit init/warn-collector.service
			systemd_enable_service multi-user.target warn-collector.service
		fi
	else
		insinto /etc/init
		doins init/crash-reporter.conf
		doins init/crash-boot-collect.conf
		doins init/crash-sender.conf
		use cros_embedded || doins init/warn-collector.conf
	fi

	insinto /etc
	doins crash_reporter_logs.conf

	udev_dorules 99-crash-reporter.rules
}

platform_pkg_test() {
	platform_test "run" "${OUT}/crash_reporter_test"
}