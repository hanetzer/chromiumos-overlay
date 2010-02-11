# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="pam_google slim"

RDEPEND="chromeos-base/chromeos-cryptohome
	 chromeos-base/chromeos-minijail
         pam_google? ( chromeos-base/pam_google )
         slim? ( x11-misc/slim )"

DEPEND="${RDEPEND}
        dev-cpp/gmock"

src_unpack() {
       local platform="${CHROMEOS_ROOT}/src/platform"
       elog "Using platform: $platform"
       mkdir -p "${S}/login_manager"
       cp -a "${platform}/login_manager" "${S}" || die
}

src_compile() {
       if tc-is-cross-compiler ; then
               tc-getCC
               tc-getCXX
               tc-getAR
               tc-getRANLIB
               tc-getLD
               tc-getNM
               export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
               export CCFLAGS="$CFLAGS"
       fi

       pushd login_manager
       # TODO: We can't use emake because the makefile will fail with -j
       make CXX="${CXX}" CXXFLAGS="$CFLAGS" session_manager || \
         die "chromeos-login compile failed."
       popd
}

src_install() {
       S="${S}/login_manager"

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
