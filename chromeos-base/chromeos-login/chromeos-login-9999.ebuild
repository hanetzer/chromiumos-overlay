# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="~arm ~amd64 ~x86"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND="chromeos-base/chromeos-cryptohome
	chromeos-base/chromeos-login-config
	chromeos-base/chromeos-minijail"

DEPEND="${RDEPEND}
	chromeos-base/libcros
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

CROS_WORKON_PROJECT="login_manager"
CROS_WORKON_LOCALNAME="${CROS_WORKON_PROJECT}"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	export CXXFLAGS="${CXXFLAGS} -gstabs"
	emake session_manager || die "chromeos-login compile failed."
	dump_syms session_manager > session_manager.sym 2>/dev/null || \
		die "symbol extraction failed"
}

src_test() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG

	emake session_manager_unittest || \
		die "chromeos-login compile tests failed."

	if use x86 ; then
		./session_manager_unittest ${GTEST_ARGS} || \
		    die "unit tests (with ${GTEST_ARGS}) failed!"
	fi
}

src_install() {
	dodir /etc/X11
	install --mode=0755 "${S}/chromeos-xsession" "${D}/etc/X11"

	into /
	dosbin "${S}/session_manager_setup.sh"
	dosbin "${S}/session_manager"
	dosbin "${S}/xstart.sh"

	insinto /etc/dbus-1/system.d
	doins "${S}/SessionManager.conf"

	insinto /usr/share/dbus-1/services
	doins "${S}/org.chromium.SessionManager.service"

	insinto /usr/lib/debug
	doins session_manager.sym

	insinto /usr/share/misc
	doins "${S}/recovery_ui.html"
}
