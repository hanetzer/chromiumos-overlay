# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU Public License v2
CROS_WORKON_COMMIT="5e7fe5dfb6d7330a8b46537738dfa32afe9b02ef"
CROS_WORKON_TREE="f1ab7562a7010a62d84e038f5715e49faec5980a"

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

