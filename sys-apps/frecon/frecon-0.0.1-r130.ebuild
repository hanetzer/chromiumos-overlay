# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="3ccfd38dce51bdcf28f0c1c5beec0a08a128bec3"
CROS_WORKON_TREE="b02606acd94bca57e5f931ca234dc4422774bdf5"
CROS_WORKON_PROJECT="chromiumos/platform/frecon"
CROS_WORKON_LOCALNAME="../platform/frecon"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Chrome OS KMS console"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="virtual/udev
	sys-apps/dbus
	media-libs/libpng:0=
	sys-apps/libtsm"

DEPEND="${RDEPEND}
	media-sound/adhd
	virtual/pkgconfig
	x11-libs/libdrm"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.frecon.conf
	default
}
