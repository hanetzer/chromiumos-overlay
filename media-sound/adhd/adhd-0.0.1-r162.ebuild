# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
CROS_WORKON_COMMIT="bec352c9c73028e7ea56b95da1ff6caf7c973d46"
CROS_WORKON_TREE="2b28f159037cbdf66194f8fee7d72548c1dcaf01"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
CROS_WORKON_LOCALNAME="adhd"

inherit toolchain-funcs autotools cros-workon cros-board

DESCRIPTION="Google A/V Daemon"
HOMEPAGE="http://www.chromium.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=">=media-libs/alsa-lib-1.0.24.1
	media-libs/speex
	dev-libs/iniparser
	>=sys-apps/dbus-1.4.12
	dev-libs/libpthread-stubs
	sys-fs/udev"
DEPEND=${RDEPEND}

src_prepare() {
	cd cras
	eautoreconf
}

src_configure() {
	cd cras
	econf
}

src_compile() {
	local board=$(get_current_board_with_variant)
	emake BOARD=${board} CC="$(tc-getCC)" || die "Unable to build ADHD"
}

src_install() {
	local board=$(get_current_board_with_variant)
	emake BOARD=${board} DESTDIR="${D}" install
}
