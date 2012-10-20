# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU Public License v2
CROS_WORKON_COMMIT=2ada542ab5fc01d889030d97c035070c589136d0
CROS_WORKON_TREE="25cd414b3a6bc58fb8ca3d11e9e7e68fcec5d3d4"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/xf86-video-armsoc"
CROS_WORKON_LOCALNAME="xf86-video-armsoc"

XORG_DRI="always"
XORG_EAUTORECONF="yes"

inherit xorg-2 cros-workon

DESCRIPTION="X.Org driver for ARM devices"

KEYWORDS="-* arm"

RDEPEND=">=x11-base/xorg-server-1.9"
DEPEND="${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	mkdir -p "${S}"/m4
}

