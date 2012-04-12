# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="6b86b50eb2318f0f66c456b1af3367666ef16193"
CROS_WORKON_TREE="abf3729b0f27f797a3b64c14adb3748d476a2ecc"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/gestures"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="Gesture recognizer library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-cros-debug"

RDEPEND="chromeos-base/libchrome:85268[cros-debug=]"
DEPEND="dev-cpp/gtest
	x11-base/xorg-server
	${RDEPEND}"

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
