# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit cros-constants

CROS_WORKON_REPO=${CROS_GIT_AOSP_URL}
CROS_WORKON_PROJECT="libsync"
CROS_WORKON_LOCALNAME="../aosp/system/libsync"
CROS_WORKON_BLACKLIST="1"

inherit multilib cros-workon

DESCRIPTION="Library for Android sync objects"
HOMEPAGE="https://android.googlesource.com/platform/system/core/libsync"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"

src_prepare() {
	cp "${FILESDIR}/Makefile" "${S}" || die "Copying Makefile"
	cp "${FILESDIR}/strlcpy.c" "${S}" || die "Copying strlcpy.c"
	cp "${FILESDIR}/libsync.pc.template" "${S}" || die "Copying libsync.pc.template"
	epatch "${FILESDIR}/0001-libsync-add-prototype-for-strlcpy.patch"
}

src_configure() {
	cros-workon_src_configure
	export GENTOO_LIBDIR=$(get_libdir)
	tc-export CC
}

src_install() {
	cros-workon_src_install
}
