# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="amd64 x86 arm"

inherit toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="pam_google test"

RDEPEND="chromeos-base/chromeos-cryptohome
	 chromeos-base/chromeos-minijail
         pam_google? ( chromeos-base/pam_google )
         chromeos-base/crash-dumper"

DEPEND="${RDEPEND}
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"

	elog "Using platform: $platform"
	cp -a "${platform}/login_manager" "${S}" || die
	ln -sf "${S}" "${S}/../login_manager"
}

src_compile() {
	tc-export CXX PKG_CONFIG

	emake -j1 session_manager || die "chromeos-login compile failed."
}

src_test() {
	tc-export CXX PKG_CONFIG

	emake -j1 session_manager_unittest signaller || \
		die "chromeos-login compile tests failed."

	if use x86 ; then
		./session_manager_unittest ${GTEST_ARGS} || \
		    die "unit tests (with ${GTEST_ARGS}) failed!"
	fi
}

src_install() {
	dodir /etc/X11
	install --mode=0755 "${S}/chromeos-xsession" "${D}/etc/X11"

        dodir /etc
        insinto /etc
        doins default_proxy

	into /
	dosbin "${S}/session_manager_setup.sh"
	dosbin "${S}/session_manager"
	dosbin "${S}/xstart.sh"

	insinto /etc/dbus-1/system.d
	doins "${S}/SessionManager.conf"

	insinto /usr/share/dbus-1/services
	doins "${S}/org.chromium.SessionManager.service"
}
