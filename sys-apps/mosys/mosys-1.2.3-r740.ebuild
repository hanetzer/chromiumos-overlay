# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("5042c40bc1c845f2712893dcc213e6c6c9f0a2f4" "a7fd67d83726100f6601e85df67cee9662576bfb")
CROS_WORKON_TREE=("99d4f98c0151c7e25437bb625f114bde347170d5" "ca1288c6f38a6467db19448f1840d08ef74d7ec0")
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/mosys"
)

CROS_WORKON_LOCALNAME=(
	"../platform2"
	"../platform/mosys"
)

CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/mosys"
)

CROS_WORKON_SUBTREE=(
	"common-mk"
	""
)

PLATFORM_SUBDIR="mosys"
MESON_AUTO_DEPEND=no

inherit flag-o-matic meson toolchain-funcs cros-unibuild cros-workon platform

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

src_unpack() {
	local s="${S}"
	platform_src_unpack
	# The platform eclass will look for mosys in src/platform2 This forces it
	# to look in src/platform.
	S="${s}/platform/mosys"
}

src_configure() {
	if use unibuild; then
		cp "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
			lib/cros_config/config.dtb
		cp "${SYSROOT}${UNIBOARD_C_CONFIG}" \
			lib/cros_config/cros_config_data.c
	fi

	local emesonargs=(
		-Duse_cros_config=$(usex unibuild true false)
		-Darch=$(tc-arch)
		-Dstatic=$(usex static true false)
	)
	meson_src_configure
}

src_compile() {
	meson_src_compile
}

platform_pkg_test() {
	meson_src_test
}

src_install() {
	meson_src_install

	if ! use static; then
		rm "${D}/usr/sbin/mosys_s"
	fi

	dodoc README TODO
}
