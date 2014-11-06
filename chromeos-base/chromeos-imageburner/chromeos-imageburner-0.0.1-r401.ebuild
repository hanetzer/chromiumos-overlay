# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f2a1f867e9aaa87ed538ad9ef13085dbe43eb3d0"
CROS_WORKON_TREE="037e4e112957a2e2b9f65f52ce636eec561dfd94"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="image-burner"

inherit cros-workon platform

DESCRIPTION="Image-burning service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/platform2
	dev-libs/dbus-glib
	dev-libs/glib
	sys-apps/rootdev
"
DEPEND="${RDEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)"

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
