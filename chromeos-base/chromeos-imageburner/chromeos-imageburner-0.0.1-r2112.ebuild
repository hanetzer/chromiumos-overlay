# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3249fe596fc4935b376258217ca65c8cafafc811"
CROS_WORKON_TREE="fe9f31a931d79297ca86d994e1c9406fee22f561"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="image-burner"

inherit cros-workon platform

DESCRIPTION="Image-burning service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	dev-libs/dbus-glib
	dev-libs/glib
	sys-apps/rootdev
"
DEPEND="${RDEPEND}
	chromeos-base/libbrillo
	chromeos-base/system_api
"

src_install() {
	dosbin "${OUT}"/image_burner

	insinto /etc/dbus-1/system.d
	doins ImageBurner.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.ImageBurner.service
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}
