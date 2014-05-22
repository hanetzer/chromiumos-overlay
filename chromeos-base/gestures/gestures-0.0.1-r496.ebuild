# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="912764ae4895ae93d4b1b8f582f5a38d1c30a75c"
CROS_WORKON_TREE="e8fb40366eb5c66fcbc3412a28aa153c82b5430e"
CROS_WORKON_PROJECT="chromiumos/platform/gestures"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="Gesture recognizer library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="271506"

RDEPEND="chromeos-base/libevdev
	dev-cpp/gflags
	dev-libs/jsoncpp
	sys-fs/udev"
DEPEND="dev-cpp/gtest
	x11-libs/libXi
	${RDEPEND}"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	tc-export CXX
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}

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
