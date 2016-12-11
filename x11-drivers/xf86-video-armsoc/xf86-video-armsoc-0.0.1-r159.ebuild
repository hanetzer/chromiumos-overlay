# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1324c420aab940e3932d7960e13af6601d336733"
CROS_WORKON_TREE="1269c457c70e3acd856f315f210f1783e7fd0cd5"
CROS_WORKON_PROJECT="chromiumos/third_party/xf86-video-armsoc"
CROS_WORKON_LOCALNAME="xf86-video-armsoc"

XORG_DRI="always"
XORG_EAUTORECONF="yes"

inherit xorg-2 cros-workon

DESCRIPTION="X.Org driver for ARM devices"

KEYWORDS="-* arm"
IUSE="video_cards_exynos video_cards_rockchip"

RDEPEND=">=x11-base/xorg-server-1.9
	video_cards_exynos? ( x11-libs/libdrm[video_cards_exynos] )
	video_cards_rockchip? ( x11-libs/libdrm[video_cards_rockchip] )"
DEPEND="${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	mkdir -p "${S}"/m4
}

src_configure() {
	if use video_cards_exynos ; then
		XORG_CONFIGURE_OPTIONS=( --with-driver=exynos )
	elif use video_cards_rockchip ; then
		XORG_CONFIGURE_OPTIONS=( --with-driver=rockchip )
	fi
	xorg-2_src_configure
}
