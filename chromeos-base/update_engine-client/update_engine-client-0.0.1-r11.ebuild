# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("eba252986bb4c3366cd0a3b0d9a890e4a38d77d3" "6eddf26ce30989c0f4812b3b9de17760a40fdea7")
CROS_WORKON_TREE=("6b1459141017865ccb9930d8f78b20897ad35588" "51270386cb3ecd95c995bc80ad5b91b79c16bc64")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/update_engine")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/update_engine")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/update_engine")
CROS_WORKON_USE_VCSID=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="${PN%-client}"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-debug cros-workon platform

DESCRIPTION="Chrome OS Update Engine client library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

DEPEND="
	cros_host? ( chromeos-base/chromeos-dbus-bindings )
"

RDEPEND="
	!<chromeos-base/update_engine-0.0.3
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/update_engine"
}

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "update_engine"
}
