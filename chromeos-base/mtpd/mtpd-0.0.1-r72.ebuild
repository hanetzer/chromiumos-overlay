# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="6c80b08afdff9fa92f98aee6675541a37827a1c4"
CROS_WORKON_TREE="2e9d1bc2f506e564fce1fc961e4066f5f5152d43"
CROS_WORKON_PROJECT="chromiumos/platform/mtpd"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="MTP daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

LIBCHROME_VERS="180609"

RDEPEND="
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	dev-cpp/gflags
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	dev-libs/protobuf
	media-libs/libmtp
	sys-fs/udev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gtest )"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}

src_install() {
	cros-workon_src_install
	exeinto /opt/google/mtpd
	doexe "${OUT}"/mtpd

	# Install seccomp policy file.
	insinto /opt/google/mtpd
	newins "mtpd-seccomp-${ARCH}.policy" mtpd-seccomp.policy

	# Install upstart config file.
	insinto /etc/init
	doins mtpd.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.Mtpd.conf
}
