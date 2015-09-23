# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("2c1973c6ee7cc0f06a6f2a23199d2cdff6c47489" "d7971efc3a8e54042534207a8f34bfe3b6325f3f")
CROS_WORKON_TREE=("314ce15e69571ed1821ddab59b87ea5f1ad843c0" "6d249b517719606dfb690b10534195728896a94d")
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
