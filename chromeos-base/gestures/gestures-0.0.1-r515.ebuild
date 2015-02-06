# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a4c79700c880680c7dda7753d458cf082aafdf57"
CROS_WORKON_TREE="5436b3ae7e4dbffb8b618a539722b388e6fb7560"
CROS_WORKON_PROJECT="chromiumos/platform/gestures"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon libchrome

DESCRIPTION="Gesture recognizer library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang +X"
REQUIRED_USE="asan? ( clang )"

RDEPEND="chromeos-base/gestures-conf
	chromeos-base/libevdev
	dev-libs/jsoncpp
	sys-fs/udev"
DEPEND="dev-cpp/gtest
	X? ( x11-libs/libXi )
	${RDEPEND}"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	export USE_X11=$(usex X 1 0)
}

src_compile() {
	tc-export CXX
	cros-debug-add-NDEBUG

	emake clean  # TODO(adlr): remove when a better solution exists
	emake
}

src_test() {
	emake test

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		./test || die
	fi
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install
}
