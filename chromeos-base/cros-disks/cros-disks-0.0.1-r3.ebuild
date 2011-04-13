# Copyright (C) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=2
CROS_WORKON_COMMIT="24ea8393c213dcf8bc43da39ec7168786de93328"

KEYWORDS="arm amd64 x86"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Disk mounting daemon for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND="
	dev-cpp/gflags
	dev-libs/dbus-c++
	dev-libs/glib
"

DEPEND="${RDEPEND}
	chromeos-base/chromeos-chrome
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

CROS_WORKON_PROJECT="cros-disks"
CROS_WORKON_LOCALNAME="${CROS_WORKON_PROJECT}"

src_compile() {
	tc-export CXX CC OBJCOPY STRIP
	cros-debug-add-NDEBUG
	emake disks
}

