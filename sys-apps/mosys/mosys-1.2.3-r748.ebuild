# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="3357db47d13b47bb4c417bd7a0fa93d98e473034"
CROS_WORKON_TREE="953c6b85b4f169f7d1ae313e7dca580621484ac0"
CROS_WORKON_PROJECT="chromiumos/platform/mosys"
CROS_WORKON_LOCALNAME="../platform/mosys"

MESON_AUTO_DEPEND=no

inherit flag-o-matic meson toolchain-funcs cros-unibuild cros-workon

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="static unibuild"

# We need util-linux for libuuid.
RDEPEND="unibuild? (
		chromeos-base/chromeos-config
		sys-apps/dtc
	)
	sys-apps/util-linux
	>=sys-apps/flashmap-0.3-r4"
DEPEND="${RDEPEND}"

src_configure() {
	if use unibuild; then
		cp "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
			lib/cros_config/config.dtb
		cp "${SYSROOT}${UNIBOARD_C_CONFIG}" \
			lib/cros_config/cros_config_data.c
	fi

	local emesonargs=(
		$(meson_use unibuild use_cros_config)
		-Darch=$(tc-arch)
		$(meson_use static)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if ! use static; then
		rm "${D}/usr/sbin/mosys_s"
	fi

	dodoc README TODO
}
