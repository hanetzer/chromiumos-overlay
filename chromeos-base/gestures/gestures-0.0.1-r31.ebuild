# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="ca8593f7ee432c5ea061ed41382236de3d65accd"

CROS_WORKON_PROJECT="chromiumos/platform/gestures"
inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Gesture recognizer library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="-cros-debug"
KEYWORDS="amd64 arm x86"

RDEPEND="chromeos-base/libchrome"
DEPEND="dev-cpp/gtest
	x11-base/xorg-server
	${RDEPEND}"

src_compile() {
	tc-export CXX
	cros-debug-add-NDEBUG

	emake clean  # TODO(adlr): remove when a better solution exists
	emake || die "Gestures compile failed"
}

src_test() {
	tc-export CXX
	cros-debug-add-NDEBUG

	TARGETS="test"
	emake ${TARGETS} || die "failed to build tests"

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		./test
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
