# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4b87997919b39d6e99555e0d06c1239b6c99cf8e"
CROS_WORKON_TREE="47143a925720b4cef53d00fbb8f7780165d2d2dd"
CROS_WORKON_PROJECT="chromiumos/third_party/libdrm"

inherit xorg-2 cros-workon

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
SRC_URI=""

# This package uses the MIT license inherited from Xorg but fails to provide
# any license file in its source, so we add X as a license, which lists all
# the Xorg copyright holders and allows license generation to pick them up.
LICENSE="|| ( MIT X )"
SLOT="0"
KEYWORDS="*"
VIDEO_CARDS="amdgpu exynos freedreno intel mediatek nouveau omap radeon vmware rockchip"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} libkms manpages +udev"
REQUIRED_USE="video_cards_exynos? ( libkms )
	video_cards_mediatek? ( libkms )
	video_cards_rockchip? ( libkms )"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs
	udev? ( virtual/udev )
	video_cards_intel? ( >=x11-libs/libpciaccess-0.10 )
	!<x11-libs/libdrm-tests-2.4.58-r3
"

DEPEND="${RDEPEND}"

XORG_EAUTORECONF=yes

src_prepare() {
	xorg-2_src_prepare
}

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		--enable-install-test-programs
		$(use_enable video_cards_amdgpu amdgpu)
		$(use_enable video_cards_exynos exynos-experimental-api)
		$(use_enable video_cards_freedreno freedreno)
		$(use_enable video_cards_intel intel)
		$(use_enable video_cards_mediatek mediatek-experimental-api)
		$(use_enable video_cards_nouveau nouveau)
		$(use_enable video_cards_omap omap-experimental-api)
		$(use_enable video_cards_radeon radeon)
		$(use_enable video_cards_vmware vmwgfx)
		$(use_enable video_cards_rockchip rockchip-experimental-api)
		$(use_enable libkms)
		$(use_enable manpages)
		$(use_enable udev)
		--disable-cairo-tests
	)
	xorg-2_src_configure
}
