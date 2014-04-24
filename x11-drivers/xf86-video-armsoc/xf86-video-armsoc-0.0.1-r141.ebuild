# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1cbe95777c1cc2ffb53d6d1cc176352e95bc3be3"
CROS_WORKON_TREE="68e0e833bfb8fbdb0d8dea7af406acb3b5ab827a"
CROS_WORKON_PROJECT="chromiumos/third_party/xf86-video-armsoc"
CROS_WORKON_LOCALNAME="xf86-video-armsoc"

XORG_DRI="always"
XORG_EAUTORECONF="yes"

inherit xorg-2 cros-workon

DESCRIPTION="X.Org driver for ARM devices"

KEYWORDS="-* arm"

RDEPEND=">=x11-base/xorg-server-1.9
	x11-libs/libdrm[video_cards_exynos]"
DEPEND="${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	mkdir -p "${S}"/m4
}

