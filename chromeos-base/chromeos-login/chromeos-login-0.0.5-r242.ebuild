# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="9b5d8c2a6c64f0fff01eb765c49693ebccd37847"
CROS_WORKON_PROJECT="chromiumos/platform/login_manager"

KEYWORDS="arm amd64 x86"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="-asan -aura test -touchui"

RDEPEND="chromeos-base/chromeos-cryptohome
	chromeos-base/chromeos-minijail
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/protobuf
	x11-libs/gtk+"

DEPEND="${RDEPEND}
	>=chromeos-base/libchrome-85268
	chromeos-base/libchrome_crypto
	chromeos-base/protofiles
	chromeos-base/system_api
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_compile() {
	tc-export CXX LD PKG_CONFIG
	cros-debug-add-NDEBUG
	emake login_manager || die "chromeos-login compile failed."
}

src_test() {
	tc-export CXX LD PKG_CONFIG
	cros-debug-add-NDEBUG

	emake keygen session_manager_unittest || \
		die "chromeos-login compile tests failed."

	if use x86 ; then
		./session_manager_unittest ${GTEST_ARGS} || \
		    die "unit tests (with ${GTEST_ARGS}) failed!"
	fi
}

src_install() {
	into /
	dosbin "${S}/keygen"
	dosbin "${S}/session_manager_setup.sh"
	dosbin "${S}/session_manager"
	dosbin "${S}/xstart.sh"

	insinto /usr/share/dbus-1/interfaces
	doins "${S}/session_manager.xml"

	insinto /etc/dbus-1/system.d
	doins "${S}/SessionManager.conf"

	insinto /usr/share/dbus-1/services
	doins "${S}/org.chromium.SessionManager.service"

	insinto /usr/share/misc
	doins "${S}/recovery_ui.html"

	# For user session processes.
	dodir /etc/skel/log

	if use touchui ; then
		insinto /root
		newins "${S}/use_touchui" .use_touchui
	fi

	if use asan; then
		insinto /root
		newins "${S}/debug_with_asan" .debug_with_asan
	fi

	if use aura || use touchui; then
		insinto /root
		newins "${S}/no_wm" .no_wm
	fi
}
