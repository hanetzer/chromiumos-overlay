# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a2d86ce40c7f28b6dfcb7ec7b63c5ecbb6868412"
CROS_WORKON_TREE="71437d2bb41d2499a263d66b4e4f9e29084ad0cc"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/image-burner"

KEYWORDS="arm amd64 x86"

inherit cros-debug cros-workon

DESCRIPTION="Image-burning service for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND="
	chromeos-base/libchromeos
	dev-libs/dbus-glib
	dev-libs/glib
	sys-apps/rootdev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake image_burner || die "chromeos-imageburner compile failed."
	emake image_burner_tester || die "chromeos-imageburner compile failed."
}

src_test() {
	tc-export CXX CC OBJCOPY PKG_CONFIG STRIP
	emake unittest_runner || \
		die "chromeos-imageburner unittest compile failed."
	"${S}/unittest_runner" || die "imageburner unittests failed."
}

src_install() {
	dosbin "${S}/image_burner"
	dosbin "${S}/image_burner_tester"

	insinto /etc/dbus-1/system.d
	doins "${S}/ImageBurner.conf"

	insinto /usr/share/dbus-1/system-services
	doins "${S}/org.chromium.ImageBurner.service"
}
