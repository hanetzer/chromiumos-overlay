# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="e0720ca7a759d0689b1b308dfb8dd5140112655f"
CROS_WORKON_TREE=("94a1336ddfc584b23df58564be093463f801d558" "4d048b978c0416421c3da782c5a5c9cf41b3518c" "19022894c92a17f20d28edcddbeec5a655255b81" "c9231ae7ce0207c2d6e5733bf2643b33fa7ad010" "7198e8f1c1bb979088f90444abc0977eab51cd10" "413888b8ea9a5695763b620c5ed048a20960333b")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk chromeos-config libcontainer libpasswordprovider login_manager metrics"

PLATFORM_SUBDIR="login_manager"

inherit cros-workon platform systemd user

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cheets systemd unibuild"

RDEPEND="chromeos-base/bootstat
	unibuild? ( chromeos-base/chromeos-config )
	chromeos-base/chromeos-config-tools
	chromeos-base/minijail
	chromeos-base/cryptohome
	chromeos-base/libbrillo
	chromeos-base/libchromeos-ui
	chromeos-base/libcontainer
	chromeos-base/libpasswordprovider
	chromeos-base/metrics
	dev-libs/nss
	dev-libs/protobuf
	sys-apps/util-linux"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	chromeos-base/system_api
	chromeos-base/vboot_reference"

pkg_preinst() {
	enewgroup policy-readers
}

platform_pkg_test() {
	local tests=( session_manager_test )

	# Qemu doesn't support signalfd currently, and it's not clear how
	# feasible it is to implement :(.
	# So, filter out the tests that rely on signalfd().
	local gtest_qemu_filter=""
	if ! use x86 && ! use amd64; then
		gtest_qemu_filter+="-ChildExitHandlerTest.*"
		gtest_qemu_filter+=":SessionManagerProcessTest.*"
	fi



	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "0" "" "${gtest_qemu_filter}"
	done
}

src_install() {
	into /
	dosbin "${OUT}/keygen"
	dosbin "${OUT}/session_manager"

	# Install DBus configuration.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.SessionManagerInterface.xml

	insinto /etc/dbus-1/system.d
	doins SessionManager.conf

	# Adding init scripts
	if use systemd; then
		systemd_dounit init/systemd/*
		systemd_enable_service x-started.target
		systemd_enable_service multi-user.target ui.target
		systemd_enable_service ui.target ui.service
		systemd_enable_service ui.service machine-info.service
		systemd_enable_service login-prompt-visible.target send-uptime-metrics.service
		systemd_enable_service login-prompt-visible.target ui-init-late.service
		systemd_enable_service start-user-session.target login.service
		systemd_enable_service system-services.target ui-collect-machine-info.service
	else
		insinto /etc/init
		doins init/upstart/*.conf
	fi
	exeinto /usr/share/cros/init/
	doexe init/scripts/*

	# For user session processes.
	dodir /etc/skel/log

	# For user NSS database
	diropts -m0700
	# Need to dodir each directory in order to get the opts right.
	dodir /etc/skel/.pki
	dodir /etc/skel/.pki/nssdb
	# Yes, the created (empty) DB does work on ARM, x86 and x86_64.
	certutil -N -d "sql:${D}/etc/skel/.pki/nssdb" -f <(echo '') || die

	insinto /etc
	doins chrome_dev.conf
}
