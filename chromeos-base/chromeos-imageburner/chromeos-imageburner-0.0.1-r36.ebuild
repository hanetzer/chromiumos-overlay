# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d46e5466b336e3eb2e45e638b0e0c273f3561c8c"
CROS_WORKON_TREE="1e8285c600eed50d86724135846883d1d619d1d1"
CROS_WORKON_PROJECT="chromiumos/platform/image-burner"
CROS_WORKON_LOCALNAME=${CROS_WORKON_PROJECT##*/}

inherit cros-debug cros-workon

DESCRIPTION="Image-burning service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

LIBCHROME_VERS="180609"

RDEPEND="
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/metrics
	chromeos-base/platform2
	dev-libs/dbus-glib
	dev-libs/glib
	sys-apps/rootdev
"
DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)"

src_configure() {
        cros-workon_src_configure
}

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake image_burner
}

src_test() {
	tc-export CXX CC OBJCOPY PKG_CONFIG STRIP
	emake unittest_runner
	"${S}/unittest_runner" || die "imageburner unittests failed."
}

src_install() {
	dosbin image_burner

	insinto /etc/dbus-1/system.d
	doins ImageBurner.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.ImageBurner.service
}
