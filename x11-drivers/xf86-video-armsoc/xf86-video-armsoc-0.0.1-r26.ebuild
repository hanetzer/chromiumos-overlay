# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU Public License v2
CROS_WORKON_COMMIT=e7c0dc05d5d1e19f43dc82afe117eee53b55022b
CROS_WORKON_TREE="819d18d92bb95d41b8b14ae2a5d636dfe67fe347"

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

