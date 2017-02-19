# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e2da245689e83bc4eb7abb4cd73e06124618550b"
CROS_WORKON_TREE="acc7aca3a743b3fe92b56c64833b7048b6afa734"
CROS_WORKON_PROJECT="chromiumos/platform/mtpd"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon libchrome systemd user

DESCRIPTION="MTP daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang +seccomp systemd test"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	dev-libs/protobuf
	media-libs/libmtp
	virtual/udev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gtest )"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		einfo Skipping unit tests on non-x86 platform
	else
		# Needed for `cros_run_unit_tests`.
		cros-workon_src_test
	fi
}

src_install() {
	cros-workon_src_install
	exeinto /opt/google/mtpd
	doexe "${OUT}"/mtpd

	# Install seccomp policy file.
	insinto /opt/google/mtpd
	use seccomp && newins "mtpd-seccomp-${ARCH}.policy" mtpd-seccomp.policy

	# Install the init scripts.
	if use systemd; then
		systemd_dounit mtpd.service
		systemd_enable_service system-services.target mtpd.service
	else
		insinto /etc/init
		doins mtpd.conf
	fi

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.Mtpd.conf
}

pkg_preinst() {
	enewuser "mtp"
	enewgroup "mtp"
}
