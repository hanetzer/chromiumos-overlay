# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("e6bebd36a8cb0db343d0895a3f6508aa2638f343" "d156962a4627350b47b5878a93821f7bffbabff1")
CROS_WORKON_TREE=("b9e418e7d7d77a0e2dcc9274bf22f119b2580de7" "8270384b5efa8b29ef280b608e6c02bfac49e363")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/shill")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/connectivity/shill")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/shill")
CROS_WORKON_BLACKLIST=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="${PN%-client}"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-workon platform

DESCRIPTION="Shill DBus client library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

DEPEND="
	cros_host? ( chromeos-base/chromeos-dbus-bindings )
"

RDEPEND="
	!<chromeos-base/shill-0.0.2
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/connectivity/shill"
}

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "shill"

	# Install dbus-c++ client library.
	insinto /usr/include/shill-client/shill/dbus_proxies
	doins ${OUT}/gen/include/shill/dbus_proxies/*.h
}
