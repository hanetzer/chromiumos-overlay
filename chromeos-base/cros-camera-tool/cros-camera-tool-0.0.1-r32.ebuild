# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="0216e959f16f4173784f0336c542975e6c3fa68c"
CROS_WORKON_TREE="b34f0c73590d1c819f389ccd5d986a9d86207050"
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
