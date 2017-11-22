# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("619471e97b6197290448c268f9d51974a9ac193f" "1c3fbed9123c081c73b1bc97f755ccf7a753b74d")
CROS_WORKON_TREE=("ebe3c4d39d139164bdbf4bf8b559d74bc32d391b" "26a3051c85d5401290a097eb6b9266af8b8d0864")
CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/imageloader"
)
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/imageloader"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/imageloader"
)
PLATFORM_SUBDIR="imageloader"
PLATFORM_GYP_FILE="imageloader-client.gyp"

inherit cros-workon platform

DESCRIPTION="ImageLoader DBus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/imageloader/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library.
DEPEND="
	cros_host? ( chromeos-base/chromeos-dbus-bindings )
	chromeos-base/libbrillo
"

RDEPEND="
	chromeos-base/imageloader
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/platform/imageloader"
}

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "imageloader"
}