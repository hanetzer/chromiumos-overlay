# Copyright (C) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=2
CROS_WORKON_COMMIT="9d263f6360202c3e58f4b5d77b2e621df8f1ffdf"
CROS_WORKON_PROJECT="chromiumos/platform/chaps"

KEYWORDS="arm amd64 x86"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="PKCS #11 layer over TrouSerS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND="
	chromeos-base/libchrome
	dev-libs/dbus-c++
	dev-cpp/gflags"

DEPEND="${RDEPEND}
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_compile() {
	tc-export CXX OBJCOPY PKG_CONFIG STRIP
	cros-debug-add-NDEBUG
	emake all || die "failed to make chaps"
}

src_test() {
	cros-debug-add-NDEBUG
	emake tests || die "failed to make chaps tests"
	emake runtests || die "failed to run chaps tests"
}

src_install() {
	dosbin build-opt/chapsd || die
	dolib.so build-opt/libchaps.so || die
	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.Chaps.conf || die
}

