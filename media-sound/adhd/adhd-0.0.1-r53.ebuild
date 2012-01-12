# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4
CROS_WORKON_COMMIT="457dd55c3e7206a59189a06942a089688c10de65"
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
CROS_WORKON_LOCALNAME="adhd"
inherit toolchain-funcs cros-workon cros-board

DESCRIPTION="Google A/V Daemon"
HOMEPAGE="http://www.chromium.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=">=media-libs/alsa-lib-1.0.24.1
	>=sys-apps/dbus-1.4.12
	dev-libs/libpthread-stubs
	sys-fs/udev"
DEPEND=${RDEPEND}

src_compile() {
	local board=$(get_current_board_with_variant)
	emake BOARD=${board} CC="$(tc-getCC)" || die "Unable to build ADHD"
}

src_install() {
	# Install 'gavd' executable.
	#
	local board=$(get_current_board_with_variant)
	dobin "build/${board}/gavd/gavd" || die "Unable to install ADHD"

	# Install Upstart configuration, adhd.conf, into /etc/init.
	#
	# Compare 'chromeos-init-9999.ebuild'.
	insinto	 /etc/init
	doins upstart/adhd.conf || die

	# Install factory default sound settings: '/etc/asound.state'
	#
	# Installation method copied from audioconfig-board*.ebuild
	insinto /etc
	newins "${S}"/factory-default/asound.state.${board} asound.state || die
}
