# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="2b654fbfe3bb6599bcc2538999aa418666690f06"
CROS_WORKON_TREE="e16c5e8eefbbcc7ef67bc0ce66fd497c07433eaf"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-debug cros-workon libchrome

DESCRIPTION="Image-burning service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang test"
REQUIRED_USE="asan? ( clang )"

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

src_unpack() {
	cros-workon_src_unpack
	S+="/image-burner"
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	clang-setup-env
	emake image_burner
}

src_test() {
	tc-export CXX CC OBJCOPY PKG_CONFIG STRIP
	emake unittest_runner
	if ! use x86 && ! use amd64 ; then
		einfo Skipping unit tests on non-x86 platform
	else
		"${S}/unittest_runner" || die "imageburner unittests failed."
	fi
}

src_install() {
	dosbin image_burner

	insinto /etc/dbus-1/system.d
	doins ImageBurner.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.ImageBurner.service
}
