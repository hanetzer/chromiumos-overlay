# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("8f652d3341b35c7ebcb2b4cd05de9679ccdf54a5" "b2d0677c761fdaa7a6d72b61e8a1833c9d1cb593")
CROS_WORKON_TREE=("8a38bea6ea088680390378a239da38938df00fea" "5ddbe36673e1f851ea1bf259801ec1f635b281b1")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/shill")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/connectivity/shill")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/shill")
CROS_WORKON_INCREMENTAL_BUILD=1

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

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library, hence both dependencies. We require the particular
# revision because libbrillo-0.0.1-r1 changed location of header files from
# chromeos/ to brillo/ and chromeos-dbus-bindings-0.0.1-r1058 generates the
# code using the new location.
DEPEND="
	cros_host? ( >=chromeos-base/chromeos-dbus-bindings-0.0.1-r1058 )
	>=chromeos-base/libbrillo-0.0.1-r1
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