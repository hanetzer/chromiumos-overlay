# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="cd10bc3e550bcde199d46c81011ea2432f31618b"
CROS_WORKON_TREE="2277a41124235fa61637a99878bb832615125b73"

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
	sys-apps/rootdev
	sys-apps/util-linux
	sys-block/parted
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
