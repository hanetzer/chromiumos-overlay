# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="cb2befbe2d5521f9fe8d38d474ee6fe6cb6e70db"
CROS_WORKON_TREE="55712e2f8975403adf0ba26f22068fcaf5406411"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="cros-disks"

inherit cros-workon platform user

DESCRIPTION="Disk mounting daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
IUSE="+seccomp test"
KEYWORDS="*"

RDEPEND="
	app-arch/unrar
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	chromeos-base/metrics
	dev-libs/dbus-c++
	dev-libs/glib
	sys-apps/rootdev
	sys-apps/util-linux
	sys-fs/avfs
	sys-fs/dosfstools
	sys-fs/exfat-utils
	sys-fs/fuse-exfat
	sys-fs/ntfs3g
	sys-fs/udev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest"

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
