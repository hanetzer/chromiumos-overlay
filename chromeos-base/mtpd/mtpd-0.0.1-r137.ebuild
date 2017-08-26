# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT=("483d76fbf3a9945c1b5ff9d77eeee95658ca3883" "e7cd2685731a9d60b8330028e01051f529fab4c0")
CROS_WORKON_TREE=("873b31789d9b381721ece12545c206c6a90950eb" "8e50418ef7a967b9c4a881b14fcd1e367dcddca3")
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
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
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
