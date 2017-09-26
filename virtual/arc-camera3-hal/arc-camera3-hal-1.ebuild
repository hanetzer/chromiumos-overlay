# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="ARC++ camera3 HAL virtual package"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# Set to USB HAL by default. If devices don't use USB cameras, they should
# override the ebuild in their board overlay.
RDEPEND="media-libs/arc-camera3-hal-usb"
