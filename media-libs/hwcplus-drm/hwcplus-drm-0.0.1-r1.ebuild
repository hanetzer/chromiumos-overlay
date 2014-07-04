# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4

CROS_WORKON_COMMIT="7376a8da1c961115a61d7a3cb23bb13e4153583d"
CROS_WORKON_TREE="14ee94ad39d9b547affb3f24833aac2afcb797ed"
CROS_WORKON_PROJECT="chromiumos/third_party/hwcplus-drm"

inherit multilib cros-workon

DESCRIPTION="Android-like graphics library for Linux"
HOMEPAGE="https://chromium.googlesource.com/chromium/src/third_party/hwcplus/"

# Android-x86 files are Apache 2.0.
# The MIT || X bit is from libdrm, whence we also took intel_chipset.h.
LICENSE="BSD-Google Apache-2.0 || ( MIT X )"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

RDEPEND="
	x11-libs/libdrm
	media-libs/hwcplus
"

DEPEND="${RDEPEND}
"

src_configure() {
	cd src
	# this software doesn't have a normal configure script
	CC=$(tc-getCC) CXX=$(tc-getCXX) LIBDIR=$(get_libdir) ./configure
}

src_compile() {
	cd src
	default
}

src_install() {
	cd src
	default
}
