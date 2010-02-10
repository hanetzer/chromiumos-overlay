# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="List of packages that are needed on the buildhost (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RDEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	dev-cpp/gtest
	dev-cpp/gtkmm
	sys-devel/flex
	>=x11-proto/bigreqsproto-1.0.2
	>=x11-proto/compositeproto-0.4
	>=x11-proto/damageproto-1.1
	>=x11-proto/dri2proto-2.1
	>=x11-proto/fixesproto-4
	>=x11-proto/glproto-1.4.8
	>=x11-proto/randrproto-1.2.99.4
	>=x11-proto/resourceproto-1.0.2
	>=x11-proto/scrnsaverproto-1.1.0
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/xcb-proto-1.5
	>=x11-proto/xcmiscproto-1.1.2
	>=x11-proto/xextproto-7.0.4
	>=x11-proto/xf86dgaproto-2.0.3
	>=x11-proto/xf86driproto-2.0.4
	>=x11-proto/xf86vidmodeproto-2.2.2
	>=x11-proto/xineramaproto-1.1.2
	"

DEPEND=""
