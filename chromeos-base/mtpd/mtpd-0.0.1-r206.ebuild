# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT=("9cecc7a917ac32322d22443127d662af26e046b8" "36d84953c7104d1950648647d19a973c1275fea6")
CROS_WORKON_TREE=("6a17b7f6c338d1fb2cebcb9764746e3437bcdd31" "069486b906d0ce7b41bac0dc3854ab5e36d57684")
CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/mtpd"
)
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/mtpd"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/mtpd"
)
PLATFORM_SUBDIR="mtpd"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon platform systemd user

DESCRIPTION="MTP daemon for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/mtpd/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan +seccomp systemd test"

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/protobuf:=
	media-libs/libmtp
	virtual/udev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	# look in src/platform
	S="${s}/platform/mtpd"
}

src_install() {
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
	doins dbus/org.chromium.Mtpd.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/mtpd_testrunner"
}

pkg_preinst() {
	enewuser "mtp"
	enewgroup "mtp"
}
