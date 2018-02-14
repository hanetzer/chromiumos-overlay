# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="ef6034c665fc2737c5042efdc92c47f3e41e1463"
CROS_WORKON_TREE="0c802c0c185734f418d74bbb36503491ff3fb354"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME='../platform/arc-camera'

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS camera test utility."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="
	chromeos-base/libbrillo"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} cros-camera-tool
}

src_install() {
	dobin tools/cros-camera-tool
}
