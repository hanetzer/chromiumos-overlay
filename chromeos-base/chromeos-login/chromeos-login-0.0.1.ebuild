# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="~amd64 ~x86 ~arm"

if [[ ${PV} != "9999" ]] ; then
	inherit git

	KEYWORDS="amd64 x86 arm"

	EGIT_REPO_URI="http://src.chromium.org/git/login_manager.git"
	EGIT_COMMIT="v${PV}"
fi

inherit toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="pam_google slim test"

RDEPEND="chromeos-base/chromeos-cryptohome
	 chromeos-base/chromeos-minijail
         pam_google? ( chromeos-base/pam_google )
         slim? ( x11-misc/slim )"

DEPEND="${RDEPEND}
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

src_unpack() {
	if [[ -n "${EGIT_REPO_URI}" ]] ; then
		git_src_unpack
	else
		local platform="${CHROMEOS_ROOT}/src/platform"

		elog "Using platform: $platform"
		cp -a "${platform}/login_manager" "${S}" || die
	fi
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
		LIBC_PATH="${SYSROOT}/usr/lib/gcc/${CHOST}/"$(gcc-fullversion)
		# Set the library paths appropriately and
		# run the unit tests with the right loader.
		LD_LIBRARY_PATH=${SYSROOT}/usr/lib:${SYSROOT}/lib:${LIBC_PATH} \
			${SYSROOT}/lib/ld-linux.so.2 \
			./session_manager_unittest ${GTEST_ARGS} || \
			die "unit tests (with ${GTEST_ARGS}) failed!"
	fi
}

src_install() {
	if use slim ; then
		insinto /usr/share/slim/themes/chromeos
		doins "${S}/slim.theme"

		ln -s /usr/share/chromeos-assets/images/login_background.png \
			"${D}/usr/share/slim/themes/chromeos/background.png"
		ln -s /usr/share/chromeos-assets/images/login_panel.png \
			"${D}/usr/share/slim/themes/chromeos/panel.png"

		insinto /etc
		doins "${S}/slim.conf"
	fi

	# NOTE: The "slim" pam file is used for both slim-based and chromium-
	# based login for now.
	if use pam_google ; then
		insinto /etc/pam.d
	        doins "${S}/chrome"
		ln -s /etc/pam.d/chrome "${D}/etc/pam.d/slim"
	fi

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
}
