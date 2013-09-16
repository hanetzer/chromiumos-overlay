# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a2321b9ad36d6a8e4078012945205732a9a45300"
CROS_WORKON_TREE="b72f1ef14dfc7383dfe1e5ccfbbec7d523814811"
CROS_WORKON_PROJECT="chromiumos/platform/cros-disks"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="Disk mounting daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm amd64 x86"
IUSE="-asan -clang platform2 test"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="
	app-arch/unrar
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	chromeos-base/metrics
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	sys-apps/eject
	sys-apps/rootdev
	sys-apps/util-linux
	sys-block/parted
	sys-fs/avfs
	sys-fs/exfat-utils
	sys-fs/fuse-exfat
	sys-fs/ntfs3g
	sys-fs/udev
"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/system_api
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

src_prepare() {
	use platform2 && return 0
	cros-workon_src_prepare
}

src_configure() {
	use platform2 && return 0
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	use platform2 && return 0
	cros-workon_src_compile
}

src_test() {
	use platform2 && return 0

	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}

src_install() {
	use platform2 && return 0

	cros-workon_src_install
	exeinto /opt/google/cros-disks
	doexe "${OUT}"/disks

	# Install USB device IDs file.
	insinto /opt/google/cros-disks
	doins usb-device-info

	# Install seccomp policy file.
	newins "avfsd-seccomp-${ARCH}.policy" avfsd-seccomp.policy

	# Install upstart config file.
	insinto /etc/init
	doins cros-disks.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.CrosDisks.conf
}
