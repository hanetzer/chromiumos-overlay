# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9ded3858e9b3edbaf0cc6f95a6951fa5ea9f9666"
CROS_WORKON_TREE=("94fdfbd8edee56984132ba08a33c0437bdee88f2" "25c524bfdcc5f9d4a8280b7db4449e42a7a01319" "413888b8ea9a5695763b620c5ed048a20960333b")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk cros-disks metrics"

PLATFORM_SUBDIR="cros-disks"

inherit cros-workon platform user

DESCRIPTION="Disk mounting daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="chromeless_tty +seccomp"

RDEPEND="
	app-arch/unrar
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/minijail
	chromeos-base/session_manager-client
	sys-apps/rootdev
	sys-apps/util-linux
	sys-fs/avfs
	sys-fs/dosfstools
	sys-fs/exfat-utils
	sys-fs/fuse-exfat
	sys-fs/ntfs3g
	virtual/udev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

pkg_preinst() {
	enewuser "cros-disks"
	enewgroup "cros-disks"

	enewuser "ntfs-3g"
	enewgroup "ntfs-3g"

	enewuser "avfs"
	enewgroup "avfs"

	enewuser "fuse-exfat"
	enewgroup "fuse-exfat"
}

src_install() {
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
	# Insert the --no-session-manager flag if needed.
	if use chromeless_tty; then
		sed -i -E "s/(CROS_DISKS_OPTS=')/\1--no_session_manager /" "${D}"/etc/init/cros-disks.conf || die
	fi

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.CrosDisks.conf
}

platform_pkg_test() {
	local gtest_filter_qemu_common=""
	gtest_filter_qemu_common+="DiskManagerTest.*"
	gtest_filter_qemu_common+=":ExternalMounterTest.*"
	gtest_filter_qemu_common+=":UdevDeviceTest.*"
	gtest_filter_qemu_common+=":MountInfoTest.RetrieveFromCurrentProcess"
	gtest_filter_qemu_common+=":GlibProcessTest.*"

	local gtest_filter_user_tests="-*.RunAsRoot*:"
	! use x86 && ! use amd64 && gtest_filter_user_tests+="${gtest_filter_qemu_common}"

	local gtest_filter_root_tests="*.RunAsRoot*-"
	! use x86 && ! use amd64 && gtest_filter_root_tests+="${gtest_filter_qemu_common}"

	platform_test "run" "${OUT}/disks_testrunner" "1" \
		"${gtest_filter_root_tests}"
	platform_test "run" "${OUT}/disks_testrunner" "0" \
		"${gtest_filter_user_tests}"
}