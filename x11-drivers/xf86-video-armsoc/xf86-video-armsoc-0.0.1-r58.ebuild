# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU Public License v2
CROS_WORKON_COMMIT="b9a2f5a3fc21297e402dc425328b3f6ca92bc3a1"
CROS_WORKON_TREE="4fe37a9bff7ef266ec8fd9b46290dd2feb9d14e3"

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

