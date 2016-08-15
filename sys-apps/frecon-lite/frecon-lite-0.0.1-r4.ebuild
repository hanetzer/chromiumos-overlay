# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="da6df41a4ba404c0ad0afe5d0f46a99e2be6164d"
CROS_WORKON_TREE="a2a614509d6d40c5bec334b1d3cbfaab2bd0d7f2"
CROS_WORKON_PROJECT="chromiumos/platform/frecon"
CROS_WORKON_LOCALNAME="../platform/frecon"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Chrome OS KMS console (without DBUS support)"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="virtual/udev
	media-libs/libpng
	sys-apps/libtsm"

DEPEND="${RDEPEND}
	media-sound/adhd
	virtual/pkgconfig
	x11-libs/libdrm"

src_prepare() {
	export DBUS=0
	export TARGET=frecon-lite
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
	default
}
