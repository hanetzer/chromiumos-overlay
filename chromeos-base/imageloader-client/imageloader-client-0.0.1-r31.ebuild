# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("9783dde4a0d81aa9fdab7f6be3aff793ae469185" "b076fef1a86edcf6579df85e97a5653646a92073")
CROS_WORKON_TREE=("c7bd0d2ed679e2d5e421982f9841679d74fb5e7d" "ede617fdc306dc37f9839423d3dc9488840eaff4")
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