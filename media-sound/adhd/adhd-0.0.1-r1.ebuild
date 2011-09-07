# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=3
CROS_WORKON_COMMIT="172808ce0bb9b5119d34f208ee7ad99d1608c2ee"
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

RDEPEND=">=media-libs/alsa-lib-1.0.24.1"
DEPEND=${RDEPEND}

src_compile() {
        cros_set_board_environment_variable
        emake CC="$(tc-getCC)" || die "Unable to build ADHD."
}

src_install() {
        cros_set_board_environment_variable
        dobin "build/${BOARD}/gavd/gavd" || die "Unable to install ADHD"
}
