# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.
CROS_WORKON_COMMIT="5c023251101118b920aa858dfe3d5132b3b9a7d7"
CROS_WORKON_TREE="b0d7f4e1f6dfca13acf3570169982892f5905a74"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/cros-disks"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Disk mounting daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm amd64 x86"
IUSE="splitdebug test"

LIBCHROME_VERS="125070"

RDEPEND="
	app-arch/unrar
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	chromeos-base/metrics
	dev-cpp/gflags
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	sys-apps/parted
	sys-apps/rootdev
	sys-apps/util-linux
	sys-fs/avfs
	sys-fs/ntfs3g
	sys-fs/udev
"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/system_api
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

src_compile() {
	tc-export CXX CC OBJCOPY PKG_CONFIG STRIP
	cros-debug-add-NDEBUG
	emake OUT=build-opt BASE_VER=${LIBCHROME_VERS} disks
}

src_test() {
	tc-export CXX CC OBJCOPY PKG_CONFIG STRIP
	emake OUT=build-opt BASE_VER=${LIBCHROME_VERS} tests
}

src_install() {
	exeinto /opt/google/cros-disks
	doexe build-opt/disks

	# Install USB device IDs file.
	insinto /opt/google/cros-disks
	doins usb-device-info

	# Install seccomp policy file.
	if [ -f "avfsd-seccomp-${ARCH}.policy" ]; then
		newins "avfsd-seccomp-${ARCH}.policy" avfsd-seccomp.policy
	fi

	# Install upstart config file.
	insinto /etc/init
	doins cros-disks.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.CrosDisks.conf
}
