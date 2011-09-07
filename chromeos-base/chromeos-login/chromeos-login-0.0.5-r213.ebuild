# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="97254b54cb32a71d7d9061a2d4323fce5bf7b587"
CROS_WORKON_PROJECT="chromiumos/platform/login_manager"

KEYWORDS="arm amd64 x86"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test -touchui -webui_login"

RDEPEND="chromeos-base/chromeos-cryptohome
	chromeos-base/chromeos-minijail
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/protobuf
	x11-libs/gtk+"

DEPEND="${RDEPEND}
	chromeos-base/chromeos-chrome
	>=chromeos-base/libchrome-85268
	chromeos-base/libchrome_crypto
	chromeos-base/libcros
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

	if use webui_login ; then
		insinto /root
		newins "${S}/use_webui_login" .use_webui_login
	fi

	if use touchui ; then
		insinto /root
		newins "${S}/use_touchui" .use_touchui
	fi
}
